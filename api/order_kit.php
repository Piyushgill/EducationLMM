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

    // 2. Create kit order
    $stmtOrder = $conn->prepare("INSERT INTO kit_orders (buyer_id, total_amount, payment_status) VALUES (?, ?, 'Paid')");
    $stmtOrder->execute([$buyerId, $totalAmount]);
    $orderId = (int)$conn->lastInsertId();

    // 3. Create kit order items
    $stmtItem = $conn->prepare("INSERT INTO kit_order_items (order_id, kit_id, quantity, price_at_purchase) VALUES (?, ?, ?, ?)");
    $stmtItem->execute([$orderId, $kitId, $quantity, $unitPrice]);

    // 4. Calculate MLM 8-Tier Commissions
    // Commission rates: Tier 1: 10%, Tier 2: 5%, Tiers 3-8: 2%
    $rates = [
        1 => 0.10,
        2 => 0.05,
        3 => 0.02,
        4 => 0.02,
        5 => 0.02,
        6 => 0.02,
        7 => 0.02,
        8 => 0.02
    ];

    $currentChildId = $buyerId;
    $logMsg = "MLM Commission payout for Order #$orderId (buyer: $buyerId): ";

    for ($tier = 1; $tier <= 8; $tier++) {
        // Find parent
        $stmtParent = $conn->prepare("SELECT parent_id FROM user_relations WHERE child_id = ?");
        $stmtParent->execute([$currentChildId]);
        $relation = $stmtParent->fetch();

        if (!$relation) {
            // Reached root of the hierarchy
            break;
        }

        $parentId = (int)$relation['parent_id'];
        $commissionRate = $rates[$tier];
        $commissionAmount = $totalAmount * $commissionRate;

        // Insert commission row
        $stmtComm = $conn->prepare("
            INSERT INTO commissions (recipient_id, trigger_user_id, order_id, amount, tier_level, status) 
            VALUES (?, ?, ?, ?, ?, 'Paid')
        ");
        $stmtComm->execute([$parentId, $buyerId, $orderId, $commissionAmount, $tier]);

        $logMsg .= "[Tier $tier: Parent $parentId earned " . $commissionAmount . "] ";
        $currentChildId = $parentId; // Move up the tree for next tier
    }

    log_debug($logMsg);
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
