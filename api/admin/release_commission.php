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

$userIds = isset($data['user_ids']) ? $data['user_ids'] : [];

if (!is_array($userIds) || empty($userIds)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required parameter user_ids (array) is missing or empty."]);
    exit();
}

try {
    $conn->beginTransaction();

    $stmtWallet = $conn->prepare("SELECT id, balance FROM wallets WHERE user_id = ? FOR UPDATE");
    $stmtUpdate = $conn->prepare("UPDATE wallets SET balance = 0.00 WHERE id = ?");
    $stmtTx = $conn->prepare("
        INSERT INTO wallet_transactions (wallet_id, amount, type, description)
        VALUES (?, ?, 'Debit', 'Commission payout released by Admin')
    ");

    $releasedCount = 0;
    $totalReleased = 0.00;

    foreach ($userIds as $uid) {
        $stmtWallet->execute([(int)$uid]);
        $w = $stmtWallet->fetch();
        if ($w) {
            $balance = (float)$w['balance'];
            if ($balance > 0) {
                $walletId = (int)$w['id'];
                
                // Set balance to 0
                $stmtUpdate->execute([$walletId]);
                
                // Log Debit Transaction
                $stmtTx->execute([$walletId, $balance]);

                $releasedCount++;
                $totalReleased += $balance;
            }
        }
    }

    $conn->commit();

    echo json_encode([
        "status" => "success",
        "message" => "Commission released successfully for $releasedCount users (Total: ₹" . number_format($totalReleased, 2) . ")"
    ]);

} catch (Exception $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
