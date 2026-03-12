<?php
require_once __DIR__ . '/api_guard.php';

header('Content-Type: application/json; charset=utf-8');

if ((int)$_SESSION['rol_usuario'] !== 1) {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Acceso denegado. Se requiere rol de administrador.']);
    exit;
}

$raw  = file_get_contents('php://input');
$data = json_decode($raw, true);

$idusuario             = isset($data['idusuario'])             ? (int)$data['idusuario']             : 0;
$idusuarioCredenciales = isset($data['idusuarioCredenciales']) ? (int)$data['idusuarioCredenciales'] : 0;
$nombre                = isset($data['nombre'])                ? trim($data['nombre'])                : '';
$email                 = isset($data['email'])                 ? trim($data['email'])                 : '';
$id_rol                = isset($data['id_rol'])                ? (int)$data['id_rol']                 : 0;
$password              = isset($data['password'])              ? $data['password']                    : '';

if (!$idusuario || !$idusuarioCredenciales || !$nombre || !$id_rol) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Datos incompletos.']);
    exit;
}

// No se puede editar el usuario administrador (rol 1) ni asignar rol de cliente (rol 2)
if ($id_rol === 2) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'No se puede asignar el rol de cliente.']);
    exit;
}

$passwordHash = null;
if ($password !== '') {
    if (strlen($password) < 8 || strlen($password) > 72) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'La contraseña debe tener entre 8 y 72 caracteres.']);
        exit;
    }
    $passwordHash = password_hash($password, PASSWORD_BCRYPT);
}

require 'coneccion.php';

try {
    // Verify target user is not admin (rol 1) to prevent modification
    $check = $conn->prepare(
        "SELECT ur.p_rol_idp_rol FROM usuarioCredenciales uc
         JOIN usuariorol ur ON ur.usuario_idusuario = uc.usuario_idusuario
         WHERE uc.idusuarioCredenciales = ? LIMIT 1"
    );
    $check->execute([$idusuarioCredenciales]);
    $row = $check->fetch(PDO::FETCH_ASSOC);
    $check->closeCursor();

    if ($row && (int)$row['p_rol_idp_rol'] === 1) {
        http_response_code(403);
        echo json_encode(['success' => false, 'message' => 'El usuario administrador no puede ser modificado.']);
        exit;
    }

    $stmt = $conn->prepare("CALL SP_EditarUsuarioAcceso(?, ?, ?, ?, ?, ?)");
    $stmt->execute([$idusuario, $idusuarioCredenciales, $nombre, $email, $id_rol, $passwordHash]);
    do { $stmt->closeCursor(); } while ($stmt->nextRowset());

    echo json_encode(['success' => true, 'message' => 'Usuario actualizado correctamente.']);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Error al actualizar: ' . $e->getMessage()]);
}
