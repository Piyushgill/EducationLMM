<?php
require_once 'db.php';

// Accept user_id as either GET or POST parameter
$userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : (isset($_POST['user_id']) ? (int)$_POST['user_id'] : 0);

if ($userId <= 0) {
    // Also check for raw JSON payload
    $data = json_decode(file_get_contents('php://input'), true);
    $userId = isset($data['user_id']) ? (int)$data['user_id'] : 0;
}

if ($userId <= 0) {
    echo json_encode([
        "status" => "error",
        "message" => "Valid user_id parameter is required."
    ]);
    exit();
}

try {
    $stmt = $conn->prepare("SELECT id, name, role, kyc_status FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();

    if ($user) {
        echo json_encode([
            "status" => "success",
            "user_id" => (int)$user['id'],
            "name" => $user['name'],
            "role" => $user['role'],
            "kyc_status" => $user['kyc_status']
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "User account not found."
        ]);
    }
} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "An error occurred checking status: " . $e->getMessage()
    ]);
}
?>
