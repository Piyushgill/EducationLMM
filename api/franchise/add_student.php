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

$input = file_get_contents('php://input');
$data = json_decode($input, true);

$schoolId = isset($data['school_id']) ? (int)$data['school_id'] : (isset($data['center_id']) ? (int)$data['center_id'] : 0);
$name = isset($data['name']) ? trim($data['name']) : '';
$email = isset($data['email']) ? trim($data['email']) : '';
$phone = isset($data['phone']) ? trim($data['phone']) : '';
$password = isset($data['password']) ? trim($data['password']) : '';

if (empty($schoolId) || empty($name) || empty($email) || empty($phone) || empty($password)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "All parameters (school_id/center_id, name, email, phone, password) are required."]);
    exit();
}

try {
    // Check if email or phone already exists
    $check = $conn->prepare("SELECT id FROM users WHERE email = ? OR phone = ?");
    $check->execute([$email, $phone]);
    if ($check->rowCount() > 0) {
        echo json_encode(["status" => "error", "message" => "Email or Phone already registered."]);
        exit();
    }

    $conn->beginTransaction();

    // Insert user
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
    $stmtUser = $conn->prepare("
        INSERT INTO users (name, email, phone, password, role, kyc_status, status) 
        VALUES (?, ?, ?, ?, 'Student', 'Approved', 'Active')
    ");
    $stmtUser->execute([$name, $email, $phone, $hashedPassword]);
    $studentId = $conn->lastInsertId();

    // Link under school
    $stmtRel = $conn->prepare("INSERT INTO user_relations (parent_id, child_id) VALUES (?, ?)");
    $stmtRel->execute([$schoolId, $studentId]);

    // Insert default fee record
    $stmtFee = $conn->prepare("INSERT INTO student_fees (student_id, school_id, amount, due_date, status) VALUES (?, ?, 2500.00, DATE_ADD(CURRENT_DATE(), INTERVAL 30 DAY), 'Pending')");
    $stmtFee->execute([$studentId, $schoolId]);

    $conn->commit();

    echo json_encode([
        "status" => "success",
        "message" => "Student registered successfully.",
        "student_id" => (int)$studentId
    ]);

} catch (Exception $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    echo json_encode(["status" => "error", "message" => "Registration failed: " . $e->getMessage()]);
}
?>
