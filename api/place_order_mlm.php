<?php
require_once 'db.php';

$input = file_get_contents('php://input');
$data = json_decode($input, true);

$buyerId = isset($data['buyer_id']) ? (int)$data['buyer_id'] : 0;
$level = isset($data['level']) ? trim($data['level']) : 'Level 1';
$quantity = isset($data['quantity']) ? (int)$data['quantity'] : 1;
$schoolName = isset($data['school_name']) ? trim($data['school_name']) : '';
$schoolAddress = isset($data['school_address']) ? trim($data['school_address']) : '';
$contactPerson = isset($data['contact_person']) ? trim($data['contact_person']) : '';
$mobileNumber = isset($data['mobile_number']) ? trim($data['mobile_number']) : '';

if (empty($buyerId) || $quantity <= 0 || empty($schoolName)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required parameters (buyer_id, school_name, quantity) are missing or invalid."]);
    exit();
}

try {
    $conn->beginTransaction();

    // Find buyer role
    $stmtUser = $conn->prepare("SELECT name, role FROM users WHERE id = ?");
    $stmtUser->execute([$buyerId]);
    $buyer = $stmtUser->fetch();
    if (!$buyer) {
        throw new Exception("Buyer user not found.");
    }
    
    // Find distributor
    $distributorId = null;
    $agentId = null;

    if ($buyer['role'] === 'Agent') {
        $agentId = $buyerId;
        // Traverse parent chain to find Level 1 Distributor
        $curr = $buyerId;
        while (true) {
            $stmtP = $conn->prepare("SELECT parent_id FROM user_relations WHERE child_id = ?");
            $stmtP->execute([$curr]);
            $rel = $stmtP->fetch();
            if (!$rel) break;
            
            $pId = (int)$rel['parent_id'];
            $stmtPRole = $conn->prepare("SELECT role FROM users WHERE id = ?");
            $stmtPRole->execute([$pId]);
            $pUser = $stmtPRole->fetch();
            if ($pUser && $pUser['role'] === 'Distributor') {
                $distributorId = $pId;
                break;
            }
            $curr = $pId;
        }
    } else if ($buyer['role'] === 'Distributor') {
        $distributorId = $buyerId;
    }

    // Resolve kit ID and price
    $stmtKit = $conn->prepare("SELECT id, price FROM kits WHERE level = ?");
    $stmtKit->execute([$level]);
    $kit = $stmtKit->fetch();
    
    $kitId = 1;
    $unitPrice = 1500.00;
    if ($kit) {
        $kitId = (int)$kit['id'];
        $unitPrice = (float)$kit['price'];
    } else {
        $stmtSeed = $conn->prepare("INSERT INTO kits (level, price) VALUES (?, ?)");
        $stmtSeed->execute([$level, $unitPrice]);
        $kitId = (int)$conn->lastInsertId();
    }

    $totalAmount = $unitPrice * $quantity;

    // Create Order (defaults to Paid payment and Pending delivery)
    $stmtOrder = $conn->prepare("
        INSERT INTO kit_orders (buyer_id, total_amount, payment_status, delivery_status, agent_id, distributor_id, school_name, school_address, contact_person, mobile_number, order_type)
        VALUES (?, ?, 'Paid', 'Pending', ?, ?, ?, ?, ?, ?, 'MLM')
    ");
    $stmtOrder->execute([$buyerId, $totalAmount, $agentId, $distributorId, $schoolName, $schoolAddress, $contactPerson, $mobileNumber]);
    $orderId = (int)$conn->lastInsertId();

    // Insert order item
    $stmtItem = $conn->prepare("INSERT INTO kit_order_items (order_id, kit_id, quantity, price_at_purchase) VALUES (?, ?, ?, ?)");
    $stmtItem->execute([$orderId, $kitId, $quantity, $unitPrice]);

    // Distribute commission immediately (no admin approval needed)
    distributeCommission($conn, $orderId);

    // Activate buyer's MLM status
    $stmtAct = $conn->prepare("UPDATE users SET mlm_active = 1 WHERE id = ?");
    $stmtAct->execute([$buyerId]);

    $conn->commit();

    echo json_encode([
        "status" => "success",
        "message" => "MLM Order placed & commission distributed successfully.",
        "order_id" => $orderId,
        "total_amount" => $totalAmount
    ]);

} catch (Exception $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
