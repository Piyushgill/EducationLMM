<?php
require_once '../db.php';

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

try {
    $stmt = $conn->prepare("SELECT id, title, description, video_url, target_roles, created_at FROM videos ORDER BY created_at DESC");
    $stmt->execute();
    $videos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($videos as &$row) {
        $row['id'] = (int)$row['id'];
    }

    echo json_encode([
        "status" => "success",
        "data" => $videos
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to fetch videos: " . $e->getMessage()
    ]);
}
?>
