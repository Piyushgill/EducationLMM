<?php
require_once '../db.php';

$input = file_get_contents('php://input');
$data = json_decode($input, true);

$distributorId = isset($data['distributor_id']) ? (int)$data['distributor_id'] : 0;
$name = isset($data['name']) ? trim($data['name']) : '';
$email = isset($data['email']) ? trim($data['email']) : '';
$phone = isset($data['phone']) ? trim($data['phone']) : '';
$password = isset($data['password']) ? trim($data['password']) : '';
$address = isset($data['address']) ? trim($data['address']) : '';

if (empty($distributorId) || empty($name) || empty($email) || empty($phone) || empty($password)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required parameters are missing."]);
    exit();
}

if (strlen($phone) !== 10 || !ctype_digit($phone)) {
    echo json_encode(["status" => "error", "message" => "Mobile number must be exactly 10 digits."]);
    exit();
}

try {
    $conn->beginTransaction();

    // 1. Traverse existing chain to count agents and find last node
    $currentId = $distributorId;
    $agentCount = 0;
    while ($agentCount < 7) {
        $stmtCheck = $conn->prepare("
            SELECT child_id FROM user_relations ur
            JOIN users u ON ur.child_id = u.id
            WHERE ur.parent_id = ? AND u.role = 'Agent'
        ");
        $stmtCheck->execute([$currentId]);
        $relation = $stmtCheck->fetch();
        if (!$relation) {
            break;
        }
        $currentId = (int)$relation['child_id'];
        $agentCount++;
    }

    if ($agentCount >= 7) {
        throw new Exception("Maximum limit of 7 agents reached under this distributor hierarchy.");
    }

    // 2. Check if email/phone exists
    $stmtDup = $conn->prepare("SELECT id FROM users WHERE email = ? OR phone = ?");
    $stmtDup->execute([$email, $phone]);
    if ($stmtDup->fetch()) {
        throw new Exception("Email address or phone number is already registered.");
    }

    // 3. Create Agent User
    $hashedPassword = password_hash($password, PASSWORD_BCRYPT);
    $stmtUser = $conn->prepare("
        INSERT INTO users (name, email, phone, password, role, kyc_status, status)
        VALUES (?, ?, ?, ?, 'Agent', 'Approved', 'Active')
    ");
    $stmtUser->execute([$name, $email, $phone, $hashedPassword]);
    $newAgentId = (int)$conn->lastInsertId();

    // Create a default wallet for the new agent
    $stmtWallet = $conn->prepare("INSERT INTO wallets (user_id, balance) VALUES (?, 0.00)");
    $stmtWallet->execute([$newAgentId]);

    // Create KYC details placeholder for the agent if needed
    $stmtKyc = $conn->prepare("INSERT INTO kyc_details (user_id, city, area) VALUES (?, ?, ?)");
    $stmtKyc->execute([$newAgentId, $address, $address]);

    // 4. Create Relation mapping child to last agent or distributor
    $stmtRelation = $conn->prepare("INSERT INTO user_relations (parent_id, child_id) VALUES (?, ?)");
    $stmtRelation->execute([$currentId, $newAgentId]);

    $conn->commit();

    echo json_encode([
        "status" => "success",
        "message" => "Agent created successfully at Level " . ($agentCount + 2) . ".",
        "agent_id" => $newAgentId
    ]);

} catch (Exception $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
