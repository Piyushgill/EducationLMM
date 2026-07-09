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
    $userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 0;
} else {
    $userId = isset($data['user_id']) ? (int)$data['user_id'] : 0;
}

if (empty($userId)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required parameter user_id is missing."]);
    exit();
}

try {
    $stmt = $conn->prepare("
        SELECT 
            c.id,
            c.amount,
            c.tier_level,
            c.status,
            c.created_at,
            u.name AS trigger_name,
            u.role AS trigger_role
        FROM commissions c
        JOIN users u ON c.trigger_user_id = u.id
        WHERE c.recipient_id = ?
        ORDER BY c.created_at DESC
    ");
    $stmt->execute([$userId]);
    $commissions = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($commissions as &$c) {
        $c['id'] = (int)$c['id'];
        $c['amount'] = (float)$c['amount'];
        $c['tier_level'] = (int)$c['tier_level'];
    }

    echo json_encode([
        "status" => "success",
        "data" => $commissions
    ]);

} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => "Failed to fetch commissions: " . $e->getMessage()]);
}
?>
