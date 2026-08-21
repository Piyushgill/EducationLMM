<?php
require_once '../db.php';

try {
    $stmt = $conn->prepare("SELECT * FROM programs_catalog ORDER BY created_at DESC");
    $stmt->execute();
    $programs = $stmt->fetchAll();

    echo json_encode([
        "status" => "success",
        "data" => $programs
    ]);
} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
