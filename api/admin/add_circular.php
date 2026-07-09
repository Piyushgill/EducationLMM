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

$title = isset($data['title']) ? trim($data['title']) : '';
$message = isset($data['message']) ? trim($data['message']) : '';

if (empty($title) || empty($message)) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Required parameters (title, message) are missing."
    ]);
    exit();
}

try {
    $stmt = $conn->prepare("INSERT INTO circulars (title, message) VALUES (?, ?)");
    $stmt->execute([$title, $message]);
    $circularId = $conn->lastInsertId();

    echo json_encode([
        "status" => "success",
        "message" => "Circular announcement published successfully.",
        "circular_id" => (int)$circularId
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to publish circular: " . $e->getMessage()
    ]);
}
?>
