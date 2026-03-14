<?php
/**
 * API Authentication Guard
 * -------------------------
 * Se auto-incluye (auto_prepend o require_once) en todos los endpoints de /codigo/.
 * Rechaza peticiones no autenticadas con HTTP 401.
 *
 * Archivos exentos (no requieren sesión PHP):
 *  - apicredenciales.php  → login endpoint
 *  - apiRecibeWA.php      → webhook Meta/WhatsApp (autenticación por token propio)
 */

// Endpoints públicos: usados por client.html (formulario de registro sin sesión)
$_GUARD_PUBLIC = [
    'apitiposervicio.php',
    'apitipoidentificacion.php',
    'apimetodopago.php',
    'apicomercial.php',
    'apicomoseentero.php',
    'apidatos.php',       // registro de nuevo cliente (formulario público)
];

$_GUARD_EXEMPT = array_merge(['apicredenciales.php', 'apiRecibeWA.php'], $_GUARD_PUBLIC);

if (!in_array(basename($_SERVER['SCRIPT_FILENAME']), $_GUARD_EXEMPT, true)) {

    // Secure session cookie flags (deben setearse ANTES de session_start)
    if (session_status() === PHP_SESSION_NONE) {
        ini_set('session.cookie_httponly', '1');
        ini_set('session.cookie_samesite', 'Lax');
        // Activar Secure solo si la conexión es HTTPS
        if (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') {
            ini_set('session.cookie_secure', '1');
        }
        session_start();
    }

    if (empty($_SESSION['user_id'])) {
        if (!headers_sent()) {
            header('Content-Type: application/json; charset=utf-8');
        }
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'No autorizado. Inicie sesión.']);
        exit;
    }
}
