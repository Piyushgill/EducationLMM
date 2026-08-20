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

$name = isset($data['name']) ? trim($data['name']) : '';
$role = isset($data['role']) ? trim($data['role']) : '';
$message = isset($data['message']) ? trim($data['message']) : '';
$rating = isset($data['rating']) ? (int)$data['rating'] : 5;
$targetRoles = isset($data['target_roles']) ? $data['target_roles'] : ["All"];

if (empty($name) || empty($role) || empty($message)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required fields name, role, and message are missing."]);
    exit();
}

$rolesStr = is_array($targetRoles) ? implode(',', $targetRoles) : $targetRoles;

try {
    $stmt = $conn->prepare("INSERT INTO testimonials (name, role, message, rating, target_roles) VALUES (?, ?, ?, ?, ?)");
    $stmt->execute([$name, $role, $message, $rating, $rolesStr]);
    $testimonialId = $conn->lastInsertId();

    echo json_encode([
        "status" => "success",
        "message" => "Testimonial added successfully.",
        "testimonial_id" => (int)$testimonialId
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to add testimonial: " . $e->getMessage()
    ]);
}
?>
