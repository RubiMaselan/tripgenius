<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];
$body   = json_decode(file_get_contents('php://input'), true);
$action = $_GET['action'] ?? '';

if ($method === 'POST' && $action === 'register') {
    $name     = trim($body['name'] ?? '');
    $email    = trim($body['email'] ?? '');
    $password = trim($body['password'] ?? '');

    if (!$name || !$email || !$password) {
        echo json_encode(['error' => 'All fields are required']);
        exit();
    }
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        echo json_encode(['error' => 'Invalid email format']);
        exit();
    }

    $db   = getDB();
    $stmt = $db->prepare('SELECT id FROM users WHERE email = ?');
    $stmt->bind_param('s', $email);
    $stmt->execute();
    if ($stmt->get_result()->num_rows > 0) {
        echo json_encode(['error' => 'Email already registered']);
        exit();
    }

    $hash = password_hash($password, PASSWORD_BCRYPT);
    $stmt = $db->prepare('INSERT INTO users (name, email, password) VALUES (?, ?, ?)');
    $stmt->bind_param('sss', $name, $email, $hash);
    $stmt->execute();
    $userId = $db->insert_id;
    $token  = generateJWT($userId, $email);

    echo json_encode([
        'success' => true,
        'token'   => $token,
        'user'    => ['id' => $userId, 'name' => $name, 'email' => $email]
    ]);

} elseif ($method === 'POST' && $action === 'login') {
    $email    = trim($body['email'] ?? '');
    $password = trim($body['password'] ?? '');

    if (!$email || !$password) {
        echo json_encode(['error' => 'Email and password required']);
        exit();
    }

    $db   = getDB();
    $stmt = $db->prepare('SELECT id, name, email, password FROM users WHERE email = ?');
    $stmt->bind_param('s', $email);
    $stmt->execute();
    $user = $stmt->get_result()->fetch_assoc();

    if (!$user || !password_verify($password, $user['password'])) {
        echo json_encode(['error' => 'Invalid email or password']);
        exit();
    }

    $token = generateJWT($user['id'], $user['email']);
    echo json_encode([
        'success' => true,
        'token'   => $token,
        'user'    => ['id' => $user['id'], 'name' => $user['name'], 'email' => $user['email']]
    ]);

} elseif ($method === 'GET' && $action === 'profile') {
    $auth = getAuthUser();
    $db   = getDB();
    $stmt = $db->prepare('SELECT id, name, email, created_at FROM users WHERE id = ?');
    $stmt->bind_param('i', $auth['user_id']);
    $stmt->execute();
    echo json_encode($stmt->get_result()->fetch_assoc());

} elseif ($method === 'PUT' && $action === 'profile') {
    $auth = getAuthUser();
    $name = trim($body['name'] ?? '');
    if (!$name) { echo json_encode(['error' => 'Name required']); exit(); }
    $db   = getDB();
    $stmt = $db->prepare('UPDATE users SET name = ? WHERE id = ?');
    $stmt->bind_param('si', $name, $auth['user_id']);
    $stmt->execute();
    echo json_encode(['success' => true]);

} else {
    echo json_encode(['error' => 'Invalid action']);
}
