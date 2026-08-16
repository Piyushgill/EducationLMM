<?php
require_once 'db.php';

$input = file_get_contents('php://input');
$data = json_decode($input, true);

$userId = isset($data['user_id']) ? (int)$data['user_id'] : 0;

if (empty($userId)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Required parameter (user_id) is missing."]);
    exit();
}

try {
    // Get or create wallet
    $stmt = $conn->prepare("SELECT id, balance FROM wallets WHERE user_id = ?");
    $stmt->execute([$userId]);
    $wallet = $stmt->fetch();
    
    if (!$wallet) {
        $stmtIns = $conn->prepare("INSERT INTO wallets (user_id, balance) VALUES (?, 0.00)");
        $stmtIns->execute([$userId]);
        $walletId = (int)$conn->lastInsertId();
        $balance = 0.00;
    } else {
        $walletId = (int)$wallet['id'];
        $balance = (float)$wallet['balance'];
    }

    // Get total commissions earned
    $stmtEarned = $conn->prepare("SELECT SUM(amount) as total FROM commissions WHERE recipient_id = ?");
    $stmtEarned->execute([$userId]);
    $totalEarned = (float)$stmtEarned->fetch()['total'] ?? 0.00;

    // Get transaction history
    $stmtTx = $conn->prepare("SELECT amount, type, description, created_at FROM wallet_transactions WHERE wallet_id = ? ORDER BY id DESC");
    $stmtTx->execute([$walletId]);
    $transactions = $stmtTx->fetchAll();

    echo json_encode([
        "status" => "success",
        "balance" => $balance,
        "total_earned" => $totalEarned,
        "transactions" => $transactions
    ]);

} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
