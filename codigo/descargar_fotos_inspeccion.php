<?php
/**
 * descargar_fotos_inspeccion.php
 * ──────────────────────────────────────────────────────────────
 * Descarga las fotos de una inspección.
 *
 * GET  ?id={inspeccion_id}
 *   - 1 foto  → entrega el archivo directamente.
 *   - N fotos → entrega un ZIP con todas las imágenes.
 *
 * Requiere sesión activa (api_guard.php).
 * ──────────────────────────────────────────────────────────────
 */
require_once __DIR__ . '/api_guard.php';

$inspeccion_id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
if ($inspeccion_id <= 0) {
    http_response_code(400);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['success' => false, 'message' => 'ID inválido']);
    exit;
}

require __DIR__ . '/coneccion.php';

$stmt = $conn->prepare(
    'SELECT filename, original_name FROM inspeccion_foto WHERE inspeccion_id = :id ORDER BY id ASC'
);
$stmt->execute([':id' => $inspeccion_id]);
$fotos = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (empty($fotos)) {
    http_response_code(404);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['success' => false, 'message' => 'No hay fotos para esta inspección']);
    exit;
}

$uploadBase = realpath(__DIR__ . '/../uploads/inspecciones');
if ($uploadBase === false) {
    http_response_code(500);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['success' => false, 'message' => 'Directorio de fotos no encontrado']);
    exit;
}

// ── Una sola foto: entregar directamente ─────────────────────────────────────
if (count($fotos) === 1) {
    $foto     = $fotos[0];
    $filePath = $uploadBase . DIRECTORY_SEPARATOR . $inspeccion_id . DIRECTORY_SEPARATOR . $foto['filename'];

    if (!is_file($filePath)) {
        http_response_code(404);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['success' => false, 'message' => 'Archivo no encontrado en el servidor']);
        exit;
    }

    $mime = mime_content_type($filePath) ?: 'application/octet-stream';
    header('Content-Type: ' . $mime);
    header('Content-Disposition: attachment; filename="' . rawurlencode($foto['original_name']) . '"');
    header('Content-Length: ' . filesize($filePath));
    header('Cache-Control: private, no-cache');
    readfile($filePath);
    exit;
}

// ── Múltiples fotos: comprimir en ZIP ────────────────────────────────────────
if (!class_exists('ZipArchive')) {
    http_response_code(500);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['success' => false, 'message' => 'ZipArchive no disponible en el servidor']);
    exit;
}

$tmpZip = tempnam(sys_get_temp_dir(), 'insp_') . '.zip';
$zip    = new ZipArchive();

if ($zip->open($tmpZip, ZipArchive::CREATE | ZipArchive::OVERWRITE) !== true) {
    http_response_code(500);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['success' => false, 'message' => 'No se pudo crear el archivo ZIP']);
    exit;
}

// Manejar nombres duplicados dentro del ZIP
$namesUsed = [];
foreach ($fotos as $foto) {
    $filePath = $uploadBase . DIRECTORY_SEPARATOR . $inspeccion_id . DIRECTORY_SEPARATOR . $foto['filename'];
    if (!is_file($filePath)) {
        continue;
    }
    // Evitar colisiones de nombre dentro del ZIP
    $entryName = $foto['original_name'];
    if (isset($namesUsed[$entryName])) {
        $namesUsed[$entryName]++;
        $pi = pathinfo($entryName);
        $entryName = ($pi['filename'] ?? $entryName) . '_' . $namesUsed[$entryName]
                   . (isset($pi['extension']) ? '.' . $pi['extension'] : '');
    } else {
        $namesUsed[$entryName] = 1;
    }
    $zip->addFile($filePath, $entryName);
}
$zip->close();

$zipName = 'fotos_inspeccion_' . $inspeccion_id . '.zip';
header('Content-Type: application/zip');
header('Content-Disposition: attachment; filename="' . $zipName . '"');
header('Content-Length: ' . filesize($tmpZip));
header('Cache-Control: private, no-cache');
header('Pragma: no-cache');
readfile($tmpZip);

// Eliminar el temporal tras enviarlo
@unlink($tmpZip);
exit;
