<?php
require_once '../db.php';

$input = file_get_contents('php://input');
$data = json_decode($input, true);

$title = isset($data['title']) ? trim($data['title']) : '';
$imageUrl = isset($data['image_url']) ? trim($data['image_url']) : '';
$targetRoles = isset($data['target_roles']) ? $data['target_roles'] : 'All';

if (is_array($targetRoles)) {
    $targetRoles = implode(',', $targetRoles);
}

if (empty($title) || empty($imageUrl)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Title and Image URL are required."]);
    exit();
}

try {
    $stmt = $conn->prepare("INSERT INTO gallery_photos (title, image_url, target_roles) VALUES (?, ?, ?)");
    $stmt->execute([$title, $imageUrl, $targetRoles]);

    echo json_encode([
        "status" => "success",
        "message" => "Gallery photo added successfully.",
        "id" => (int)$conn->lastInsertId()
    ]);
} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
