<?php
require_once 'db.php';

// Allow from any origin (CORS)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$input = file_get_contents('php://input');
$data = json_decode($input, true);

if (!$data) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Invalid JSON payload."
    ]);
    exit();
}

$buyerId = isset($data['buyer_id']) ? (int)$data['buyer_id'] : 0;
$kitLevel = isset($data['level']) ? trim($data['level']) : 'Level 1';
$quantity = isset($data['quantity']) ? (int)$data['quantity'] : 1;
$program = isset($data['program']) ? trim($data['program']) : $kitLevel; // program name (e.g. 'Abacus')
$selectedSchoolId = isset($data['selected_school_id']) ? (int)$data['selected_school_id'] : null;

if (empty($buyerId) || empty($kitLevel) || $quantity <= 0) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Required parameters (buyer_id, level, quantity) are missing or invalid."
    ]);
    exit();
}

try {
    $conn->beginTransaction();

    // 1. Determine kit price (Fallback if kits catalog has not been populated)
    $stmtKit = $conn->prepare("SELECT id, price FROM kits WHERE level = ?");
    $stmtKit->execute([$kitLevel]);
    $kit = $stmtKit->fetch();
    
    $kitId = 1;
    $unitPrice = 1500.00; // default kit price

    if ($kit) {
        $kitId = (int)$kit['id'];
        $unitPrice = (float)$kit['price'];
    } else {
        // Auto-seed kit master catalog row for level if not present
        $stmtSeed = $conn->prepare("INSERT INTO kits (level, price) VALUES (?, ?)");
        $stmtSeed->execute([$kitLevel, $unitPrice]);
        $kitId = (int)$conn->lastInsertId();
    }

    $totalAmount = $unitPrice * $quantity;

    // 2. Create kit order — store program name and selected_school_id
    $stmtOrder = $conn->prepare("INSERT INTO kit_orders (buyer_id, total_amount, payment_status, program, selected_school_id) VALUES (?, ?, 'Paid', ?, ?)");
    $stmtOrder->execute([$buyerId, $totalAmount, $program, $selectedSchoolId]);
    $orderId = (int)$conn->lastInsertId();

    // 3. Create kit order items
    $stmtItem = $conn->prepare("INSERT INTO kit_order_items (order_id, kit_id, quantity, price_at_purchase) VALUES (?, ?, ?, ?)");
    $stmtItem->execute([$orderId, $kitId, $quantity, $unitPrice]);

    // 4. Use shared per-kit commission distributor from db.php
    distributeCommission($conn, $orderId);

    log_debug("Order #$orderId placed by buyer $buyerId — program: $program, qty: $quantity");
    $conn->commit();

    echo json_encode([
        "status" => "success",
        "message" => "Kit order placed successfully. MLM commissions distributed.",
        "order_id" => $orderId,
        "total_amount" => $totalAmount
    ]);

} catch (Exception $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    log_debug("Failed to order kit for user $buyerId: " . $e->getMessage());
    echo json_encode([
        "status" => "error",
        "message" => "Order placement failed: " . $e->getMessage()
    ]);
}
?>
