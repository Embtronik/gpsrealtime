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

if ($idusuarioCredenciales <= 0) {
    http_response_code(422);
    echo json_encode(['success' => false, 'message' => 'ID de credencial inválido.']);
    exit;
}

// Prevent admin from disabling their own account
$myUserId = (int)($_SESSION['user_id'] ?? 0);
if ($myUserId > 0) {
    $chkStmt = $conn->prepare(
        "SELECT idusuarioCredenciales FROM usuarioCredenciales WHERE usuario_idusuario = :uid LIMIT 1"
    );
    $chkStmt->bindValue(':uid', $myUserId, PDO::PARAM_INT);
    $chkStmt->execute();
    $chkRow = $chkStmt->fetch(PDO::FETCH_ASSOC);
    if ($chkRow && (int)$chkRow['idusuarioCredenciales'] === $idusuarioCredenciales) {
        http_response_code(422);
        echo json_encode(['success' => false, 'message' => 'No puede desactivar su propia cuenta.']);
        exit;
    }
}

try {
    $stmt = $conn->prepare("CALL SP_EliminarUsuarioLogico(:id)");
    $stmt->bindValue(':id', $idusuarioCredenciales, PDO::PARAM_INT);
    $stmt->execute();
    do { $stmt->closeCursor(); } while ($stmt->nextRowset());
    echo json_encode(['success' => true, 'message' => 'Usuario desactivado correctamente.']);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Error al desactivar usuario: ' . $e->getMessage()]);
}
