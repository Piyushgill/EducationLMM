<?php
require_once '../db.php';

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
    echo json_encode(["status" => "error", "message" => "Invalid JSON payload."]);
    exit();
}

$franchiseId = isset($data['franchise_id']) ? (int)$data['franchise_id'] : 0;
$name = isset($data['name']) ? trim($data['name']) : '';
$email = isset($data['email']) ? trim($data['email']) : '';
$phone = isset($data['phone']) ? trim($data['phone']) : '';
$password = isset($data['password']) ? trim($data['password']) : '';

// Center fields (maps to principal_name and school_city in kyc_details)
$contactPerson = isset($data['principal_name']) ? trim($data['principal_name']) : ''; // Contact Person
$centerCity = isset($data['center_city']) ? trim($data['center_city']) : '';

if (empty($franchiseId) || empty($name) || empty($email) || empty($phone) || empty($password)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required parameters are missing."]);
    exit();
}

try {
    $conn->beginTransaction();

    // Check if email or phone already exists
    $stmt = $conn->prepare("SELECT id FROM users WHERE email = ? OR phone = ?");
    $stmt->execute([$email, $phone]);
    if ($stmt->fetch()) {
        echo json_encode(["status" => "error", "message" => "Email or phone already registered."]);
        $conn->rollBack();
        exit();
    }

    // Insert user
    $hashedPassword = password_hash($password, PASSWORD_BCRYPT);
    $stmtUser = $conn->prepare("INSERT INTO users (name, email, phone, password, role, kyc_status) VALUES (?, ?, ?, ?, 'School', 'Approved')");
    $stmtUser->execute([$name, $email, $phone, $hashedPassword]);
    $centerId = $conn->lastInsertId();

    // Insert relation
    $stmtRel = $conn->prepare("INSERT INTO user_relations (parent_id, child_id) VALUES (?, ?)");
    $stmtRel->execute([$franchiseId, $centerId]);

    // Insert KYC details
    $stmtKyc = $conn->prepare("
        INSERT INTO kyc_details (
            user_id, school_name, principal_name, school_city
        ) VALUES (?, ?, ?, ?)
    ");
    $stmtKyc->execute([$centerId, $name, $contactPerson, $centerCity]);

    $conn->commit();

    echo json_encode([
        "status" => "success",
        "message" => "Center registered successfully under Franchise.",
        "center_id" => (int)$centerId
    ]);

} catch (Exception $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    echo json_encode(["status" => "error", "message" => "Failed to add center: " . $e->getMessage()]);
}
?>
