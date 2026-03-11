<?php
require_once __DIR__ . '/api_guard.php';

header('Content-Type: application/json; charset=utf-8');

if ((int)$_SESSION['rol_usuario'] !== 1) {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Acceso denegado. Se requiere rol de administrador.']);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Método no permitido.']);
    exit;
}

require 'coneccion.php';

$data = json_decode(file_get_contents('php://input'), true);
if (json_last_error() !== JSON_ERROR_NONE || !is_array($data)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Formato JSON inválido.']);
    exit;
}

$idusuarioCredenciales = (int)($data['idusuarioCredenciales'] ?? 0);
$plainPassword         = (string)($data['password'] ?? '');

if ($idusuarioCredenciales <= 0) {
    http_response_code(422);
    echo json_encode(['success' => false, 'message' => 'ID de credencial inválido.']);
    exit;
}

if (strlen($plainPassword) < 8 || strlen($plainPassword) > 72) {
    http_response_code(422);
    echo json_encode(['success' => false, 'message' => 'La contraseña debe tener entre 8 y 72 caracteres.']);
    exit;
}

$hashedPassword = password_hash($plainPassword, PASSWORD_BCRYPT);

try {
    $stmt = $conn->prepare("CALL SP_CambiarPasswordUsuario(:id, :hash)");
    $stmt->bindValue(':id',   $idusuarioCredenciales, PDO::PARAM_INT);
    $stmt->bindValue(':hash', $hashedPassword);
    $stmt->execute();
    do { $stmt->closeCursor(); } while ($stmt->nextRowset());
    echo json_encode(['success' => true, 'message' => 'Contraseña actualizada correctamente.']);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Error al cambiar contraseña: ' . $e->getMessage()]);
}
