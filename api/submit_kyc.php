<?php
require_once 'db.php';

// Allow from any origin (CORS)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

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

$userId = isset($data['user_id']) ? (int)$data['user_id'] : 0;
if (empty($userId)) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Required user_id parameter is missing."
    ]);
    exit();
}

try {
    $conn->beginTransaction();

    // Fetch user details
    $stmtUser = $conn->prepare("SELECT id, name, phone, role FROM users WHERE id = ?");
    $stmtUser->execute([$userId]);
    $user = $stmtUser->fetch();

    if (!$user) {
        throw new Exception("User not found.");
    }

    $name = $user['name'];
    $phone = $user['phone'];
    $role = $user['role'];

    // Map role folders
    $roleFolderMap = [
        "Student" => "student",
        "School" => "school",
        "Franchise Partner" => "franchise",
        "Distributor" => "distributor",
        "Agent" => "agent"
    ];
    $roleSubdir = isset($roleFolderMap[$role]) ? $roleFolderMap[$role] : "agent";

    // Clean name to form user folder
    $cleanName = preg_replace('/[^a-zA-Z0-9_-]/', '_', $name);
    $userFolderName = $cleanName . "_" . $phone;
    $targetDir = "../kyc/" . $roleSubdir . "/" . $userFolderName . "/";

    if (!file_exists($targetDir)) {
        if (!mkdir($targetDir, 0755, true)) {
            throw new Exception("Failed to create KYC upload directory on server.");
        }
    }
    chmod($targetDir, 0755);

    // File fields mapping
    $fileFields = [
        "aadhaar_front" => "aadhaar_front",
        "aadhaar_back" => "aadhaar_back",
        "pan_image" => "pan_image",
        "gst_cert" => "gst_cert",
        "school_reg_cert" => "school_reg_cert",
        "selfie" => "selfie",
        "signature" => "signature"
    ];

    // Fetch existing KYC details if any
    $stmtKycCheck = $conn->prepare("SELECT id, aadhaar_front, aadhaar_back, pan_image, gst_cert, school_reg_cert, selfie, signature FROM kyc_details WHERE user_id = ?");
    $stmtKycCheck->execute([$userId]);
    $existingKyc = $stmtKycCheck->fetch();

    $uploadedUrls = [];
    foreach ($fileFields as $key => $dbCol) {
        // Keep existing URL by default
        $uploadedUrls[$dbCol] = $existingKyc ? $existingKyc[$dbCol] : null;
        $base64Key = $key . "_base64";

        if (isset($data[$base64Key]) && !empty($data[$base64Key])) {
            $base64Data = $data[$base64Key];
            $ext = isset($data[$key . "_ext"]) ? strtolower($data[$key . "_ext"]) : "jpg";

            $fileBytes = base64_decode($base64Data);
            if ($fileBytes === false) {
                throw new Exception("Failed to decode uploaded image: " . $key);
            }

            $newFileName = $key . "." . $ext;
            $destFilePath = $targetDir . $newFileName;

            if (file_put_contents($destFilePath, $fileBytes) !== false) {
                $uploadedUrls[$dbCol] = "https://apps.kofalt.in/kyc/" . $roleSubdir . "/" . $userFolderName . "/" . $newFileName;
            } else {
                throw new Exception("Error writing uploaded file: " . $key);
            }
        }
    }

    // Fields
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

    if ($existingKyc) {
        // Update kyc_details
        $stmtKyc = $conn->prepare("
            UPDATE kyc_details 
            SET school_name = ?, class_grade = ?, dob = ?, principal_name = ?, board_type = ?, 
                reg_number = ?, school_city = ?, business_name = ?, gst_number = ?, city = ?, 
                experience = ?, area = ?, aadhaar_number = ?, pan_number = ?, gst_number_doc = ?, 
                school_reg_number = ?, aadhaar_front = ?, aadhaar_back = ?, pan_image = ?, gst_cert = ?, 
                school_reg_cert = ?, selfie = ?, signature = ?, bank_account = ?, bank_ifsc = ?, 
                bank_name = ?, rejection_reason = NULL 
            WHERE user_id = ?
        ");
        $stmtKyc->execute([
            $schoolName, $classGrade, $dob, $principalName, $boardType,
            $regNumber, $schoolCity, $businessName, $gstNumber, $city,
            $experience, $area, $aadhaarNumber, $panNumber, $gstNumberDoc,
            $schoolRegNumber, $uploadedUrls['aadhaar_front'], $uploadedUrls['aadhaar_back'], $uploadedUrls['pan_image'], $uploadedUrls['gst_cert'],
            $uploadedUrls['school_reg_cert'], $uploadedUrls['selfie'], $uploadedUrls['signature'], $bankAccount, $bankIfsc,
            $bankName, $userId
        ]);
    } else {
        // Insert kyc_details
        $stmtKyc = $conn->prepare("
            INSERT INTO kyc_details (
                user_id, school_name, class_grade, dob, principal_name, board_type,
                reg_number, school_city, business_name, gst_number, city,
                experience, area, aadhaar_number, pan_number, gst_number_doc,
                school_reg_number, aadhaar_front, aadhaar_back, pan_image, gst_cert,
                school_reg_cert, selfie, signature, bank_account, bank_ifsc, bank_name
            ) VALUES (
                ?, ?, ?, ?, ?, ?,
                ?, ?, ?, ?, ?,
                ?, ?, ?, ?, ?,
                ?, ?, ?, ?, ?,
                ?, ?, ?, ?, ?, ?
            )
        ");
        $stmtKyc->execute([
            $userId, $schoolName, $classGrade, $dob, $principalName, $boardType,
            $regNumber, $schoolCity, $businessName, $gstNumber, $city,
            $experience, $area, $aadhaarNumber, $panNumber, $gstNumberDoc,
            $schoolRegNumber, $uploadedUrls['aadhaar_front'], $uploadedUrls['aadhaar_back'], $uploadedUrls['pan_image'], $uploadedUrls['gst_cert'],
            $uploadedUrls['school_reg_cert'], $uploadedUrls['selfie'], $uploadedUrls['signature'], $bankAccount, $bankIfsc, $bankName
        ]);
    }

    // Also update bank details inside the 'users' table directly to stay in sync
    $stmtUserBank = $conn->prepare("
        UPDATE users 
        SET bank_name = ?, account_number = ?, ifsc_code = ?, account_holder_name = ?, kyc_status = 'Pending' 
        WHERE id = ?
    ");
    $stmtUserBank->execute([$bankName, $bankAccount, $bankIfsc, $name, $userId]);

    $conn->commit();

    echo json_encode([
        "status" => "success",
        "message" => "KYC details submitted successfully! Pending approval."
    ]);

} catch (Exception $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    echo json_encode([
        "status" => "error",
        "message" => "Failed to submit KYC: " . $e->getMessage()
    ]);
}
?>
