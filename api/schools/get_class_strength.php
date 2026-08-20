<?php
require_once '../db.php';

$input = file_get_contents('php://input');
$data = json_decode($input, true);
$schoolId = isset($data['school_id']) ? (int)$data['school_id'] : 0;

if (!$schoolId) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "school_id is required."]);
    exit();
}

try {
    // Fetch existing class records
    $stmt = $conn->prepare("SELECT id, class_name, strength FROM school_classes WHERE school_id = ? ORDER BY id ASC");
    $stmt->execute([$schoolId]);
    $classes = $stmt->fetchAll();

    // If no classes found for this school, seed defaults
    if (empty($classes)) {
        $defaultClasses = ['Nursery', 'LKG', 'UKG', 'Class 1', 'Class 2', 'Class 3',
                           'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8',
                           'Class 9', 'Class 10'];
        $insStmt = $conn->prepare("INSERT IGNORE INTO school_classes (school_id, class_name, strength) VALUES (?, ?, 0)");
        foreach ($defaultClasses as $cls) {
            $insStmt->execute([$schoolId, $cls]);
        }
        // Re-fetch after seeding
        $stmt->execute([$schoolId]);
        $classes = $stmt->fetchAll();
    }

    echo json_encode([
        "status" => "success",
        "classes" => $classes,
        "total_classes" => count($classes),
        "total_students" => array_sum(array_column($classes, 'strength'))
    ]);
} catch (Exception $e) {
    log_debug("get_class_strength error: " . $e->getMessage());
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
