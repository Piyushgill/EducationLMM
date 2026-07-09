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
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Invalid JSON payload."
    ]);
    exit();
}

$orderId = isset($data['order_id']) ? (int)$data['order_id'] : 0;
$status = isset($data['status']) ? trim($data['status']) : '';

if (empty($orderId) || empty($status)) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Required parameters (order_id, status) are missing."
    ]);
    exit();
}

try {
    $stmt = $conn->prepare("UPDATE kit_orders SET delivery_status = ? WHERE id = ?");
    $stmt->execute([$status, $orderId]);

    echo json_encode([
        "status" => "success",
        "message" => "Order delivery status successfully updated to $status."
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to update status: " . $e->getMessage()
    ]);
}
?>
