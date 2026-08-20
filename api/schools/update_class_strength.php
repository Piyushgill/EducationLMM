<?php
require_once '../db.php';

$input = file_get_contents('php://input');
$data = json_decode($input, true);
$schoolId = isset($data['school_id']) ? (int)$data['school_id'] : 0;
$className = isset($data['class_name']) ? trim($data['class_name']) : '';
$newStrength = isset($data['strength']) ? (int)$data['strength'] : -1;
$addQty = isset($data['add_qty']) ? (int)$data['add_qty'] : 0;

if (!$schoolId || empty($className)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "school_id and class_name are required."]);
    exit();
}

try {
    if ($newStrength >= 0) {
        // Set absolute strength
        $stmt = $conn->prepare("
            INSERT INTO school_classes (school_id, class_name, strength)
            VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE strength = VALUES(strength), updated_at = NOW()
        ");
        $stmt->execute([$schoolId, $className, $newStrength]);
    } elseif ($addQty > 0) {
        // Add to existing strength
        $stmt = $conn->prepare("
            INSERT INTO school_classes (school_id, class_name, strength)
            VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE strength = strength + VALUES(strength), updated_at = NOW()
        ");
        $stmt->execute([$schoolId, $className, $addQty]);
    } else {
        echo json_encode(["status" => "error", "message" => "Provide 'strength' (absolute) or 'add_qty' (increment)."]);
        exit();
    }

    // Return updated class record
    $fetchStmt = $conn->prepare("SELECT id, class_name, strength FROM school_classes WHERE school_id = ? AND class_name = ?");
    $fetchStmt->execute([$schoolId, $className]);
    $updated = $fetchStmt->fetch();

    echo json_encode([
        "status" => "success",
        "message" => "Class strength updated.",
        "class" => $updated
    ]);
} catch (Exception $e) {
    log_debug("update_class_strength error: " . $e->getMessage());
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
