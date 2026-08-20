<?php
require_once '../db.php';

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

try {
    $stmt = $conn->prepare("SELECT id, name, role, message, rating, target_roles, created_at FROM testimonials ORDER BY created_at DESC");
    $stmt->execute();
    $testimonials = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($testimonials as &$row) {
        $row['id'] = (int)$row['id'];
        $row['rating'] = (int)$row['rating'];
    }

    echo json_encode([
        "status" => "success",
        "data" => $testimonials
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to fetch testimonials: " . $e->getMessage()
    ]);
}
?>
