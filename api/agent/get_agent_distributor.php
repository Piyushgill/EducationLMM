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

$agentId = isset($data['agent_id']) ? (int)$data['agent_id'] : 0;

if (empty($agentId)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required parameter (agent_id) is missing."]);
    exit();
}

try {
    $curr = $agentId;
    $distributor = null;
    
    while (true) {
        $stmt = $conn->prepare("SELECT parent_id FROM user_relations WHERE child_id = ?");
        $stmt->execute([$curr]);
        $row = $stmt->fetch();
        if (!$row) {
            break;
        }
        
        $pId = (int)$row['parent_id'];
        $stmtP = $conn->prepare("SELECT id, name, email, phone, role FROM users WHERE id = ?");
        $stmtP->execute([$pId]);
        $parent = $stmtP->fetch();
        
        if ($parent) {
            if ($parent['role'] === 'Distributor') {
                $distributor = $parent;
                break;
            }
            $curr = $pId;
        } else {
            break;
        }
    }
    
    if ($distributor) {
        echo json_encode([
            "status" => "success",
            "distributor" => [
                "id" => (int)$distributor['id'],
                "name" => $distributor['name'],
                "email" => $distributor['email'],
                "phone" => $distributor['phone']
            ]
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "No parent distributor found for this agent."
        ]);
    }
} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
