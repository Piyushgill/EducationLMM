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
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Invalid JSON payload."
    ]);
    exit();
}

$studentId = isset($data['student_id']) ? (int)$data['student_id'] : 0;
$level = isset($data['level']) ? (int)$data['level'] : 0;
$score = isset($data['score']) ? (int)$data['score'] : 0;

if (empty($studentId) || empty($level)) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Required parameters (student_id, level) are missing."
    ]);
    exit();
}

// 40 out of 50 is passing according to client documentation
$passed = ($score >= 40) ? 1 : 0;

try {
    $stmt = $conn->prepare("INSERT INTO practice_attempts (student_id, level, score, passed) VALUES (?, ?, ?, ?)");
    $stmt->execute([$studentId, $level, $score, $passed]);

    log_debug("Practice exam attempt logged: Student ID $studentId, Level $level, Score $score/50, Passed: " . ($passed ? "Yes" : "No"));

    echo json_encode([
        "status" => "success",
        "message" => "Score submitted successfully.",
        "passed" => (bool)$passed
    ]);

} catch (Exception $e) {
    log_debug("Failed to log practice attempt: " . $e->getMessage());
    echo json_encode([
        "status" => "error",
        "message" => "Failed to submit score: " . $e->getMessage()
    ]);
}
?>
