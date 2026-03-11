<?php

// Reads from env vars when running in Docker; falls back to XAMPP defaults.
$servername = getenv('DB_HOST')     ?: 'localhost';
$username   = getenv('DB_USER')     ?: 'gps';
$password   = getenv('DB_PASSWORD') ?: 'WtQH]Lc@.Wo3ZVc]';
$dbname     = getenv('DB_NAME')     ?: 'mydb';

try {
  $conn = new PDO("mysql:host=$servername;dbname=$dbname;charset=utf8", $username, $password);
  $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
  error_log('DB connection failed: ' . $e->getMessage());
  if (!headers_sent()) { header('Content-Type: application/json; charset=utf-8'); }
  http_response_code(503);
  echo json_encode(['success' => false, 'message' => 'Error interno del servidor']);
  exit;
}

?>