<?php
require_once '../db.php';

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
    $buyerId = isset($_GET['buyer_id']) ? (int)$_GET['buyer_id'] : 0;
} else {
    $buyerId = isset($data['buyer_id']) ? (int)$data['buyer_id'] : 0;
}

if (empty($buyerId)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required parameter buyer_id is missing."]);
    exit();
}

try {
    $stmt = $conn->prepare("
        SELECT 
            ko.id AS order_id,
            ko.total_amount,
            ko.payment_status,
            ko.delivery_status,
            ko.created_at,
            koi.quantity,
            koi.price_at_purchase,
            k.level AS kit_level
        FROM kit_orders ko
        LEFT JOIN kit_order_items koi ON ko.id = koi.order_id
        LEFT JOIN kits k ON koi.kit_id = k.id
        WHERE ko.buyer_id = ?
        ORDER BY ko.created_at DESC
    ");
    $stmt->execute([$buyerId]);
    $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($orders as &$o) {
        $o['order_id'] = (int)$o['order_id'];
        $o['total_amount'] = (float)$o['total_amount'];
        $o['quantity'] = (int)$o['quantity'];
        $o['price_at_purchase'] = (float)$o['price_at_purchase'];
    }

    echo json_encode([
        "status" => "success",
        "data" => $orders
    ]);

} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => "Failed to fetch orders: " . $e->getMessage()]);
}
?>
