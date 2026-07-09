<?php
// Database connection configuration for apps.kofalt.in/api

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

error_reporting(0);
ini_set('display_errors', 0);

function log_debug($msg) {
    $logFile = __DIR__ . '/debug.log';
    $logMsg = date('[Y-m-d H:i:s] ') . $msg . "\n";
    file_put_contents($logFile, $logMsg, FILE_APPEND);
}

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$host = "localhost";
$db_name = "appskofa_education";
$username = "appskofa_education";
$password = "Education@147";

try {
    $conn = new PDO("mysql:host=" . $host . ";dbname=" . $db_name . ";charset=utf8", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $conn->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);

    // Self-healing database check:
    // 1. Check if 'status' column exists in 'users' table
    $usersColumnCheck = $conn->query("SHOW COLUMNS FROM `users` LIKE 'status'")->fetch();
    if (!$usersColumnCheck) {
        $conn->exec("ALTER TABLE `users` ADD COLUMN `status` ENUM('Active', 'Suspended') NOT NULL DEFAULT 'Active'");
    }

    // 2. Check if 'delivery_status' column exists in 'kit_orders' table
    $ordersColumnCheck = $conn->query("SHOW COLUMNS FROM `kit_orders` LIKE 'delivery_status'")->fetch();
    if (!$ordersColumnCheck) {
        $conn->exec("ALTER TABLE `kit_orders` ADD COLUMN `delivery_status` ENUM('Pending', 'Shipped', 'Delivered', 'Cancelled') NOT NULL DEFAULT 'Pending'");
    }

} catch (PDOException $exception) {
    echo json_encode([
        "status" => "error",
        "message" => "Database connection error: " . $exception->getMessage()
    ]);
    exit();
}
?>
