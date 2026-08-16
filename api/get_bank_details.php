<?php
require_once 'db.php';

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
        SELECT bank_name, account_number, ifsc_code, account_holder_name 
        FROM users 
        WHERE id = ?
    ");
    $stmt->execute([$userId]);
    $details = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$details) {
        echo json_encode([
            "status" => "success",
            "bank_name" => "",
            "account_number" => "",
            "ifsc_code" => "",
            "account_holder_name" => ""
        ]);
    } else {
        echo json_encode([
            "status" => "success",
            "bank_name" => $details['bank_name'] ?? "",
            "account_number" => $details['account_number'] ?? "",
            "ifsc_code" => $details['ifsc_code'] ?? "",
            "account_holder_name" => $details['account_holder_name'] ?? ""
        ]);
    }
} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
