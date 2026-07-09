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

// Decode JSON input or fall back to standard $_POST parameters
$data = json_decode(file_get_contents('php://input'), true);
$emailOrPhone = isset($data['email']) ? trim($data['email']) : (isset($_POST['email']) ? trim($_POST['email']) : '');
$password = isset($data['password']) ? $data['password'] : (isset($_POST['password']) ? $_POST['password'] : '');

if (empty($emailOrPhone) || empty($password)) {
    echo json_encode([
        "status" => "error",
        "message" => "Email/Phone and password are required fields."
    ]);
    exit();
}

try {
    // Look up user by email or phone
    $stmt = $conn->prepare("SELECT id, name, email, phone, password, role, kyc_status FROM users WHERE email = ? OR phone = ?");
    $stmt->execute([$emailOrPhone, $emailOrPhone]);
    $user = $stmt->fetch();

    if ($user && password_verify($password, $user['password'])) {
        // Password is correct, return user session details
        echo json_encode([
            "status" => "success",
            "message" => "Login successful.",
            "user" => [
                "id" => (int)$user['id'],
                "name" => $user['name'],
                "email" => $user['email'],
                "phone" => $user['phone'],
                "role" => $user['role'],
                "kyc_status" => $user['kyc_status']
            ]
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Invalid email, phone number, or password."
        ]);
    }
} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "An error occurred during login: " . $e->getMessage()
    ]);
}
?>
