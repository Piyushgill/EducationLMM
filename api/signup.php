<?php
require_once 'db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        "status" => "error",
        "message" => "Method Not Allowed. Only POST requests are accepted."
    ]);
    exit();
}

// Read raw JSON input body
$input = file_get_contents('php://input');
$data = json_decode($input, true);

if (!$data) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Invalid JSON payload."
    ]);
    exit();
}

// Extract standard user registration inputs from JSON data
$name = isset($data['name']) ? trim($data['name']) : '';
$email = isset($data['email']) ? trim($data['email']) : '';
$phone = isset($data['phone']) ? trim($data['phone']) : '';
$password = isset($data['password']) ? $data['password'] : '';
$role = isset($data['role']) ? trim($data['role']) : '';

log_debug("New Base64 registration request. Name: $name, Email: $email, Phone: $phone, Role: $role");

if (empty($name) || empty($email) || empty($phone) || empty($password) || empty($role)) {
    echo json_encode([
        "status" => "error",
        "message" => "Required credentials (name, email, phone, password, role) cannot be empty."
    ]);
    exit();
}

// Restrict phone number length to exactly 10 digits
if (strlen($phone) !== 10 || !ctype_digit($phone)) {
    echo json_encode([
        "status" => "error",
        "message" => "Mobile number must be exactly 10 digits."
    ]);
    exit();
}

// Start Transaction to ensure users and kyc_details are inserted atomically
try {
    $conn->beginTransaction();

    // 1. Check if email or phone already exists
    $stmt = $conn->prepare("SELECT id, email, phone FROM users WHERE email = ? OR phone = ?");
    $stmt->execute([$email, $phone]);
    $existingUser = $stmt->fetch();

    if ($existingUser) {
        if ($existingUser['email'] === $email) {
            echo json_encode(["status" => "error", "message" => "Email address is already registered."]);
        } else {
            echo json_encode(["status" => "error", "message" => "Phone number is already registered."]);
        }
        $conn->rollBack();
        log_debug("Registration stopped: Email or phone already registered.");
        exit();
    }

    // 2. Hash Password
    $hashedPassword = password_hash($password, PASSWORD_BCRYPT);

    // 3. Insert User into 'users' table
    $stmt = $conn->prepare("INSERT INTO users (name, email, phone, password, role, kyc_status) VALUES (?, ?, ?, ?, ?, 'Pending')");
    $stmt->execute([$name, $email, $phone, $hashedPassword, $role]);
    $userId = $conn->lastInsertId();
    log_debug("User record inserted successfully. ID: $userId");

    // 4. Handle KYC Image Uploads
    // Determine the role subdirectory
    $roleFolderMap = [
        "Student" => "student",
        "School" => "school",
        "Franchise Partner" => "franchise",
        "Distributor" => "distributor"
    ];
    
    $roleSubdir = isset($roleFolderMap[$role]) ? $roleFolderMap[$role] : "distributor";
    
    // Clean name to form user folder (alphanumeric and underscore)
    $cleanName = preg_replace('/[^a-zA-Z0-9_-]/', '_', $name);
    $userFolderName = $cleanName . "_" . $phone;
    
    // Target directory (relative to the API folder, pointing to the parallel kyc folder)
    $targetDir = "../kyc/" . $roleSubdir . "/" . $userFolderName . "/";
    
    // Create directories if they do not exist
    log_debug("Determining target folder: $targetDir");
    if (!file_exists($targetDir)) {
        if (!mkdir($targetDir, 0755, true)) {
            log_debug("Failed to create folder: $targetDir");
            throw new Exception("Failed to create KYC upload directory on server.");
        }
        log_debug("Target folder created successfully.");
    }
    chmod($targetDir, 0755); // Use 0755 as 0777 is blocked by hosting firewalls

    // Map of JSON Base64 keys to their saved column name
    $fileFields = [
        "aadhaar_front" => "aadhaar_front",
        "aadhaar_back" => "aadhaar_back",
        "pan_image" => "pan_image",
        "gst_cert" => "gst_cert",
        "school_reg_cert" => "school_reg_cert",
        "selfie" => "selfie",
        "signature" => "signature"
    ];

    $uploadedUrls = [];
    foreach ($fileFields as $key => $dbCol) {
        $uploadedUrls[$dbCol] = null;
        $base64Key = $key . "_base64";
        
        if (isset($data[$base64Key]) && !empty($data[$base64Key])) {
            $base64Data = $data[$base64Key];
            $ext = isset($data[$key . "_ext"]) ? strtolower($data[$key . "_ext"]) : "jpg";
            
            // Decode base64 bytes
            $fileBytes = base64_decode($base64Data);
            if ($fileBytes === false) {
                log_debug("Base64 decoding failed for $key");
                throw new Exception("Failed to decode uploaded image: " . $key);
            }
            
            // Write to destination file
            $newFileName = $key . "." . $ext;
            $destFilePath = $targetDir . $newFileName;
            
            log_debug("Writing Base64 file $key ($newFileName) to disk");
            if (file_put_contents($destFilePath, $fileBytes) !== false) {
                // Construct public URL
                $uploadedUrls[$dbCol] = "https://apps.kofalt.in/kyc/" . $roleSubdir . "/" . $userFolderName . "/" . $newFileName;
                log_debug("File $key written successfully. URL: " . $uploadedUrls[$dbCol]);
            } else {
                log_debug("File $key FAILED to write to $destFilePath");
                throw new Exception("Error writing uploaded file: " . $key);
            }
        }
    }

    // 5. Gather extra/specific details from JSON
    $schoolName = isset($data['school_name']) ? trim($data['school_name']) : null;
    $classGrade = isset($data['class_grade']) ? trim($data['class_grade']) : null;
    $dob = isset($data['dob']) ? trim($data['dob']) : null;
    
    $principalName = isset($data['principal_name']) ? trim($data['principal_name']) : null;
    $boardType = isset($data['board_type']) ? trim($data['board_type']) : null;
    $regNumber = isset($data['reg_number']) ? trim($data['reg_number']) : null;
    $schoolCity = isset($data['school_city']) ? trim($data['school_city']) : null;
    
    $businessName = isset($data['business_name']) ? trim($data['business_name']) : null;
    $gstNumber = isset($data['gst_number']) ? trim($data['gst_number']) : null;
    $city = isset($data['city']) ? trim($data['city']) : null;
    $experience = isset($data['experience']) ? trim($data['experience']) : null;
    $area = isset($data['area']) ? trim($data['area']) : null;

    $aadhaarNumber = isset($data['aadhaar_number']) ? trim($data['aadhaar_number']) : null;
    $panNumber = isset($data['pan_number']) ? trim($data['pan_number']) : null;
    $gstNumberDoc = isset($data['gst_number_doc']) ? trim($data['gst_number_doc']) : null;
    $schoolRegNumber = isset($data['school_reg_number']) ? trim($data['school_reg_number']) : null;

    $bankAccount = isset($data['bank_account']) ? trim($data['bank_account']) : null;
    $bankIfsc = isset($data['bank_ifsc']) ? trim($data['bank_ifsc']) : null;
    $bankName = isset($data['bank_name']) ? trim($data['bank_name']) : null;

    // 6. Insert into 'kyc_details' table
    $kycSql = "INSERT INTO kyc_details (
                user_id, school_name, class_grade, dob,
                principal_name, board_type, reg_number, school_city,
                business_name, gst_number, city, experience, area,
                aadhaar_number, pan_number, gst_number_doc, school_reg_number,
                aadhaar_front, aadhaar_back, pan_image, gst_cert, school_reg_cert, selfie,
                bank_account, bank_ifsc, bank_name, signature
              ) VALUES (
                ?, ?, ?, ?,
                ?, ?, ?, ?,
                ?, ?, ?, ?, ?,
                ?, ?, ?, ?,
                ?, ?, ?, ?, ?, ?,
                ?, ?, ?, ?
              )";
              
    $kycStmt = $conn->prepare($kycSql);
    $kycStmt->execute([
        $userId, $schoolName, $classGrade, $dob,
        $principalName, $boardType, $regNumber, $schoolCity,
        $businessName, $gstNumber, $city, $experience, $area,
        $aadhaarNumber, $panNumber, $gstNumberDoc, $schoolRegNumber,
        $uploadedUrls['aadhaar_front'], $uploadedUrls['aadhaar_back'], $uploadedUrls['pan_image'], $uploadedUrls['gst_cert'], $uploadedUrls['school_reg_cert'], $uploadedUrls['selfie'],
        $bankAccount, $bankIfsc, $bankName, $uploadedUrls['signature']
    ]);

    // Commit Transaction
    $conn->commit();
    log_debug("Database transaction committed successfully. Registration complete.");

    echo json_encode([
        "status" => "success",
        "message" => "Registration and KYC details submitted successfully.",
        "user" => [
            "id" => (int)$userId,
            "name" => $name,
            "email" => $email,
            "phone" => $phone,
            "role" => $role,
            "kyc_status" => "Pending"
        ]
    ]);

} catch (Exception $e) {
    log_debug("EXCEPTION CAUGHT: " . $e->getMessage());
    // Rollback changes on database exception or upload failure
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    // Return HTTP 200 with JSON error to prevent server custom HTML overrides
    echo json_encode([
        "status" => "error",
        "message" => "Registration failed: " . $e->getMessage()
    ]);
}
?>
