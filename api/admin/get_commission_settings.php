<?php
require_once '../db.php';

try {
    $stmt = $conn->prepare("SELECT setting_key, setting_value FROM commission_settings");
    $stmt->execute();
    $settingsList = $stmt->fetchAll();

    $settings = [];
    foreach ($settingsList as $row) {
        $settings[$row['setting_key']] = $row['setting_value'];
    }

    echo json_encode([
        "status" => "success",
        "settings" => $settings
    ]);

} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
