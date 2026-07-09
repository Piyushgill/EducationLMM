<?php
require_once 'db.php';

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

if (empty($userId)) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Required parameter (user_id) is missing."
    ]);
    exit();
}

try {
    // 1. Fetch entire recursive downline of this user
    $stmt = $conn->prepare("
        WITH RECURSIVE downline AS (
            SELECT child_id FROM user_relations WHERE parent_id = ?
            UNION ALL
            SELECT r.child_id FROM user_relations r
            INNER JOIN downline d ON r.parent_id = d.child_id
        )
        SELECT d.child_id AS id, ur.parent_id, u.name, u.email, u.phone, u.role, u.status 
        FROM downline d
        JOIN users u ON d.child_id = u.id
        JOIN user_relations ur ON u.id = ur.child_id
    ");
    $stmt->execute([$userId]);
    $network = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $networkSize = count($network);
    $activeSchools = 0;
    $totalStudents = 0;

    foreach ($network as &$node) {
        $node['id'] = (int)$node['id'];
        $node['parent_id'] = (int)$node['parent_id'];
        if ($node['role'] === 'School' && $node['status'] === 'Active') {
            $activeSchools++;
        }
        if ($node['role'] === 'Student') {
            $totalStudents++;
        }
    }

    // 2. Fetch commissions
    $stmtComm = $conn->prepare("SELECT SUM(amount) AS total_commission FROM commissions WHERE recipient_id = ?");
    $stmtComm->execute([$userId]);
    $commRow = $stmtComm->fetch();
    $totalCommission = isset($commRow['total_commission']) ? (float)$commRow['total_commission'] : 0.0;

    // 3. Fetch past practice test scores if they are a student
    $stmtTest = $conn->prepare("SELECT COUNT(*) AS test_count FROM practice_attempts WHERE student_id = ?");
    $stmtTest->execute([$userId]);
    $testRow = $stmtTest->fetch();
    $testCount = isset($testRow['test_count']) ? (int)$testRow['test_count'] : 0;

    echo json_encode([
        "status" => "success",
        "network_size" => $networkSize,
        "active_schools" => $activeSchools,
        "total_students" => $totalStudents,
        "total_commission" => $totalCommission,
        "test_count" => $testCount,
        "network_users" => $network
    ]);

} catch (Exception $e) {
    // Fallback if cPanel MySQL server does not support CTE (MariaDB < 10.2 / MySQL < 8.0)
    // Simply fetch direct children to prevent crashes.
    try {
        $stmtDirect = $conn->prepare("
            SELECT u.id, ur.parent_id, u.name, u.email, u.phone, u.role, u.status 
            FROM user_relations ur
            JOIN users u ON ur.child_id = u.id
            WHERE ur.parent_id = ?
        ");
        $stmtDirect->execute([$userId]);
        $network = $stmtDirect->fetchAll(PDO::FETCH_ASSOC);

        $networkSize = count($network);
        $activeSchools = 0;
        $totalStudents = 0;

        foreach ($network as &$node) {
            $node['id'] = (int)$node['id'];
            $node['parent_id'] = (int)$node['parent_id'];
            if ($node['role'] === 'School' && $node['status'] === 'Active') {
                $activeSchools++;
            }
            if ($node['role'] === 'Student') {
                $totalStudents++;
            }
        }

        $stmtComm = $conn->prepare("SELECT SUM(amount) AS total_commission FROM commissions WHERE recipient_id = ?");
        $stmtComm->execute([$userId]);
        $commRow = $stmtComm->fetch();
        $totalCommission = isset($commRow['total_commission']) ? (float)$commRow['total_commission'] : 0.0;

        echo json_encode([
            "status" => "success",
            "network_size" => $networkSize,
            "active_schools" => $activeSchools,
            "total_students" => $totalStudents,
            "total_commission" => $totalCommission,
            "test_count" => 0,
            "network_users" => $network
        ]);
    } catch (Exception $fallbackEx) {
        echo json_encode([
            "status" => "error",
            "message" => "Failed to load network: " . $fallbackEx->getMessage()
        ]);
    }
}
?>
