<?php
require_once '../db.php';

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

try {
    $stmt = $conn->prepare("
        SELECT tr.id, tr.school_id, u.name AS school_name, tr.topic, 
               tr.requested_date, tr.requested_time, tr.notes,
               tr.scheduled_date, tr.scheduled_time, tr.meeting_info,
               tr.status, tr.created_at
        FROM training_requests tr
        JOIN users u ON tr.school_id = u.id
        ORDER BY FIELD(tr.status, 'Pending', 'Scheduled', 'Completed', 'Cancelled'), tr.created_at DESC
    ");
    $stmt->execute();
    $requests = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($requests as &$r) {
        $r['id'] = (int)$r['id'];
        $r['school_id'] = (int)$r['school_id'];
    }

    echo json_encode([
        "status" => "success",
        "data" => $requests
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to fetch training requests: " . $e->getMessage()
    ]);
}
?>
