<?php
/**
 * migrate_passwords.php
 * ─────────────────────────────────────────────────────────────
 * Script de ejecución única (one-shot) para migrar todas las
 * contraseñas en texto plano de usuarioCredenciales a hashes bcrypt.
 *
 * CÓMO EJECUTAR (desde la raíz del proyecto):
 *   php codigo/migrate_passwords.php
 *   — o bien —
 *   Visita http://localhost/gpsrealtime/codigo/migrate_passwords.php
 *   (solo desde localhost; el .htaccess bloquea acceso externo)
 *
 * SEGURIDAD:
 *   - Solo accesible desde 127.0.0.1 / ::1 (localhost)
 *   - Eliminar este archivo después de ejecutarlo
 * ─────────────────────────────────────────────────────────────
 */

// ─── Restringir a localhost ───────────────────────────────────────────────────
$remoteIp = $_SERVER['REMOTE_ADDR'] ?? 'cli';
if ($remoteIp !== 'cli' && !in_array($remoteIp, ['127.0.0.1', '::1'], true)) {
    http_response_code(403);
    exit('Acceso denegado. Este script solo puede ejecutarse desde localhost.');
}

require __DIR__ . '/coneccion.php';

header('Content-Type: text/plain; charset=utf-8');

// ─── Leer todos los usuarios activos ─────────────────────────────────────────
$stmt = $conn->query(
    "SELECT idusuarioCredenciales AS id, username, password FROM usuarioCredenciales WHERE estadoRegistro = 1"
);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

$total    = count($rows);
$migrated = 0;
$skipped  = 0;
$errors   = 0;

echo "=== Migración de contraseñas a bcrypt ===\n";
echo "Total de registros activos: {$total}\n\n";

$update = $conn->prepare(
    "UPDATE usuarioCredenciales SET password = :hash WHERE idusuarioCredenciales = :id"
);

foreach ($rows as $row) {
    $id       = $row['id'];
    $username = $row['username'];
    $stored   = $row['password'];

    // Si ya tiene formato bcrypt ($2y$... o $2b$...) → saltar
    if (strlen($stored) >= 60 && strncmp($stored, '$2', 2) === 0) {
        echo "[SKIP]    #{$id} {$username}  → ya es bcrypt\n";
        $skipped++;
        continue;
    }

    // Contraseña en texto plano → hashear
    $newHash = password_hash($stored, PASSWORD_BCRYPT);

    try {
        $update->execute([':hash' => $newHash, ':id' => $id]);
        echo "[OK]      #{$id} {$username}  → migrado a bcrypt\n";
        $migrated++;
    } catch (PDOException $e) {
        echo "[ERROR]   #{$id} {$username}  → " . $e->getMessage() . "\n";
        $errors++;
    }
}

echo "\n=== RESULTADO ===\n";
echo "Migrados  : {$migrated}\n";
echo "Ya bcrypt : {$skipped}\n";
echo "Errores   : {$errors}\n";
echo "\n¡IMPORTANTE! Elimina este archivo ahora:\n";
echo "  del " . __FILE__ . "\n";
