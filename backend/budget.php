<?php
require_once 'config.php';

$token = $_GET['token'] ?? null;
$auth  = $token ? verifyJWT($token) : null;
if (!$auth) {
    echo json_encode(['error' => 'Unauthorized']);
    exit();
}

$method = $_SERVER['REQUEST_METHOD'];
$db     = getDB();

if ($method === 'GET') {
    $tripId = $_GET['trip_id'] ?? '';
    $stmt   = $db->prepare('SELECT * FROM budgets WHERE trip_id = ? AND user_id = ?');
    $stmt->bind_param('si', $tripId, $auth['user_id']);
    $stmt->execute();
    $budget = $stmt->get_result()->fetch_assoc();
    echo json_encode($budget ?? (object)[]);

} elseif ($method === 'POST') {
    $body          = json_decode(file_get_contents('php://input'), true);
    $tripId        = $body['trip_id'] ?? '';
    $accommodation = floatval($body['accommodation'] ?? 0);
    $food          = floatval($body['food'] ?? 0);
    $transport     = floatval($body['transport'] ?? 0);
    $attractions   = floatval($body['attractions'] ?? 0);
    $others        = floatval($body['others'] ?? 0);

    $stmt = $db->prepare('SELECT id FROM budgets WHERE trip_id = ? AND user_id = ?');
    $stmt->bind_param('si', $tripId, $auth['user_id']);
    $stmt->execute();

    if ($stmt->get_result()->num_rows > 0) {
        $stmt = $db->prepare('UPDATE budgets SET accommodation=?, food=?, transport=?, attractions=?, others=? WHERE trip_id=? AND user_id=?');
        $stmt->bind_param('dddddsi', $accommodation, $food, $transport, $attractions, $others, $tripId, $auth['user_id']);
    } else {
        $stmt = $db->prepare('INSERT INTO budgets (trip_id, user_id, accommodation, food, transport, attractions, others) VALUES (?,?,?,?,?,?,?)');
        $stmt->bind_param('siddddд', $tripId, $auth['user_id'], $accommodation, $food, $transport, $attractions, $others);
    }
    $stmt->execute();
    echo json_encode(['success' => true]);
}
