-- Database creation script for appskofa_education
-- You can run this in phpMyAdmin or mysql client.

CREATE TABLE IF NOT EXISTS `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `phone` VARCHAR(20) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `role` ENUM('Super Admin', 'Student', 'School', 'Franchise Partner', 'Distributor') NOT NULL,
    `kyc_status` ENUM('Pending', 'Approved', 'Rejected') NOT NULL DEFAULT 'Pending',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `kyc_details` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL UNIQUE,
    
    -- Role-specific Extra Fields (Students)
    `school_name` VARCHAR(150) DEFAULT NULL,
    `class_grade` VARCHAR(50) DEFAULT NULL,
    `dob` VARCHAR(20) DEFAULT NULL,
    
    -- Role-specific Extra Fields (Schools)
    `principal_name` VARCHAR(100) DEFAULT NULL,
    `board_type` VARCHAR(100) DEFAULT NULL,
    `reg_number` VARCHAR(100) DEFAULT NULL,
    `school_city` VARCHAR(100) DEFAULT NULL,
    
    -- Role-specific Extra Fields (Franchise / Distributors)
    `business_name` VARCHAR(150) DEFAULT NULL,
    `gst_number` VARCHAR(50) DEFAULT NULL,
    `city` VARCHAR(100) DEFAULT NULL,
    `experience` VARCHAR(150) DEFAULT NULL,
    `area` VARCHAR(150) DEFAULT NULL,
    
    -- KYC Doc text inputs
    `aadhaar_number` VARCHAR(20) DEFAULT NULL,
    `pan_number` VARCHAR(20) DEFAULT NULL,
    `gst_number_doc` VARCHAR(50) DEFAULT NULL,
    `school_reg_number` VARCHAR(100) DEFAULT NULL,
    
    -- KYC Document image URLs
    `aadhaar_front` VARCHAR(255) DEFAULT NULL,
    `aadhaar_back` VARCHAR(255) DEFAULT NULL,
    `pan_image` VARCHAR(255) DEFAULT NULL,
    `gst_cert` VARCHAR(255) DEFAULT NULL,
    `school_reg_cert` VARCHAR(255) DEFAULT NULL,
    `selfie` VARCHAR(255) DEFAULT NULL,
    
    -- Bank Details
    `bank_account` VARCHAR(50) DEFAULT NULL,
    `bank_ifsc` VARCHAR(20) DEFAULT NULL,
    `bank_name` VARCHAR(100) DEFAULT NULL,
    
    -- Agreement & Signature
    `signature` VARCHAR(255) DEFAULT NULL,
    `submitted_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. MLM Downline User Relationships
CREATE TABLE IF NOT EXISTS `user_relations` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `parent_id` INT NOT NULL,
    `child_id` INT NOT NULL UNIQUE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`parent_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`child_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Practice Exam attempts
CREATE TABLE IF NOT EXISTS `practice_attempts` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` INT NOT NULL,
    `level` INT NOT NULL,
    `score` INT NOT NULL, -- out of 50
    `passed` TINYINT(1) NOT NULL,
    `taken_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Kit Items Master Catalog
CREATE TABLE IF NOT EXISTS `kits` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `level` VARCHAR(50) NOT NULL, -- 'Level 1' through 'Level 8'
    `price` DECIMAL(10, 2) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. Kit Orders
CREATE TABLE IF NOT EXISTS `kit_orders` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `buyer_id` INT NOT NULL,
    `total_amount` DECIMAL(10, 2) NOT NULL,
    `payment_status` ENUM('Pending', 'Paid', 'Failed') NOT NULL DEFAULT 'Pending',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. Kit Order Items
CREATE TABLE IF NOT EXISTS `kit_order_items` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `order_id` INT NOT NULL,
    `kit_id` INT NOT NULL,
    `quantity` INT NOT NULL DEFAULT 1,
    `price_at_purchase` DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (`order_id`) REFERENCES `kit_orders` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`kit_id`) REFERENCES `kits` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. 8-Tier Commission Logs
CREATE TABLE IF NOT EXISTS `commissions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `recipient_id` INT NOT NULL,
    `trigger_user_id` INT NOT NULL,
    `order_id` INT NOT NULL,
    `amount` DECIMAL(10, 2) NOT NULL,
    `tier_level` INT NOT NULL, -- 1 to 8
    `status` ENUM('Pending', 'Paid') NOT NULL DEFAULT 'Pending',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`recipient_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`trigger_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`order_id`) REFERENCES `kit_orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9. Student Batches (Franchise / School Scheduling)
CREATE TABLE IF NOT EXISTS `student_batches` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `creator_id` INT NOT NULL,
    `batch_name` VARCHAR(100) NOT NULL,
    `class_time` VARCHAR(20) NOT NULL, -- e.g., '14:30'
    `class_days` VARCHAR(100) NOT NULL, -- e.g., 'Mon,Wed,Fri'
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`creator_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 10. Batch Allocations
CREATE TABLE IF NOT EXISTS `batch_members` (
    `batch_id` INT NOT NULL,
    `student_id` INT NOT NULL,
    PRIMARY KEY (`batch_id`, `student_id`),
    FOREIGN KEY (`batch_id`) REFERENCES `student_batches` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 11. Courses Catalog
CREATE TABLE IF NOT EXISTS `courses` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(150) NOT NULL,
    `description` TEXT NOT NULL,
    `class_grade` VARCHAR(50) NOT NULL,
    `subject` VARCHAR(100) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 12. Chapters & Video Lessons
CREATE TABLE IF NOT EXISTS `chapters` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `course_id` INT NOT NULL,
    `chapter_number` INT NOT NULL,
    `title` VARCHAR(150) NOT NULL,
    `resource_url` VARCHAR(255) NOT NULL, -- link to video or document
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 13. Platform Announcements (Circulars)
CREATE TABLE IF NOT EXISTS `circulars` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(150) NOT NULL,
    `message` TEXT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
