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

if (!$data) {
    $franchiseId = isset($_GET['franchise_id']) ? (int)$_GET['franchise_id'] : 0;
} else {
    $franchiseId = isset($data['franchise_id']) ? (int)$data['franchise_id'] : 0;
}

if (empty($franchiseId)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required parameter franchise_id is missing."]);
    exit();
}

try {
    $stmt = $conn->prepare("
        SELECT 
            u.id, 
            u.name, 
            u.email, 
            u.phone, 
            u.status,
            kd.principal_name,
            kd.school_city AS center_city
        FROM user_relations ur
        JOIN users u ON ur.child_id = u.id
        LEFT JOIN kyc_details kd ON u.id = kd.user_id
        WHERE ur.parent_id = ? AND u.role = 'School'
    ");
    $stmt->execute([$franchiseId]);
    $centers = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($centers as &$c) {
        $c['id'] = (int)$c['id'];
        
        $stmtStud = $conn->prepare("
            SELECT COUNT(ur.child_id) AS count
            FROM user_relations ur
            JOIN users u ON ur.child_id = u.id
            WHERE ur.parent_id = ? AND u.role = 'Student'
        ");
        $stmtStud->execute([$c['id']]);
        $stud = $stmtStud->fetch();
        $c['students'] = (int)($stud['count'] ?? 0);

        $stmtBatches = $conn->prepare("
            SELECT COUNT(id) AS count FROM student_batches WHERE creator_id = ?
        ");
        $stmtBatches->execute([$c['id']]);
        $batch = $stmtBatches->fetch();
        $c['batches'] = (int)($batch['count'] ?? 0);
    }

    echo json_encode([
        "status" => "success",
        "data" => $centers
    ]);

} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => "Failed to fetch centers: " . $e->getMessage()]);
}
?>
