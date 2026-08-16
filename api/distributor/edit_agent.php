<?php
require_once '../db.php';

$input = file_get_contents('php://input');
$data = json_decode($input, true);

$agentId = isset($data['agent_id']) ? (int)$data['agent_id'] : 0;
$name = isset($data['name']) ? trim($data['name']) : '';
$email = isset($data['email']) ? trim($data['email']) : '';
$phone = isset($data['phone']) ? trim($data['phone']) : '';
$address = isset($data['address']) ? trim($data['address']) : '';

if (empty($agentId) || empty($name) || empty($email) || empty($phone)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required parameters are missing."]);
    exit();
}

try {
    $conn->beginTransaction();

    // Check duplicate email/phone excluding current agent
    $stmtDup = $conn->prepare("SELECT id FROM users WHERE (email = ? OR phone = ?) AND id != ?");
    $stmtDup->execute([$email, $phone, $agentId]);
    if ($stmtDup->fetch()) {
        throw new Exception("Email or phone number is already registered by another user.");
    }

    $stmtUser = $conn->prepare("UPDATE users SET name = ?, email = ?, phone = ? WHERE id = ? AND role = 'Agent'");
    $stmtUser->execute([$name, $email, $phone, $agentId]);

    // Update KYC city/area for address
    $stmtKyc = $conn->prepare("
        INSERT INTO kyc_details (user_id, city, area) VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE city = VALUES(city), area = VALUES(area)
    ");
    $stmtKyc->execute([$agentId, $address, $address]);

    $conn->commit();

    echo json_encode([
        "status" => "success",
        "message" => "Agent details updated successfully."
    ]);

} catch (Exception $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
