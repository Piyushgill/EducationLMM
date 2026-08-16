<?php
require_once '../db.php';

try {
    $stmt = $conn->prepare("
        SELECT u.id, u.name, u.email, u.phone, u.role, COALESCE(w.balance, 0.00) as balance,
               u.bank_name, u.account_number, u.ifsc_code, u.account_holder_name,
               COALESCE((SELECT SUM(amount) FROM commissions WHERE recipient_id = u.id), 0.00) as total_earned,
               (SELECT p.name FROM user_relations ur JOIN users p ON ur.parent_id = p.id WHERE ur.child_id = u.id AND p.role = 'Distributor' LIMIT 1) as parent_distributor_name
        FROM users u
        LEFT JOIN wallets w ON u.id = w.user_id
        WHERE u.role IN ('Distributor', 'Agent')
        ORDER BY w.balance DESC, u.name ASC
    ");
    $stmt->execute();
    $wallets = $stmt->fetchAll();

    // Get all commission transaction logs for ledger details
    $stmtTx = $conn->prepare("
        SELECT c.id, c.recipient_id, r.name as recipient_name, c.trigger_user_id, t.name as trigger_name, 
               c.order_id, c.amount, c.tier_level, c.created_at
        FROM commissions c
        JOIN users r ON c.recipient_id = r.id
        JOIN users t ON c.trigger_user_id = t.id
        ORDER BY c.id DESC
        LIMIT 200
    ");
    $stmtTx->execute();
    $transactions = $stmtTx->fetchAll();

    echo json_encode([
        "status" => "success",
        "wallets" => $wallets,
        "transactions" => $transactions
    ]);

} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
