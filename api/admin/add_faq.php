<?php
require_once '../db.php';

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
    echo json_encode(["status" => "error", "message" => "Invalid JSON payload."]);
    exit();
}

$question = isset($data['question']) ? trim($data['question']) : '';
$answer = isset($data['answer']) ? trim($data['answer']) : '';
$targetRoles = isset($data['target_roles']) ? $data['target_roles'] : ["All"];

if (empty($question) || empty($answer)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required fields question and answer are missing."]);
    exit();
}

$rolesStr = is_array($targetRoles) ? implode(',', $targetRoles) : $targetRoles;

try {
    $stmt = $conn->prepare("INSERT INTO faqs (question, answer, target_roles) VALUES (?, ?, ?)");
    $stmt->execute([$question, $answer, $rolesStr]);
    $faqId = $conn->lastInsertId();

    echo json_encode([
        "status" => "success",
        "message" => "FAQ added successfully.",
        "faq_id" => (int)$faqId
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to add FAQ: " . $e->getMessage()
    ]);
}
?>
