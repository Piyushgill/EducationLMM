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

try {
    // Fetch all courses
    $stmt = $conn->prepare("SELECT id, title, description, class_grade, subject, created_at FROM courses ORDER BY created_at DESC");
    $stmt->execute();
    $courses = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($courses as &$course) {
        $course['id'] = (int)$course['id'];
        
        // Fetch chapters for this course
        $stmtCh = $conn->prepare("SELECT id, chapter_number, title, resource_url, created_at FROM chapters WHERE course_id = ? ORDER BY chapter_number ASC");
        $stmtCh->execute([$course['id']]);
        $chapters = $stmtCh->fetchAll(PDO::FETCH_ASSOC);
        
        foreach ($chapters as &$ch) {
            $ch['id'] = (int)$ch['id'];
            $ch['chapter_number'] = (int)$ch['chapter_number'];
        }
        $course['chapters'] = $chapters;
    }

    echo json_encode([
        "status" => "success",
        "data" => $courses
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to fetch courses: " . $e->getMessage()
    ]);
}
?>
