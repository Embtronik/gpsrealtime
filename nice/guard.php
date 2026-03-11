<?php
/**
 * Guard para el panel de administración /nice/
 * Se ejecuta automáticamente vía auto_prepend_file en .htaccess.
 *
 * Roles permitidos en el panel:
 *  1 = Admin
 *  3 = Comercial
 *  5 = Supervisor
 */

// Solo proteger archivos HTML/PHP en el directorio raíz de /nice/
// Los assets (js, css, imágenes, vendor...) no son PHP y no pasan por aquí
$currentFile = basename($_SERVER['SCRIPT_FILENAME'] ?? '');
$currentExt  = strtolower(pathinfo($currentFile, PATHINFO_EXTENSION));

// No aplicar guard a este mismo archivo ni a non-html/php
if ($currentFile === 'guard.php' || !in_array($currentExt, ['html', 'php'], true)) {
    return;
}

// Solo proteger archivos que estén directamente en /nice/ (no subdirectorios)
$niceDir    = realpath(__DIR__);
$scriptDir  = realpath(dirname($_SERVER['SCRIPT_FILENAME'] ?? ''));
if ($niceDir === false || $scriptDir === false || $scriptDir !== $niceDir) {
    return;
}

// ─── Verificar sesión ────────────────────────────────────────────────────────
if (session_status() === PHP_SESSION_NONE) {
    ini_set('session.cookie_httponly', '1');
    ini_set('session.cookie_samesite', 'Lax');
    session_start();
}

// Roles permitidos en el panel /nice/: 1=Admin, 3=Comercial, 5=Supervisor
$allowedRoles = [1, 3, 5];
if (empty($_SESSION['user_id']) || !in_array((int)$_SESSION['rol_usuario'], $allowedRoles, true)) {
    header('Location: ../index.html');
    exit;
}
