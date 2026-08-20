<?php
require_once '../db.php';

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

try {
    $stmt = $conn->prepare("SELECT id, question, answer, target_roles, created_at FROM faqs ORDER BY created_at DESC");
    $stmt->execute();
    $faqs = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($faqs as &$row) {
        $row['id'] = (int)$row['id'];
    }

    echo json_encode([
        "status" => "success",
        "data" => $faqs
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to fetch FAQs: " . $e->getMessage()
    ]);
}
?>
