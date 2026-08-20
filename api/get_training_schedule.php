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
    $schoolId = isset($_GET['school_id']) ? (int)$_GET['school_id'] : 0;
} else {
    $schoolId = isset($data['school_id']) ? (int)$data['school_id'] : 0;
}

if (empty($schoolId)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required school_id parameter is missing."]);
    exit();
}

try {
    $stmt = $conn->prepare("
        SELECT id, topic, requested_date, requested_time, scheduled_date, scheduled_time, meeting_info, notes, status, created_at 
        FROM training_requests 
        WHERE school_id = ? 
        ORDER BY created_at DESC
    ");
    $stmt->execute([$schoolId]);
    $trainings = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($trainings as &$t) {
        $t['id'] = (int)$t['id'];
    }

    echo json_encode([
        "status" => "success",
        "data" => $trainings
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to fetch training schedule: " . $e->getMessage()
    ]);
}
?>
