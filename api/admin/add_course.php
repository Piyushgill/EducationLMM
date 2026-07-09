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
$description = isset($data['description']) ? trim($data['description']) : '';
$classGrade = isset($data['class_grade']) ? trim($data['class_grade']) : '';
$subject = isset($data['subject']) ? trim($data['subject']) : '';

if (empty($title) || empty($description) || empty($classGrade) || empty($subject)) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Required parameters (title, description, class_grade, subject) are missing."
    ]);
    exit();
}

try {
    $stmt = $conn->prepare("INSERT INTO courses (title, description, class_grade, subject) VALUES (?, ?, ?, ?)");
    $stmt->execute([$title, $description, $classGrade, $subject]);
    $courseId = $conn->lastInsertId();

    echo json_encode([
        "status" => "success",
        "message" => "Course created successfully.",
        "course_id" => (int)$courseId
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to create course: " . $e->getMessage()
    ]);
}
?>
