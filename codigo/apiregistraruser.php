<?php
require_once __DIR__ . '/api_guard.php';

header('Content-Type: application/json; charset=utf-8');

// ─── Solo administradores (rol 1) pueden registrar nuevos usuarios ───────────
if ((int)$_SESSION['rol_usuario'] !== 1) {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Acceso denegado. Se requiere rol de administrador.']);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Método no permitido']);
    exit;
}

require __DIR__ . '/coneccion.php';

$jsonData = file_get_contents('php://input');
$data = json_decode($jsonData, true);

if (json_last_error() !== JSON_ERROR_NONE || !is_array($data)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Formato JSON inválido']);
    exit;
}

// ─── Validación y sanitización de inputs ─────────────────────────────────────
$errors = [];

$name               = trim((string)($data['name'] ?? ''));
$email              = trim(strtolower((string)($data['email'] ?? '')));
$tipoIdentificacion = (int)($data['tipoIdentificacion'] ?? 0);
$identificacion     = trim((string)($data['identificacion'] ?? ''));
$direccion          = trim((string)($data['direccion'] ?? ''));
$telefono           = trim((string)($data['telefono'] ?? ''));
$username           = trim((string)($data['username'] ?? ''));
$plainPassword      = (string)($data['password'] ?? '');
$rol                = (int)($data['rol'] ?? 0);

if ($name === '' || strlen($name) > 255)           { $errors[] = 'Nombre inválido (máx 255 caracteres).'; }
if (!filter_var($email, FILTER_VALIDATE_EMAIL))    { $errors[] = 'Email inválido.'; }
if ($tipoIdentificacion <= 0)                      { $errors[] = 'Tipo de identificación inválido.'; }
if ($identificacion === '' || strlen($identificacion) > 45) { $errors[] = 'Identificación inválida.'; }
if ($direccion === '' || strlen($direccion) > 255)  { $errors[] = 'Dirección inválida.'; }
if (!preg_match('/^[\d\s+\-()]{7,20}$/', $telefono)) { $errors[] = 'Teléfono inválido.'; }
if (!preg_match('/^[a-zA-Z0-9_]{3,45}$/', $username)) { $errors[] = 'Username inválido (solo alfanumérico y _, 3-45 chars).'; }
if (strlen($plainPassword) < 8 || strlen($plainPassword) > 72) { $errors[] = 'La contraseña debe tener entre 8 y 72 caracteres.'; }
// Evitar escalada de privilegios: el rol asignado no puede ser superior al del admin actual
$validRoles = [1, 3, 4];
if (!in_array($rol, $validRoles, true)) { $errors[] = 'Rol inválido.'; }

if (!empty($errors)) {
    http_response_code(422);
    echo json_encode(['success' => false, 'message' => implode(' ', $errors)]);
    exit;
}

// ─── Hash de contraseña con bcrypt ───────────────────────────────────────────
$hashedPassword = password_hash($plainPassword, PASSWORD_BCRYPT);

try {
    $stmt = $conn->prepare(
        "CALL insertar_user(:name, :email, :identificacion, :direccion, :telefono, :tipoIdentificacion, :username, :password, :rol)"
    );
    $stmt->bindValue(':name',               $name);
    $stmt->bindValue(':email',              $email);
    $stmt->bindValue(':identificacion',     $identificacion);
    $stmt->bindValue(':direccion',          $direccion);
    $stmt->bindValue(':telefono',           $telefono);
    $stmt->bindValue(':tipoIdentificacion', $tipoIdentificacion, PDO::PARAM_INT);
    $stmt->bindValue(':username',           $username);
    $stmt->bindValue(':password',           $hashedPassword);
    $stmt->bindValue(':rol',                $rol, PDO::PARAM_INT);
    $stmt->execute();

    echo json_encode(['success' => true]);
} catch (PDOException $e) {
    error_log('apiregistraruser error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Error al registrar el usuario.']);
}
