<?php
require_once '../db.php';

$input = file_get_contents('php://input');
$data = json_decode($input, true);

if (!$data || !isset($data['settings'])) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required parameter (settings) is missing."]);
    exit();
}

try {
    $conn->beginTransaction();

    $stmt = $conn->prepare("
        INSERT INTO commission_settings (setting_key, setting_value) 
        VALUES (?, ?) 
        ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)
    ");

    foreach ($data['settings'] as $key => $value) {
        $stmt->execute([$key, strval($value)]);
    }

    $conn->commit();

    echo json_encode([
        "status" => "success",
        "message" => "Commission settings updated successfully."
    ]);

} catch (Exception $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
