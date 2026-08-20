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

$requestId = isset($data['request_id']) ? (int)$data['request_id'] : 0;
$scheduledDate = isset($data['scheduled_date']) ? trim($data['scheduled_date']) : '';
$scheduledTime = isset($data['scheduled_time']) ? trim($data['scheduled_time']) : '';
$meetingInfo = isset($data['meeting_info']) ? trim($data['meeting_info']) : '';

if (empty($requestId) || empty($scheduledDate)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required parameters (request_id, scheduled_date) are missing."]);
    exit();
}

try {
    $stmt = $conn->prepare("UPDATE training_requests SET scheduled_date = ?, scheduled_time = ?, meeting_info = ?, status = 'Scheduled' WHERE id = ?");
    $stmt->execute([$scheduledDate, $scheduledTime, $meetingInfo, $requestId]);

    echo json_encode([
        "status" => "success",
        "message" => "Training scheduled successfully."
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to schedule training: " . $e->getMessage()
    ]);
}
?>
