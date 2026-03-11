<?php
declare(strict_types=1);

require_once __DIR__ . '/api_guard.php';

header('Content-Type: application/json; charset=utf-8');

// Permitir solo POST (puedes cambiar a GET si lo prefieres)
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Método no permitido']);
    exit;
}

require_once __DIR__ . '/coneccion.php'; // Debe definir $conn = new PDO(...)

try {
    // Traer categorías activas
    $sqlCategorias = "
        SELECT id, nombre, `orden`
        FROM checklist_categoria
        WHERE activo = 1
        ORDER BY `orden` ASC, id ASC
    ";
    $categorias = $conn->query($sqlCategorias)->fetchAll(PDO::FETCH_ASSOC);

    // Si no hay categorías, responder vacío
    if (!$categorias) {
        echo json_encode([
            'success'     => true,
            'categorias'  => []
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    // Traer ítems activos
    $sqlItems = "
        SELECT id, categoria_id, nombre, `orden`
        FROM checklist_item
        WHERE activo = 1
        ORDER BY categoria_id ASC, `orden` ASC, id ASC
    ";
    $items = $conn->query($sqlItems)->fetchAll(PDO::FETCH_ASSOC);

    // Agrupar ítems por categoria_id
    $itemsPorCategoria = [];
    foreach ($items as $it) {
        $cid = (int)$it['categoria_id'];
        if (!isset($itemsPorCategoria[$cid])) {
            $itemsPorCategoria[$cid] = [];
        }
        $itemsPorCategoria[$cid][] = [
            'id'     => (int)$it['id'],
            'nombre' => $it['nombre'],
            'orden'  => (int)$it['orden']
        ];
    }

    // Armar payload final
    $respCategorias = [];
    foreach ($categorias as $cat) {
        $cid = (int)$cat['id'];
        $respCategorias[] = [
            'id'     => $cid,
            'nombre' => $cat['nombre'],
            'orden'  => (int)$cat['orden'],
            'items'  => $itemsPorCategoria[$cid] ?? []
        ];
    }

    echo json_encode([
        'success'     => true,
        'categorias'  => $respCategorias
    ], JSON_UNESCAPED_UNICODE);

} catch (\PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Error de base de datos', 'detail' => $e->getMessage()]);
} catch (\Throwable $t) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Error interno', 'detail' => $t->getMessage()]);
}
