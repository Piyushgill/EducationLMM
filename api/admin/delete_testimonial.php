<?php
require_once '../db.php';

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
    echo json_encode(["status" => "error", "message" => "Invalid JSON payload."]);
    exit();
}

$testimonialId = isset($data['testimonial_id']) ? (int)$data['testimonial_id'] : 0;

if (empty($testimonialId)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required field testimonial_id is missing."]);
    exit();
}

try {
    $stmt = $conn->prepare("DELETE FROM testimonials WHERE id = ?");
    $stmt->execute([$testimonialId]);

    echo json_encode([
        "status" => "success",
        "message" => "Testimonial deleted successfully."
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to delete testimonial: " . $e->getMessage()
    ]);
}
?>
