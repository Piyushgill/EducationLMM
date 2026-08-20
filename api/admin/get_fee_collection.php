<?php
require_once '../db.php';

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

try {
    $stmt = $conn->prepare("
        SELECT 
            u.name AS student,
            s.name AS centre,
            sf.amount,
            DATE_FORMAT(sf.due_date, '%d %b %Y') AS due,
            sf.status
        FROM student_fees sf
        JOIN users u ON sf.student_id = u.id
        JOIN users s ON sf.school_id = s.id
        ORDER BY sf.created_at DESC
    ");
    $stmt->execute();
    $fees = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($fees as &$f) {
        $f['amount'] = "₹" . number_format($f['amount'], 0);
    }

    echo json_encode([
        "status" => "success",
        "data" => $fees
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to fetch fee collection: " . $e->getMessage()
    ]);
}
?>
