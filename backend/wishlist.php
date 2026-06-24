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
    $stmt = $db->prepare('
        SELECT w.id, w.created_at, d.*
        FROM wishlist w
        JOIN destinations d ON w.destination_id = d.id
        WHERE w.user_id = ?
        ORDER BY w.created_at DESC
    ');
    $stmt->bind_param('i', $auth['user_id']);
    $stmt->execute();
    echo json_encode($stmt->get_result()->fetch_all(MYSQLI_ASSOC));

} elseif ($method === 'POST') {
    $body   = json_decode(file_get_contents('php://input'), true);
    $destId = intval($body['destination_id'] ?? 0);

    $stmt = $db->prepare('SELECT id FROM wishlist WHERE user_id = ? AND destination_id = ?');
    $stmt->bind_param('ii', $auth['user_id'], $destId);
    $stmt->execute();
    if ($stmt->get_result()->num_rows > 0) {
        echo json_encode(['error' => 'Already in wishlist']);
        exit();
    }

    $stmt = $db->prepare('INSERT INTO wishlist (user_id, destination_id) VALUES (?, ?)');
    $stmt->bind_param('ii', $auth['user_id'], $destId);
    $stmt->execute();
    echo json_encode(['success' => true]);

} elseif ($method === 'DELETE') {
    $id   = $_GET['id'] ?? '';
    $stmt = $db->prepare('DELETE FROM wishlist WHERE id = ? AND user_id = ?');
    $stmt->bind_param('ii', $id, $auth['user_id']);
    $stmt->execute();
    echo json_encode(['success' => true]);
}