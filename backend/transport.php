<?php
require_once 'config.php';

$db   = getDB();
$from = $_GET['from'] ?? '';
$to   = $_GET['to'] ?? '';

if ($from && $to) {
    $f    = "%$from%";
    $t    = "%$to%";
    $stmt = $db->prepare('SELECT * FROM transport WHERE from_destination LIKE ? AND to_destination LIKE ?');
    $stmt->bind_param('ss', $f, $t);
} else {
    $stmt = $db->prepare('SELECT * FROM transport');
}
$stmt->execute();
echo json_encode($stmt->get_result()->fetch_all(MYSQLI_ASSOC));