<?php
require_once '../db.php';

$input = file_get_contents('php://input');
$data = json_decode($input, true);

$title = isset($data['title']) ? trim($data['title']) : '';
$description = isset($data['description']) ? trim($data['description']) : '';
$thumbnailUrl = isset($data['thumbnail_url']) ? trim($data['thumbnail_url']) : '';
$demoVideoUrl = isset($data['demo_video_url']) ? trim($data['demo_video_url']) : '';
$fullDemoVideoUrl = isset($data['full_demo_video_url']) ? trim($data['full_demo_video_url']) : '';
$targetRoles = isset($data['target_roles']) ? $data['target_roles'] : 'All';

if (is_array($targetRoles)) {
    $targetRoles = implode(',', $targetRoles);
}

if (empty($title)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Title is required."]);
    exit();
}

try {
    $stmt = $conn->prepare("INSERT INTO programs_catalog (title, description, thumbnail_url, demo_video_url, full_demo_video_url, target_roles) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->execute([$title, $description, $thumbnailUrl, $demoVideoUrl, $fullDemoVideoUrl, $targetRoles]);

    echo json_encode([
        "status" => "success",
        "message" => "Program added successfully.",
        "id" => (int)$conn->lastInsertId()
    ]);
} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
