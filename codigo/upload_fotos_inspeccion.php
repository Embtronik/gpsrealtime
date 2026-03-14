<?php
/**
 * upload_fotos_inspeccion.php
 * ──────────────────────────────────────────────────────────────
 * Recibe fotos de una inspección y las almacena en el servidor.
 *
 * POST multipart/form-data:
 *   inspeccion_id  int         ID de la inspección
 *   fotos[]        file(s)     Imágenes (JPEG, PNG, GIF, WebP)
 *
 * Requiere sesión activa (api_guard.php).
 * ──────────────────────────────────────────────────────────────
 */
require_once __DIR__ . '/api_guard.php';

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Método no permitido']);
    exit;
}

$inspeccion_id = isset($_POST['inspeccion_id']) ? (int)$_POST['inspeccion_id'] : 0;
if ($inspeccion_id <= 0) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'ID de inspección inválido']);
    exit;
}

if (empty($_FILES['fotos']) || !is_array($_FILES['fotos']['name'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'No se recibieron archivos']);
    exit;
}

require __DIR__ . '/coneccion.php';

// Verificar que la inspección existe
$stmtCheck = $conn->prepare('SELECT id FROM inspeccion WHERE id = :id LIMIT 1');
$stmtCheck->execute([':id' => $inspeccion_id]);
if (!$stmtCheck->fetch()) {
    http_response_code(404);
    echo json_encode(['success' => false, 'message' => 'Inspección no encontrada']);
    exit;
}

// Construir la ruta de destino
$uploadBase = realpath(__DIR__ . '/../uploads/inspecciones');
if ($uploadBase === false) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Directorio de subida no encontrado']);
    exit;
}
$uploadDir = $uploadBase . DIRECTORY_SEPARATOR . $inspeccion_id . DIRECTORY_SEPARATOR;

if (!is_dir($uploadDir)) {
    if (!mkdir($uploadDir, 0755, true)) {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'No se pudo crear el directorio de subida']);
        exit;
    }
}

$allowedMimes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
$maxSizeBytes = 10 * 1024 * 1024; // 10 MB por archivo
$maxFiles     = 20;

$files  = $_FILES['fotos'];
$count  = min(count($files['name']), $maxFiles);
$saved  = [];
$errors = [];

$stmtInsert = $conn->prepare(
    'INSERT INTO inspeccion_foto (inspeccion_id, filename, original_name) VALUES (:iid, :fname, :oname)'
);

for ($i = 0; $i < $count; $i++) {
    if ($files['error'][$i] !== UPLOAD_ERR_OK) {
        $errors[] = "Archivo #" . ($i + 1) . ": error de subida (código " . $files['error'][$i] . ')';
        continue;
    }
    if ($files['size'][$i] > $maxSizeBytes) {
        $errors[] = "'" . basename($files['name'][$i]) . "' excede el límite de 10 MB";
        continue;
    }

    // Validar tipo MIME real (no confiar solo en la extensión)
    $finfo = new finfo(FILEINFO_MIME_TYPE);
    $mime  = $finfo->file($files['tmp_name'][$i]);
    if (!in_array($mime, $allowedMimes, true)) {
        $errors[] = "'" . basename($files['name'][$i]) . "': tipo no permitido";
        continue;
    }

    // Generar nombre de archivo seguro y único
    $ext     = strtolower(pathinfo($files['name'][$i], PATHINFO_EXTENSION));
    $safeExt = in_array($ext, ['jpg', 'jpeg', 'png', 'gif', 'webp'], true) ? $ext : 'jpg';
    $filename = bin2hex(random_bytes(16)) . '.' . $safeExt;
    $destPath = $uploadDir . $filename;

    if (!move_uploaded_file($files['tmp_name'][$i], $destPath)) {
        $errors[] = "No se pudo guardar '" . basename($files['name'][$i]) . "'";
        continue;
    }

    $stmtInsert->execute([
        ':iid'   => $inspeccion_id,
        ':fname' => $filename,
        ':oname' => mb_substr(basename($files['name'][$i]), 0, 255),
    ]);
    $saved[] = $filename;
}

echo json_encode([
    'success' => true,
    'saved'   => count($saved),
    'errors'  => $errors,
], JSON_UNESCAPED_UNICODE);
