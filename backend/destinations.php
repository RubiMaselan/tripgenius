<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];
$search = $_GET['search'] ?? '';
$id     = $_GET['id'] ?? '';
$db     = getDB();

if ($method === 'GET' && $id) {
    $stmt = $db->prepare('SELECT * FROM destinations WHERE id = ?');
    $stmt->bind_param('i', $id);
    $stmt->execute();
    $dest = $stmt->get_result()->fetch_assoc();

    if (!$dest) { echo json_encode(['error' => 'Not found']); exit(); }

    $stmt = $db->prepare('SELECT * FROM attractions WHERE destination_id = ?');
    $stmt->bind_param('i', $id);
    $stmt->execute();
    $dest['attractions'] = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);

    $stmt = $db->prepare('SELECT * FROM accommodation WHERE destination_id = ?');
    $stmt->bind_param('i', $id);
    $stmt->execute();
    $dest['accommodation'] = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);

    echo json_encode($dest);

} elseif ($method === 'GET') {
    if ($search) {
        $like = "%$search%";
        $stmt = $db->prepare('SELECT * FROM destinations WHERE name LIKE ? OR country LIKE ? OR category LIKE ?');
        $stmt->bind_param('sss', $like, $like, $like);
    } else {
        $stmt = $db->prepare('SELECT * FROM destinations');
    }
    $stmt->execute();
    echo json_encode($stmt->get_result()->fetch_all(MYSQLI_ASSOC));
}