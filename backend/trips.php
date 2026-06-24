<?php
require_once 'config.php';

$token = $_GET['token'] ?? null;
$auth  = $token ? verifyJWT($token) : null;
if (!$auth) {
    echo json_encode(['error' => 'Unauthorized', 'debug' => 'No token found']);
    exit();
}

$method = $_SERVER['REQUEST_METHOD'];
$db     = getDB();

if ($method === 'GET') {
    $stmt = $db->prepare('SELECT * FROM trips WHERE user_id = ? ORDER BY created_at DESC');
    $stmt->bind_param('i', $auth['user_id']);
    $stmt->execute();
    $trips = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    foreach ($trips as &$trip) {
        $trip['plan'] = json_decode($trip['plan'], true);
    }
    echo json_encode($trips);

} elseif ($method === 'POST') {
    $body      = json_decode(file_get_contents('php://input'), true);
    $id        = $body['id'] ?? uniqid('trip_', true);
    $dest      = $body['destination'] ?? '';
    $days      = intval($body['days'] ?? 1);
    $plan      = json_encode($body['plan'] ?? []);
    $interests = implode(',', $body['interests'] ?? []);
    $budget    = $body['budget'] ?? 'Medium';

    $stmt = $db->prepare('INSERT INTO trips (id, user_id, destination, days, interests, budget, plan) VALUES (?,?,?,?,?,?,?)');
    $stmt->bind_param('siissss', $id, $auth['user_id'], $dest, $days, $interests, $budget, $plan);
    $stmt->execute();
    echo json_encode(['success' => true, 'id' => $id]);

} elseif ($method === 'DELETE') {
    $id   = $_GET['id'] ?? '';
    $stmt = $db->prepare('DELETE FROM trips WHERE id = ? AND user_id = ?');
    $stmt->bind_param('si', $id, $auth['user_id']);
    $stmt->execute();
    echo json_encode(['success' => true]);
}