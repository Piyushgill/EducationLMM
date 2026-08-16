<?php
require_once '../db.php';

$input = file_get_contents('php://input');
$data = json_decode($input, true);

$agentId = isset($data['agent_id']) ? (int)$data['agent_id'] : 0;
$status = isset($data['status']) ? trim($data['status']) : '';

if (empty($agentId) || !in_array($status, ['Active', 'Suspended'])) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required parameters (agent_id, status) are missing or invalid."]);
    exit();
}

try {
    $stmt = $conn->prepare("UPDATE users SET status = ? WHERE id = ? AND role = 'Agent'");
    $stmt->execute([$status, $agentId]);

    echo json_encode([
        "status" => "success",
        "message" => "Agent status updated to $status successfully."
    ]);

} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
