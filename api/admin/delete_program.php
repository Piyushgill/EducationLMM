<?php
require_once '../db.php';

$input = file_get_contents('php://input');
$data = json_decode($input, true);
$id = isset($data['id']) ? (int)$data['id'] : 0;

if (!$id) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Program ID is required."]);
    exit();
}

try {
    $stmt = $conn->prepare("DELETE FROM programs_catalog WHERE id = ?");
    $stmt->execute([$id]);

    echo json_encode(["status" => "success", "message" => "Program deleted successfully."]);
} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
