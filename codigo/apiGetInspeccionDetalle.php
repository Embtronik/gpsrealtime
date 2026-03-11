<?php
require_once __DIR__ . '/api_guard.php';

header('Content-Type: application/json; charset=utf-8');

// Admin (1), Supervisor (5) pueden ver cualquier inspección
$allowedRoles = [1, 5];
if (!in_array((int)$_SESSION['rol_usuario'], $allowedRoles, true)) {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Acceso denegado']);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Método no permitido']);
    exit;
}

require __DIR__ . '/coneccion.php';

$raw  = file_get_contents('php://input');
$data = json_decode($raw, true) ?: [];
$id   = (int)($data['id'] ?? 0);

if ($id <= 0) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'ID de inspección requerido']);
    exit;
}

try {
    // Encabezado de la inspección
    $stmt = $conn->prepare("SELECT * FROM inspeccion WHERE id = :id");
    $stmt->execute([':id' => $id]);
    $header = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$header) {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'Inspección no encontrada']);
        exit;
    }

    // Ítems con nombre de categoría e ítem, ordenados
    $stmtItems = $conn->prepare("
        SELECT  ii.id,
                ii.item_id,
                ci.nombre   AS item_nombre,
                cc.nombre   AS categoria_nombre,
                cc.orden    AS categoria_orden,
                ci.orden    AS item_orden,
                ii.estado,
                ii.observaciones
        FROM    inspeccion_item ii
        JOIN    checklist_item     ci ON ci.id = ii.item_id
        JOIN    checklist_categoria cc ON cc.id = ci.categoria_id
        WHERE   ii.inspeccion_id = :id
        ORDER BY cc.orden ASC, ci.orden ASC
    ");
    $stmtItems->execute([':id' => $id]);
    $items = $stmtItems->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'header'  => $header,
        'items'   => $items,
    ], JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {
    error_log('apiGetInspeccionDetalle: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Error interno del servidor']);
}
