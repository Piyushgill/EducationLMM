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
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Invalid JSON payload."]);
    exit();
}

$schoolId = isset($data['school_id']) ? (int)$data['school_id'] : 0;
$topic = isset($data['topic']) ? trim($data['topic']) : '';
$date = isset($data['date']) ? trim($data['date']) : null;
$time = isset($data['time']) ? trim($data['time']) : null;
$notes = isset($data['notes']) ? trim($data['notes']) : null;

if (empty($schoolId) || empty($topic)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required parameters (school_id, topic) are missing."]);
    exit();
}

try {
    $stmt = $conn->prepare("INSERT INTO training_requests (school_id, topic, requested_date, requested_time, notes, status) VALUES (?, ?, ?, ?, ?, 'Pending')");
    $stmt->execute([$schoolId, $topic, $date, $time, $notes]);
    $requestId = $conn->lastInsertId();

    echo json_encode([
        "status" => "success",
        "message" => "Training request submitted successfully.",
        "request_id" => (int)$requestId
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to request training: " . $e->getMessage()
    ]);
}
?>
