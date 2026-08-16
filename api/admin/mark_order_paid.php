<?php
require_once '../db.php';

$input = file_get_contents('php://input');
$data = json_decode($input, true);

$orderId = isset($data['order_id']) ? (int)$data['order_id'] : 0;

if (empty($orderId)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required parameter (order_id) is missing."]);
    exit();
}

try {
    $conn->beginTransaction();

    // 1. Update payment status to Paid
    $stmt = $conn->prepare("UPDATE kit_orders SET payment_status = 'Paid' WHERE id = ?");
    $stmt->execute([$orderId]);

    // 2. Distribute commissions
    distributeCommission($conn, $orderId);

    $conn->commit();

    echo json_encode([
        "status" => "success",
        "message" => "Order #$orderId marked as Paid. MLM commissions calculated and distributed to wallets."
    ]);

} catch (Exception $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
