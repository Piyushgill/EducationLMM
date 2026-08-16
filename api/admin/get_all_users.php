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

try {
    // Fetch all users except Super Admin
    $stmt = $conn->prepare("
        SELECT id, name, email, phone, role, kyc_status, status, created_at 
        FROM users 
        WHERE role != 'Super Admin'
        ORDER BY created_at DESC
    ");
    $stmt->execute();
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($users as &$row) {
        $row['id'] = (int)$row['id'];
        $row['distributor_name'] = null;
        if ($row['role'] === 'Agent') {
            $curr = $row['id'];
            $loopLimit = 10; // prevent infinite loops
            while ($loopLimit-- > 0) {
                $stmtP = $conn->prepare("SELECT parent_id FROM user_relations WHERE child_id = ?");
                $stmtP->execute([$curr]);
                $rel = $stmtP->fetch();
                if (!$rel) break;

                $pId = (int)$rel['parent_id'];
                $stmtPRole = $conn->prepare("SELECT name, role FROM users WHERE id = ?");
                $stmtPRole->execute([$pId]);
                $pUser = $stmtPRole->fetch();
                if ($pUser) {
                    if ($pUser['role'] === 'Distributor') {
                        $row['distributor_name'] = $pUser['name'];
                        break;
                    }
                    $curr = $pId;
                } else {
                    break;
                }
            }
        }
    }

    echo json_encode([
        "status" => "success",
        "data" => $users
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to fetch users: " . $e->getMessage()
    ]);
}
?>
