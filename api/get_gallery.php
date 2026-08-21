<?php
require_once 'db.php';

$role = isset($_GET['role']) ? trim($_GET['role']) : (isset($_POST['role']) ? trim($_POST['role']) : 'All');

try {
    $stmt = $conn->prepare("SELECT * FROM gallery_photos ORDER BY created_at DESC");
    $stmt->execute();
    $all = $stmt->fetchAll();

    $filtered = [];
    foreach ($all as $photo) {
        $targets = explode(',', $photo['target_roles']);
        if ($role === 'All' || in_array('All', $targets) || in_array($role, $targets)) {
            $filtered[] = $photo;
        }
    }

    echo json_encode([
        "status" => "success",
        "data" => $filtered
    ]);
} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
