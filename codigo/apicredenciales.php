<?php
// ─── Secure session cookie flags (ANTES de session_start) ───────────────────
ini_set('session.cookie_httponly', '1');
ini_set('session.cookie_samesite', 'Lax');
if (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') {
    ini_set('session.cookie_secure', '1');
}
session_start();

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Método no permitido']);
    exit;
}

require __DIR__ . '/coneccion.php';

// ─── Rate limiting por IP (max 10 intentos fallidos en 15 min) ───────────────
function _checkRateLimit(string $ip): bool {
    $dir = sys_get_temp_dir() . DIRECTORY_SEPARATOR . 'gps_rl';
    if (!is_dir($dir)) { @mkdir($dir, 0700, true); }
    $file    = $dir . DIRECTORY_SEPARATOR . md5($ip) . '.json';
    $window  = 900; // 15 minutos
    $maxAtt  = 10;
    $now     = time();
    $attempts = [];
    if (file_exists($file)) {
        $raw = @file_get_contents($file);
        $decoded = $raw !== false ? @json_decode($raw, true) : null;
        if (is_array($decoded)) {
            $attempts = array_values(array_filter($decoded, fn($t) => $t > ($now - $window)));
        }
    }
    if (count($attempts) >= $maxAtt) { return false; }
    $attempts[] = $now;
    @file_put_contents($file, json_encode($attempts), LOCK_EX);
    return true;
}

function _clearRateLimit(string $ip): void {
    $file = sys_get_temp_dir() . DIRECTORY_SEPARATOR . 'gps_rl' . DIRECTORY_SEPARATOR . md5($ip) . '.json';
    if (file_exists($file)) { @unlink($file); }
}

$clientIp = $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';

try {
    $raw  = file_get_contents('php://input');
    $data = json_decode($raw, true);

    if (!is_array($data)) {
        $data = [];
        $ct = isset($_SERVER['CONTENT_TYPE']) ? strtolower($_SERVER['CONTENT_TYPE']) : '';
        if (strpos($ct, 'application/x-www-form-urlencoded') !== false) {
            parse_str($raw, $data);
            if (!is_array($data)) $data = [];
        }
    }

    $usuario  = trim((string)($data['usuarioEncoded'] ?? $data['usuario']  ?? ''));
    $password = trim((string)($data['passwordEncoded'] ?? $data['password'] ?? ''));

    if ($usuario === '' || $password === '') {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Usuario/contraseña requeridos']);
        exit;
    }

    // ─── Rate limit check ────────────────────────────────────────────────────
    if (!_checkRateLimit($clientIp)) {
        http_response_code(429);
        echo json_encode(['success' => false, 'message' => 'Demasiados intentos fallidos. Espere 15 minutos.']);
        exit;
    }

    // ─── Obtener usuario + hash almacenado (sin comparar en SQL) ─────────────
    $stmt = $conn->prepare("
        SELECT uc.password        AS stored_password,
               u.idusuario        AS id_usuario,
               u.nombre           AS nombre_usuario,
               ur.p_rol_idp_rol   AS rol_usuario,
               r.descripcion      AS p_rol_descripcion
        FROM   usuarioCredenciales uc
        JOIN   usuario     u  ON u.idusuario          = uc.usuario_idusuario
        JOIN   usuariorol  ur ON u.idusuario          = ur.usuario_idusuario
        JOIN   p_rol       r  ON r.idp_rol            = ur.p_rol_idp_rol
        WHERE  uc.username        = :usuario
          AND  uc.estadoRegistro  = 1
          AND  ur.p_rol_idp_rol   IN (1, 2, 3, 4, 5)
        ORDER  BY ur.idusuarioRol DESC
        LIMIT  1
    ");
    $stmt->execute([':usuario' => $usuario]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$row) {
        // Respuesta genérica para no filtrar si el usuario existe
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'Credenciales inválidas']);
        exit;
    }

    // ─── Verificar contraseña: bcrypt (nuevo) o texto plano (migración) ───────
    $storedHash = $row['stored_password'];
    $isValid    = false;

    if (strlen($storedHash) >= 60 && strncmp($storedHash, '$2', 2) === 0) {
        // Hash bcrypt — verificar con password_verify
        $isValid = password_verify($password, $storedHash);
    } else {
        // Contraseña en texto plano (legado) — comparación segura y migración automática a bcrypt
        $isValid = hash_equals($storedHash, $password);
        if ($isValid) {
            $newHash = password_hash($password, PASSWORD_BCRYPT);
            $upd = $conn->prepare(
                "UPDATE usuarioCredenciales SET password = :hash WHERE username = :user AND estadoRegistro = 1"
            );
            $upd->execute([':hash' => $newHash, ':user' => $usuario]);
        }
    }

    if (!$isValid) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'Credenciales inválidas']);
        exit;
    }

    // ─── Login exitoso: limpiar rate-limit y guardar sesión ──────────────────
    _clearRateLimit($clientIp);

    $_SESSION['user_id']     = (int)$row['id_usuario'];
    $_SESSION['usuario']     = (string)$row['nombre_usuario'];
    $_SESSION['rol_usuario'] = (int)$row['rol_usuario'];
    session_write_close();

    $out = [
        'id_usuario'        => (int)$row['id_usuario'],
        'nombre_usuario'    => (string)$row['nombre_usuario'],
        'rol_usuario'       => (int)$row['rol_usuario'],
        'p_rol_descripcion' => (string)$row['p_rol_descripcion'],
    ];

    http_response_code(200);
    echo json_encode(array_merge(['success' => true], $out), JSON_UNESCAPED_UNICODE);

} catch (Throwable $t) {
    error_log('apicredenciales error: ' . $t->getMessage() . ' line ' . $t->getLine());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Error interno del servidor'
    ]);
}
