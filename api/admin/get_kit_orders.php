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

try {
    // Fetch orders with buyer user details and items ordered
    $stmt = $conn->prepare("
        SELECT 
            ko.id AS order_id,
            ko.buyer_id,
            u.name AS buyer_name,
            u.role AS buyer_role,
            u.phone AS buyer_phone,
            ko.total_amount,
            ko.payment_status,
            ko.delivery_status,
            ko.created_at,
            koi.quantity,
            koi.price_at_purchase,
            k.level AS kit_level,
            ko.order_type,
            ko.school_name,
            ko.school_address,
            ko.contact_person,
            ko.mobile_number
        FROM kit_orders ko
        JOIN users u ON ko.buyer_id = u.id
        LEFT JOIN kit_order_items koi ON ko.id = koi.order_id
        LEFT JOIN kits k ON koi.kit_id = k.id
        ORDER BY ko.created_at DESC
    ");
    $stmt->execute();
    $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($orders as &$o) {
        $o['order_id'] = (int)$o['order_id'];
        $o['buyer_id'] = (int)$o['buyer_id'];
        $o['total_amount'] = (float)$o['total_amount'];
        $o['quantity'] = (int)$o['quantity'];
        $o['price_at_purchase'] = (float)$o['price_at_purchase'];
    }

    echo json_encode([
        "status" => "success",
        "data" => $orders
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to fetch orders: " . $e->getMessage()
    ]);
}
?>
