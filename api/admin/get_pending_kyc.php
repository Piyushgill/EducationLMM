<?php
require_once '../db.php';

// Allow from any origin (CORS)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    // Fetch users with kyc_status 'Pending', their KYC details, and their creator
    $stmt = $conn->prepare("
        SELECT 
            u.id, u.name, u.email, u.phone, u.role, u.kyc_status, u.created_at,
            kd.school_name, kd.class_grade, kd.dob,
            kd.principal_name, kd.board_type, kd.reg_number, kd.school_city,
            kd.business_name, kd.gst_number, kd.city, kd.experience, kd.area,
            kd.aadhaar_number, kd.pan_number, kd.gst_number_doc, kd.school_reg_number,
            kd.aadhaar_front, kd.aadhaar_back, kd.pan_image, kd.gst_cert, kd.school_reg_cert, 
            kd.selfie, kd.signature, kd.bank_account, kd.bank_ifsc, kd.bank_name, kd.rejection_reason,
            creator.name AS created_by_name,
            creator.role AS created_by_role,
            creator.phone AS created_by_phone
        FROM users u
        LEFT JOIN kyc_details kd ON u.id = kd.user_id
        LEFT JOIN user_relations ur ON ur.child_id = u.id
        LEFT JOIN users creator ON creator.id = ur.parent_id
        WHERE u.kyc_status = 'Pending' AND u.role != 'Super Admin'
        ORDER BY u.created_at ASC
    ");
    $stmt->execute();
    $pendingList = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Cast any numerical values if needed
    foreach ($pendingList as &$row) {
        $row['id'] = (int)$row['id'];
    }
    
    echo json_encode([
        "status" => "success",
        "data" => $pendingList
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to fetch pending KYC: " . $e->getMessage()
    ]);
}
?>
