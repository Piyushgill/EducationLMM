<?php
require_once '../db.php';

$input = file_get_contents('php://input');
$data = json_decode($input, true);

$agentId = isset($data['agent_id']) ? (int)$data['agent_id'] : 0;
$password = isset($data['password']) ? trim($data['password']) : '';

if (empty($agentId) || empty($password)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required parameters are missing."]);
    exit();
}

try {
    $hashedPassword = password_hash($password, PASSWORD_BCRYPT);
    $stmt = $conn->prepare("UPDATE users SET password = ? WHERE id = ? AND role = 'Agent'");
    $stmt->execute([$hashedPassword, $agentId]);

    echo json_encode([
        "status" => "success",
        "message" => "Agent password reset successfully."
    ]);

} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
