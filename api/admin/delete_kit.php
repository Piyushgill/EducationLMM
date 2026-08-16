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

$input = file_get_contents('php://input');
$data = json_decode($input, true);

if (!$data) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Invalid JSON payload."
    ]);
    exit();
}

$kitId = isset($data['kit_id']) ? (int)$data['kit_id'] : 0;

if ($kitId <= 0) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Required parameter (kit_id) is missing or invalid."
    ]);
    exit();
}

try {
    // Delete the kit from catalog
    $stmt = $conn->prepare("DELETE FROM kits WHERE id = ?");
    $stmt->execute([$kitId]);

    echo json_encode([
        "status" => "success",
        "message" => "Kit deleted successfully from catalog."
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Failed to delete kit: " . $e->getMessage()
    ]);
}
?>
