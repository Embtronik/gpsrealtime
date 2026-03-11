<?php
require_once __DIR__ . '/api_guard.php';


$api_url = "https://apitellitwatest.aldeamo.com/v1/apikey/text";
$api_key = "TU_API_KEY";
$user_id = "TU_USER_ID";

$data = [
    "from" => "57300XXXXXXX",
    "to" => "57313XXXXXXX",
    "type" => "text",
    "recipient_type" => "individual",
    "text" => ["body" => "¡Hola, este es un mensaje de prueba desde la API!"]
];

$headers = [
    "Content-Type: application/json",
    "ApiKey: $api_key",
    "UserId: $user_id"
];

$ch = curl_init($api_url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));

$response = curl_exec($ch);
curl_close($ch);

echo $response;
?>