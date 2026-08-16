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

$userId = isset($data['user_id']) ? (int)$data['user_id'] : 0;
$bankName = isset($data['bank_name']) ? trim($data['bank_name']) : '';
$accountNumber = isset($data['account_number']) ? trim($data['account_number']) : '';
$ifscCode = isset($data['ifsc_code']) ? trim($data['ifsc_code']) : '';
$holderName = isset($data['account_holder_name']) ? trim($data['account_holder_name']) : '';

if (empty($userId)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required parameter user_id is missing."]);
    exit();
}

try {
    $stmt = $conn->prepare("
        UPDATE users 
        SET bank_name = ?, account_number = ?, ifsc_code = ?, account_holder_name = ?
        WHERE id = ?
    ");
    $stmt->execute([$bankName, $accountNumber, $ifscCode, $holderName, $userId]);

    echo json_encode([
        "status" => "success",
        "message" => "Bank details updated successfully."
    ]);
} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
