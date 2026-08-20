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

    // Ensure 'kyc_details' table exists with all columns
    $conn->exec("CREATE TABLE IF NOT EXISTS `kyc_details` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `user_id` INT NOT NULL UNIQUE,
        `school_name` VARCHAR(150) DEFAULT NULL,
        `class_grade` VARCHAR(50) DEFAULT NULL,
        `dob` DATE DEFAULT NULL,
        `principal_name` VARCHAR(100) DEFAULT NULL,
        `board_type` VARCHAR(100) DEFAULT NULL,
        `reg_number` VARCHAR(100) DEFAULT NULL,
        `school_city` VARCHAR(100) DEFAULT NULL,
        `business_name` VARCHAR(150) DEFAULT NULL,
        `gst_number` VARCHAR(50) DEFAULT NULL,
        `city` VARCHAR(100) DEFAULT NULL,
        `experience` VARCHAR(150) DEFAULT NULL,
        `area` VARCHAR(150) DEFAULT NULL,
        `aadhaar_number` VARCHAR(12) DEFAULT NULL,
        `pan_number` VARCHAR(10) DEFAULT NULL,
        `gst_number_doc` VARCHAR(15) DEFAULT NULL,
        `school_reg_number` VARCHAR(100) DEFAULT NULL,
        `aadhaar_front` VARCHAR(255) DEFAULT NULL,
        `aadhaar_back` VARCHAR(255) DEFAULT NULL,
        `pan_image` VARCHAR(255) DEFAULT NULL,
        `gst_cert` VARCHAR(255) DEFAULT NULL,
        `school_reg_cert` VARCHAR(255) DEFAULT NULL,
        `selfie` VARCHAR(255) DEFAULT NULL,
        `signature` VARCHAR(255) DEFAULT NULL,
        `bank_account` VARCHAR(18) DEFAULT NULL,
        `bank_ifsc` VARCHAR(11) DEFAULT NULL,
        `bank_name` VARCHAR(100) DEFAULT NULL,
        `rejection_reason` TEXT DEFAULT NULL,
        `submitted_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // Check if 'rejection_reason' column exists in 'kyc_details' table (for older installs)
    $kycTableCheck = $conn->query("SHOW TABLES LIKE 'kyc_details'")->fetch();
    if ($kycTableCheck) {
        $kycReasonCheck = $conn->query("SHOW COLUMNS FROM `kyc_details` LIKE 'rejection_reason'")->fetch();
        if (!$kycReasonCheck) {
            $conn->exec("ALTER TABLE `kyc_details` ADD COLUMN `rejection_reason` TEXT DEFAULT NULL");
        }
    }

    // Check bank detail columns in 'users' table
    $bankCols = [
        'bank_name' => "VARCHAR(150) DEFAULT NULL",
        'account_number' => "VARCHAR(100) DEFAULT NULL",
        'ifsc_code' => "VARCHAR(50) DEFAULT NULL",
        'account_holder_name' => "VARCHAR(150) DEFAULT NULL"
    ];
    foreach ($bankCols as $bcol => $bdef) {
        $check = $conn->query("SHOW COLUMNS FROM `users` LIKE '$bcol'")->fetch();
        if (!$check) {
            $conn->exec("ALTER TABLE `users` ADD COLUMN `$bcol` $bdef");
        }
    }

    // 2. Check if 'delivery_status' column exists in 'kit_orders' table
    $ordersColumnCheck = $conn->query("SHOW COLUMNS FROM `kit_orders` LIKE 'delivery_status'")->fetch();
    if (!$ordersColumnCheck) {
        $conn->exec("ALTER TABLE `kit_orders` ADD COLUMN `delivery_status` ENUM('Pending', 'Shipped', 'Delivered', 'Cancelled') NOT NULL DEFAULT 'Pending'");
    }

    // 3. Modify 'role' in 'users' to include 'Agent'
    $conn->exec("ALTER TABLE `users` MODIFY COLUMN `role` ENUM('Super Admin', 'Student', 'School', 'Franchise Partner', 'Distributor', 'Agent') NOT NULL");

    // 4. Add columns to 'kit_orders' if they don't exist
    $cols = [
        'agent_id' => "INT DEFAULT NULL",
        'distributor_id' => "INT DEFAULT NULL",
        'school_name' => "VARCHAR(150) DEFAULT NULL",
        'school_address' => "TEXT DEFAULT NULL",
        'contact_person' => "VARCHAR(100) DEFAULT NULL",
        'mobile_number' => "VARCHAR(20) DEFAULT NULL",
        'order_type' => "ENUM('MLM', 'Direct') NOT NULL DEFAULT 'Direct'",
        'program' => "VARCHAR(100) DEFAULT NULL",
        'selected_school_id' => "INT DEFAULT NULL"
    ];
    foreach ($cols as $colName => $colDef) {
        $check = $conn->query("SHOW COLUMNS FROM `kit_orders` LIKE '$colName'")->fetch();
        if (!$check) {
            $conn->exec("ALTER TABLE `kit_orders` ADD COLUMN `$colName` $colDef");
        }
    }

    // 5. Create 'wallets' table
    $conn->exec("CREATE TABLE IF NOT EXISTS `wallets` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `user_id` INT NOT NULL UNIQUE,
        `balance` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
        `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // 6. Create 'wallet_transactions' table
    $conn->exec("CREATE TABLE IF NOT EXISTS `wallet_transactions` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `wallet_id` INT NOT NULL,
        `amount` DECIMAL(10, 2) NOT NULL,
        `type` ENUM('Credit', 'Debit') NOT NULL,
        `description` VARCHAR(255) NOT NULL,
        `reference_id` INT DEFAULT NULL,
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (`wallet_id`) REFERENCES `wallets` (`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // 7. Create 'commission_settings' table
    $conn->exec("CREATE TABLE IF NOT EXISTS `commission_settings` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `setting_key` VARCHAR(100) NOT NULL UNIQUE,
        `setting_value` VARCHAR(255) NOT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // Create 'circulars' table
    $conn->exec("CREATE TABLE IF NOT EXISTS `circulars` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `title` VARCHAR(255) NOT NULL,
        `message` TEXT NOT NULL,
        `target_roles` VARCHAR(255) DEFAULT 'All',
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // Create 'videos' table
    $conn->exec("CREATE TABLE IF NOT EXISTS `videos` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `title` VARCHAR(255) NOT NULL,
        `description` TEXT DEFAULT NULL,
        `video_url` VARCHAR(255) NOT NULL,
        `target_roles` VARCHAR(255) NOT NULL,
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // Create 'testimonials' table
    $conn->exec("CREATE TABLE IF NOT EXISTS `testimonials` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `name` VARCHAR(255) NOT NULL,
        `role` VARCHAR(255) NOT NULL,
        `message` TEXT NOT NULL,
        `rating` INT NOT NULL DEFAULT 5,
        `target_roles` VARCHAR(255) NOT NULL,
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // Create 'faqs' table
    $conn->exec("CREATE TABLE IF NOT EXISTS `faqs` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `question` TEXT NOT NULL,
        `answer` TEXT NOT NULL,
        `target_roles` VARCHAR(255) NOT NULL,
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // Create 'student_fees' table
    $conn->exec("CREATE TABLE IF NOT EXISTS `student_fees` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `student_id` INT NOT NULL,
        `school_id` INT NOT NULL,
        `amount` DECIMAL(10, 2) NOT NULL DEFAULT 2500.00,
        `due_date` DATE NOT NULL,
        `status` ENUM('Pending', 'Paid', 'Overdue') NOT NULL DEFAULT 'Pending',
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
        FOREIGN KEY (`school_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // Create 'training_requests' table
    $conn->exec("CREATE TABLE IF NOT EXISTS `training_requests` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `school_id` INT NOT NULL,
        `topic` VARCHAR(255) NOT NULL,
        `requested_date` DATE DEFAULT NULL,
        `requested_time` VARCHAR(50) DEFAULT NULL,
        `notes` TEXT DEFAULT NULL,
        `scheduled_date` DATE DEFAULT NULL,
        `scheduled_time` VARCHAR(50) DEFAULT NULL,
        `meeting_info` VARCHAR(255) DEFAULT NULL,
        `status` ENUM('Pending', 'Scheduled', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Pending',
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (`school_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // Create 'commissions' table
    $conn->exec("CREATE TABLE IF NOT EXISTS `commissions` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `recipient_id` INT NOT NULL,
        `trigger_user_id` INT NOT NULL,
        `order_id` INT NOT NULL,
        `amount` DECIMAL(10, 2) NOT NULL,
        `tier_level` INT NOT NULL DEFAULT 1,
        `status` ENUM('Pending', 'Paid') NOT NULL DEFAULT 'Pending',
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (`recipient_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
        FOREIGN KEY (`trigger_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // Create 'kit_order_items' table
    $conn->exec("CREATE TABLE IF NOT EXISTS `kit_order_items` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `order_id` INT NOT NULL,
        `kit_id` INT NOT NULL,
        `quantity` INT NOT NULL DEFAULT 1,
        `price_at_purchase` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // Create 'practice_attempts' table
    $conn->exec("CREATE TABLE IF NOT EXISTS `practice_attempts` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `student_id` INT NOT NULL,
        `exam_id` INT DEFAULT NULL,
        `score` INT NOT NULL DEFAULT 0,
        `total` INT NOT NULL DEFAULT 0,
        `attempted_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // Create 'school_classes' table — stores each school's class names and strengths
    $conn->exec("CREATE TABLE IF NOT EXISTS `school_classes` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `school_id` INT NOT NULL,
        `class_name` VARCHAR(100) NOT NULL,
        `strength` INT NOT NULL DEFAULT 0,
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        UNIQUE KEY `school_class_unique` (`school_id`, `class_name`),
        FOREIGN KEY (`school_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // Seed default school classes for existing schools (Nursery to Class 10) if none exist
    // This runs per school on login; actual seeding done per-school by API

    // Seed default settings if not exists
    $chkSet = $conn->query("SELECT COUNT(*) FROM `commission_settings`")->fetchColumn();
    if ($chkSet == 0) {
        $conn->exec("INSERT INTO `commission_settings` (`setting_key`, `setting_value`) VALUES 
            ('commission_type', 'per_kit'),
            ('per_kit_commission', '50'),
            ('global_percent', '5'),
            ('percent_Level 1', '5'),
            ('percent_Level 2', '6'),
            ('percent_Level 3', '7'),
            ('percent_Level 4', '8'),
            ('percent_Level 5', '9'),
            ('percent_Level 6', '10'),
            ('percent_Level 7', '11'),
            ('percent_Level 8', '12')
        ");
    } else {
        // Ensure per_kit_commission setting exists in older installs
        $chkPerKit = $conn->query("SELECT COUNT(*) FROM `commission_settings` WHERE setting_key='per_kit_commission'")->fetchColumn();
        if ($chkPerKit == 0) {
            $conn->exec("INSERT INTO `commission_settings` (setting_key, setting_value) VALUES ('per_kit_commission', '50')");
        }
    }

function creditWallet($conn, $userId, $amount, $desc, $refId = null) {
    try {
        $stmt = $conn->prepare("SELECT id FROM wallets WHERE user_id = ?");
        $stmt->execute([$userId]);
        $wallet = $stmt->fetch();
        if (!$wallet) {
            $stmtIns = $conn->prepare("INSERT INTO wallets (user_id, balance) VALUES (?, 0.00)");
            $stmtIns->execute([$userId]);
            $walletId = (int)$conn->lastInsertId();
        } else {
            $walletId = (int)$wallet['id'];
        }

        $stmtUp = $conn->prepare("UPDATE wallets SET balance = balance + ? WHERE id = ?");
        $stmtUp->execute([$amount, $walletId]);

        $stmtLog = $conn->prepare("
            INSERT INTO wallet_transactions (wallet_id, amount, type, description, reference_id)
            VALUES (?, ?, 'Credit', ?, ?)
        ");
        $stmtLog->execute([$walletId, $amount, $desc, $refId]);
    } catch (Exception $e) {
        log_debug("creditWallet error for user $userId: " . $e->getMessage());
    }
}

function distributeCommission($conn, $orderId) {
    try {
        $chk = $conn->prepare("SELECT id FROM commissions WHERE order_id = ?");
        $chk->execute([$orderId]);
        if ($chk->rowCount() > 0) {
            log_debug("Commission already distributed for order #$orderId");
            return; // Already distributed
        }

        $stmtOrder = $conn->prepare("SELECT buyer_id, total_amount FROM kit_orders WHERE id = ?");
        $stmtOrder->execute([$orderId]);
        $order = $stmtOrder->fetch();
        if (!$order) {
            log_debug("Order #$orderId not found for commission distribution");
            return;
        }

        $buyerId = (int)$order['buyer_id'];
        $totalAmount = (float)$order['total_amount'];

        $stmtUser = $conn->prepare("SELECT role FROM users WHERE id = ?");
        $stmtUser->execute([$buyerId]);
        $user = $stmtUser->fetch();
        if (!$user || !in_array($user['role'], ['Agent', 'Distributor'])) {
            log_debug("Buyer role is " . ($user ? $user['role'] : 'unknown') . ". No commissions distributed.");
            return; // Only MLM buyers get MLM commission
        }

        // Fetch per kit commission setting
        $stmtSet = $conn->prepare("SELECT setting_value FROM commission_settings WHERE setting_key = 'per_kit_commission'");
        $stmtSet->execute();
        $setRow = $stmtSet->fetch();
        $perKitVal = $setRow ? (float)$setRow['setting_value'] : 50.0;

        // Fetch quantity of kits ordered
        $stmtQty = $conn->prepare("SELECT SUM(quantity) as qty FROM kit_order_items WHERE order_id = ?");
        $stmtQty->execute([$orderId]);
        $qtyRow = $stmtQty->fetch();
        $quantity = $qtyRow && $qtyRow['qty'] !== null ? (int)$qtyRow['qty'] : 1;

        $commissionPool = $quantity * $perKitVal;
        log_debug("Order #$orderId: Quantity $quantity, Per-Kit Rate ₹$perKitVal, Pool: ₹$commissionPool");

        // Traverse upline
        $path = [$buyerId];
        $currentNode = $buyerId;
        while (true) {
            $stmtParent = $conn->prepare("SELECT parent_id FROM user_relations WHERE child_id = ?");
            $stmtParent->execute([$currentNode]);
            $relation = $stmtParent->fetch();
            if (!$relation) break;
            $parentId = (int)$relation['parent_id'];
            $path[] = $parentId;
            $currentNode = $parentId;
        }

        $K = count($path);
        if ($K > 8) $K = 8;

        $distribution = [
            8 => [8 => 0.80, 7 => 0.12, 6 => 0.04, 5 => 0.02, 4 => 0.01, 3 => 0.005, 2 => 0.003, 1 => 0.002],
            7 => [7 => 0.80, 6 => 0.12, 5 => 0.04, 4 => 0.02, 3 => 0.01, 2 => 0.006, 1 => 0.004],
            6 => [6 => 0.80, 5 => 0.12, 4 => 0.04, 3 => 0.024, 2 => 0.01, 1 => 0.006],
            5 => [5 => 0.80, 4 => 0.12, 3 => 0.04, 2 => 0.024, 1 => 0.016],
            4 => [4 => 0.80, 3 => 0.12, 2 => 0.05, 1 => 0.03],
            3 => [3 => 0.80, 2 => 0.12, 1 => 0.08],
            2 => [2 => 0.80, 1 => 0.20],
            1 => [1 => 1.00]
        ];

        if (!isset($distribution[$K])) {
            log_debug("No distribution found for depth $K");
            return;
        }

        $shares = $distribution[$K];
        foreach ($shares as $R => $fraction) {
            $idx = $K - $R;
            if (isset($path[$idx])) {
                $recipientId = $path[$idx];
                $amount = $commissionPool * $fraction;

                // Log commission row
                $stmtInsert = $conn->prepare("
                    INSERT INTO commissions (recipient_id, trigger_user_id, order_id, amount, tier_level, status)
                    VALUES (?, ?, ?, ?, ?, 'Paid')
                ");
                $stmtInsert->execute([$recipientId, $buyerId, $orderId, $amount, $R]);

                // Credit wallet
                creditWallet($conn, $recipientId, $amount, "Commission earned from Order #$orderId", $orderId);
                log_debug("Credited ₹$amount to Recipient ID $recipientId (Tier $R) for Order #$orderId");
            }
        }
    } catch (Exception $e) {
        log_debug("distributeCommission error for order $orderId: " . $e->getMessage());
    }
}

} catch (PDOException $exception) {
    echo json_encode([
        "status" => "error",
        "message" => "Database connection error: " . $exception->getMessage()
    ]);
    exit();
}
?>
