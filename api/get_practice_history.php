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
    $studentId = isset($_GET['student_id']) ? (int)$_GET['student_id'] : 0;
} else {
    $studentId = isset($data['student_id']) ? (int)$data['student_id'] : 0;
}

if (empty($studentId)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required parameter student_id is missing."]);
    exit();
}

try {
    $stmt = $conn->prepare("
        SELECT id, level, score, passed, created_at 
        FROM practice_attempts 
        WHERE student_id = ? 
        ORDER BY created_at DESC
    ");
    $stmt->execute([$studentId]);
    $attempts = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($attempts as &$a) {
        $a['id'] = (int)$a['id'];
        $a['level'] = (int)$a['level'];
        $a['score'] = (int)$a['score'];
        $a['passed'] = (bool)$a['passed'];
    }

    echo json_encode([
        "status" => "success",
        "data" => $attempts
    ]);

} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => "Failed to fetch practice history: " . $e->getMessage()]);
}
?>
