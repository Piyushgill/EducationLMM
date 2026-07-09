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

$level = isset($data['level']) ? trim($data['level']) : '';
$price = isset($data['price']) ? (float)$data['price'] : 0.0;

if (empty($level) || $price <= 0) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Required parameters (level, price) are missing or invalid."
    ]);
    exit();
}

try {
    // Check if level already exists
    $stmtCheck = $conn->prepare("SELECT id FROM kits WHERE level = ?");
    $stmtCheck->execute([$level]);
    $existing = $stmtCheck->fetch();

    if ($existing) {
        // Update price
        $stmtUpdate = $conn->prepare("UPDATE kits SET price = ? WHERE level = ?");
        $stmtUpdate->execute([$price, $level]);
        echo json_encode([
            "status" => "success",
            "message" => "Kit level price updated successfully."
        ]);
    } else {
        // Insert new
        $stmtInsert = $conn->prepare("INSERT INTO kits (level, price) VALUES (?, ?)");
        $stmtInsert->execute([$level, $price]);
        echo json_encode([
            "status" => "success",
            "message" => "Kit level added successfully to catalog."
        ]);
    }

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to add/update kit type: " . $e->getMessage()
    ]);
}
?>
