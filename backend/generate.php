<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['error' => 'POST method required']);
    exit();
}

$body = json_decode(file_get_contents('php://input'), true);

// Get token from body or query string
$token = $body['token'] ?? $_GET['token'] ?? null;
if (!$token) {
    echo json_encode(['error' => 'Unauthorized', 'debug' => 'No token']);
    exit();
}
$user = verifyJWT($token);
if (!$user) {
    echo json_encode(['error' => 'Unauthorized', 'debug' => 'Invalid token']);
    exit();
}

$destination = $body['destination'] ?? '';
$days        = intval($body['days'] ?? 1);
$interests   = implode(', ', $body['interests'] ?? ['General sightseeing']);
$budget      = $body['budget'] ?? 'Medium';

if (empty($destination)) {
    echo json_encode(['error' => 'Destination is required']);
    exit();
}

$prompt = "You are a travel expert. Create a detailed {$days}-day travel itinerary for {$destination}.
Traveler interests: {$interests}.
Budget level: {$budget}.

Return ONLY a valid JSON object in this exact format, no markdown, no extra text:
{
  \"destination\": \"{$destination}\",
  \"days\": {$days},
  \"plan\": [
    {
      \"day\": 1,
      \"morning\": \"Detailed morning activity\",
      \"afternoon\": \"Detailed afternoon activity\",
      \"evening\": \"Detailed evening activity\"
    }
  ]
}

Generate exactly {$days} day objects. Be specific with place names and activities.";

$payload = [
    'contents' => [['parts' => [['text' => $prompt]]]],
    'generationConfig' => ['temperature' => 0.7, 'maxOutputTokens' => 2048]
];

$ch = curl_init(GEMINI_URL . '?key=' . GEMINI_API_KEY);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($httpCode !== 200) {
    echo json_encode(['error' => 'Gemini API error', 'details' => $response]);
    exit();
}

$geminiData = json_decode($response, true);
$text = $geminiData['candidates'][0]['content']['parts'][0]['text'] ?? '';
$text = preg_replace('/```json\s*/i', '', $text);
$text = preg_replace('/```\s*/i', '', $text);
$text = trim($text);

$itinerary = json_decode($text, true);
if (!$itinerary) {
    echo json_encode(['error' => 'Failed to parse itinerary', 'raw' => $text]);
    exit();
}

$itinerary['id']         = uniqid('trip_', true);
$itinerary['created_at'] = date('c');

// Save to MySQL
$db           = getDB();
$id           = $itinerary['id'];
$userId       = $user['user_id'];
$dest         = $itinerary['destination'];
$plan         = json_encode($itinerary['plan']);
$interestsStr = implode(',', $body['interests'] ?? []);

$stmt = $db->prepare('INSERT INTO trips (id, user_id, destination, days, interests, budget, plan) VALUES (?,?,?,?,?,?,?)');
$stmt->bind_param('siissss', $id, $userId, $dest, $days, $interestsStr, $budget, $plan);
$stmt->execute();

echo json_encode($itinerary);
