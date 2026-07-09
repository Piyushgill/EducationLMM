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

$userId = isset($data['user_id']) ? (int)$data['user_id'] : 0;
$status = isset($data['status']) ? trim($data['status']) : ''; // 'Active' or 'Suspended'

if (empty($userId) || empty($status) || !in_array($status, ['Active', 'Suspended'])) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Required parameters (user_id, status) are missing or invalid."
    ]);
    exit();
}

try {
    $stmt = $conn->prepare("SELECT id, role FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();

    if (!$user) {
        throw new Exception("User not found.");
    }
    if ($user['role'] === 'Super Admin') {
        throw new Exception("Cannot change status of Super Admin accounts.");
    }

    $stmt = $conn->prepare("UPDATE users SET status = ? WHERE id = ?");
    $stmt->execute([$status, $userId]);

    log_debug("User ID: $userId status updated to $status");

    echo json_encode([
        "status" => "success",
        "message" => "User status successfully updated to $status."
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to update user status: " . $e->getMessage()
    ]);
}
?>
