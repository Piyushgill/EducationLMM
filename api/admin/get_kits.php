<?php
require_once '../db.php';

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
    $stmt = $conn->prepare("SELECT id, level, price, created_at FROM kits ORDER BY level ASC");
    $stmt->execute();
    $kits = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($kits as &$k) {
        $k['id'] = (int)$k['id'];
        $k['price'] = (float)$k['price'];
    }

    echo json_encode([
        "status" => "success",
        "data" => $kits
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to fetch kits: " . $e->getMessage()
    ]);
}
?>
