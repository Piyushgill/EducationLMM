<?php
require_once '../db.php';

$input = file_get_contents('php://input');
$data = json_decode($input, true);
$id = isset($data['id']) ? (int)$data['id'] : 0;

if (!$id) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Photo ID is required."]);
    exit();
}

try {
    $stmt = $conn->prepare("DELETE FROM gallery_photos WHERE id = ?");
    $stmt->execute([$id]);

    echo json_encode(["status" => "success", "message" => "Gallery photo deleted successfully."]);
} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
