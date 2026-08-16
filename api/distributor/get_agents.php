<?php
require_once '../db.php';

$input = file_get_contents('php://input');
$data = json_decode($input, true);

$distributorId = isset($data['distributor_id']) ? (int)$data['distributor_id'] : 0;

if (empty($distributorId)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required parameter (distributor_id) is missing."]);
    exit();
}

try {
    // Traverse downline relations to build the straight line chain of agents
    $agents = [];
    $currentId = $distributorId;
    $levelNum = 2; // Distributor is level 1, agents are levels 2 to 8

    while ($levelNum <= 8) {
        $stmt = $conn->prepare("
            SELECT u.id, u.name, u.email, u.phone, u.kyc_status, u.status, u.created_at
            FROM user_relations ur
            JOIN users u ON ur.child_id = u.id
            WHERE ur.parent_id = ? AND u.role = 'Agent'
        ");
        $stmt->execute([$currentId]);
        $agent = $stmt->fetch();
        
        if (!$agent) {
            break;
        }

        $agent['level'] = $levelNum;
        $agents[] = $agent;
        $currentId = (int)$agent['id'];
        $levelNum++;
    }

    echo json_encode([
        "status" => "success",
        "agents" => $agents
    ]);

} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
