<?php
require_once 'db.php';

$input = file_get_contents('php://input');
$data = json_decode($input, true);

$buyerId = isset($data['buyer_id']) ? (int)$data['buyer_id'] : 0;
$adminView = isset($data['admin_view']) && $data['admin_view'] === true;

try {
    if ($adminView) {
        $stmt = $conn->prepare("
            SELECT ko.id, ko.buyer_id, u.name AS buyer_name, u.role AS buyer_role,
                   ko.total_amount, ko.payment_status, ko.delivery_status, ko.order_type,
                   ko.program, ko.school_name, ko.created_at,
                   COALESCE(SUM(koi.quantity), 0) AS total_quantity
            FROM kit_orders ko
            LEFT JOIN users u ON u.id = ko.buyer_id
            LEFT JOIN kit_order_items koi ON koi.order_id = ko.id
            GROUP BY ko.id
            ORDER BY ko.created_at DESC
        ");
        $stmt->execute();
    } elseif ($buyerId > 0) {
        $stmt = $conn->prepare("
            SELECT ko.id, ko.buyer_id, ko.total_amount, ko.payment_status,
                   ko.delivery_status, ko.order_type, ko.program, ko.school_name,
                   ko.created_at,
                   COALESCE(SUM(koi.quantity), 0) AS total_quantity,
                   COALESCE((SELECT SUM(c.amount) FROM commissions c WHERE c.order_id = ko.id AND c.recipient_id = ko.buyer_id), 0) AS earned_commission
            FROM kit_orders ko
            LEFT JOIN kit_order_items koi ON koi.order_id = ko.id
            WHERE ko.buyer_id = ?
            GROUP BY ko.id
            ORDER BY ko.created_at DESC
        ");
        $stmt->execute([$buyerId]);
    } else {
        http_response_code(400);
        echo json_encode(["status" => "error", "message" => "buyer_id is required."]);
        exit();
    }

    $orders = $stmt->fetchAll();

    // Group by program for "Programs Running" view
    $grouped = [];
    foreach ($orders as $order) {
        $programName = !empty($order['program']) ? $order['program'] : 'General Kit';
        if (!isset($grouped[$programName])) {
            $grouped[$programName] = ['program' => $programName, 'total_quantity' => 0, 'orders' => []];
        }
        $grouped[$programName]['total_quantity'] += (int)$order['total_quantity'];
        $grouped[$programName]['orders'][] = $order;
    }

    echo json_encode([
        "status" => "success",
        "data" => array_values($grouped),
        "orders" => $orders,
        "total_orders" => count($orders)
    ]);

} catch (Exception $e) {
    log_debug("get_kit_orders error: " . $e->getMessage());
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
