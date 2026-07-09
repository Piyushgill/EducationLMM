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

try {
    // Fetch 10 most recent announcements
    $stmt = $conn->prepare("SELECT id, title, message, created_at FROM circulars ORDER BY created_at DESC LIMIT 10");
    $stmt->execute();
    $circulars = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($circulars as &$row) {
        $row['id'] = (int)$row['id'];
    }

    echo json_encode([
        "status" => "success",
        "data" => $circulars
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to fetch circulars: " . $e->getMessage()
    ]);
}
?>
