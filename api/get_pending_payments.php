<?php
require_once 'db.php';

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
    echo json_encode(["status" => "error", "message" => "Invalid JSON payload."]);
    exit();
}

$schoolId = isset($data['school_id']) ? (int)$data['school_id'] : 0;

if (empty($schoolId)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required school_id parameter is missing."]);
    exit();
}

try {
    $stmt = $conn->prepare("
        SELECT 
            u.name AS student,
            sf.amount,
            DATE_FORMAT(sf.due_date, '%d %b %Y') AS due,
            sf.status
        FROM student_fees sf
        JOIN users u ON sf.student_id = u.id
        WHERE sf.school_id = ? AND sf.status != 'Paid'
        ORDER BY sf.due_date ASC
    ");
    $stmt->execute([$schoolId]);
    $payments = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "status" => "success",
        "data" => $payments
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to fetch pending payments: " . $e->getMessage()
    ]);
}
?>
