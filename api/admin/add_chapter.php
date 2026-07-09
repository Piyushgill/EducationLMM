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

$courseId = isset($data['course_id']) ? (int)$data['course_id'] : 0;
$chapterNumber = isset($data['chapter_number']) ? (int)$data['chapter_number'] : 1;
$title = isset($data['title']) ? trim($data['title']) : '';
$resourceUrl = isset($data['resource_url']) ? trim($data['resource_url']) : '';

if (empty($courseId) || empty($title) || empty($resourceUrl)) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Required parameters (course_id, title, resource_url) are missing."
    ]);
    exit();
}

try {
    $stmt = $conn->prepare("INSERT INTO chapters (course_id, chapter_number, title, resource_url) VALUES (?, ?, ?, ?)");
    $stmt->execute([$courseId, $chapterNumber, $title, $resourceUrl]);
    $chapterId = $conn->lastInsertId();

    echo json_encode([
        "status" => "success",
        "message" => "Chapter/lesson uploaded successfully.",
        "chapter_id" => (int)$chapterId
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to upload chapter: " . $e->getMessage()
    ]);
}
?>
