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

$title = isset($data['title']) ? trim($data['title']) : '';
$description = isset($data['description']) ? trim($data['description']) : '';
$videoUrl = isset($data['video_url']) ? trim($data['video_url']) : '';
$targetRoles = isset($data['target_roles']) ? $data['target_roles'] : ["All"];

if (empty($title) || empty($videoUrl)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required fields title and video_url are missing."]);
    exit();
}

$rolesStr = is_array($targetRoles) ? implode(',', $targetRoles) : $targetRoles;

try {
    $stmt = $conn->prepare("INSERT INTO videos (title, description, video_url, target_roles) VALUES (?, ?, ?, ?)");
    $stmt->execute([$title, $description, $videoUrl, $rolesStr]);
    $videoId = $conn->lastInsertId();

    echo json_encode([
        "status" => "success",
        "message" => "Video added successfully.",
        "video_id" => (int)$videoId
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to add video: " . $e->getMessage()
    ]);
}
?>
