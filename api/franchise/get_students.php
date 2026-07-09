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

$franchiseId = isset($data['franchise_id']) ? (int)$data['franchise_id'] : 0;

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
            s.id AS school_id,
            s.name AS school_name
        FROM user_relations ur1
        JOIN user_relations ur2 ON ur1.child_id = ur2.parent_id
        JOIN users u ON ur2.child_id = u.id
        JOIN users s ON ur1.child_id = s.id
        WHERE ur1.parent_id = ? AND u.role = 'Student'
        ORDER BY u.created_at DESC
    ");
    $stmt->execute([$franchiseId]);
    $students = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($students as &$s) {
        $s['id'] = (int)$s['id'];
        $s['school_id'] = (int)$s['school_id'];
    }

    echo json_encode([
        "status" => "success",
        "data" => $students
    ]);

} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => "Failed to load students: " . $e->getMessage()]);
}
?>
