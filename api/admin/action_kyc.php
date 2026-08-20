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
$action = isset($data['action']) ? trim($data['action']) : ''; // 'Approved' or 'Rejected'
$reason = isset($data['reason']) ? trim($data['reason']) : null;

if (empty($userId) || empty($action) || !in_array($action, ['Approved', 'Rejected'])) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Required parameters (user_id, action) are missing or invalid."
    ]);
    exit();
}

try {
    $conn->beginTransaction();

    // Verify if user exists
    $stmt = $conn->prepare("SELECT id, role FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();

    if (!$user) {
        throw new Exception("User not found.");
    }
    if ($user['role'] === 'Super Admin') {
        throw new Exception("Cannot perform KYC operations on Super Admin accounts.");
    }

    // Update kyc_status in users table
    $stmt = $conn->prepare("UPDATE users SET kyc_status = ? WHERE id = ?");
    $stmt->execute([$action, $userId]);

    // Update rejection reason in kyc_details table (create row if not yet exists)
    $rejectionReason = ($action === 'Rejected') ? $reason : null;
    $stmt = $conn->prepare("INSERT INTO kyc_details (user_id, rejection_reason) VALUES (?, ?) ON DUPLICATE KEY UPDATE rejection_reason = ?");
    $stmt->execute([$userId, $rejectionReason, $rejectionReason]);

    $conn->commit();
    log_debug("KYC successfully $action for User ID: $userId");

    echo json_encode([
        "status" => "success",
        "message" => "User KYC status successfully updated to $action."
    ]);

} catch (Exception $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    log_debug("KYC Action failed for User ID $userId: " . $e->getMessage());
    echo json_encode([
        "status" => "error",
        "message" => "Failed to update KYC status: " . $e->getMessage()
    ]);
}
?>
