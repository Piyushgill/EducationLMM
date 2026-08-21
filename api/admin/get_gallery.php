<?php
require_once '../db.php';

try {
    $stmt = $conn->prepare("SELECT * FROM gallery_photos ORDER BY created_at DESC");
    $stmt->execute();
    $photos = $stmt->fetchAll();

    echo json_encode([
        "status" => "success",
        "data" => $photos
    ]);
} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
