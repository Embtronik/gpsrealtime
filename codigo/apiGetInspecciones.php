<?php
require_once __DIR__ . '/api_guard.php';

header('Content-Type: application/json; charset=utf-8');

// Solo Admin (1) y Supervisor (5) pueden listar inspecciones
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

$placa   = trim((string)($data['placa']   ?? ''));
$tecnico = trim((string)($data['tecnico'] ?? ''));
$nombre  = trim((string)($data['nombre']  ?? ''));
$desde   = trim((string)($data['desde']   ?? ''));
$hasta   = trim((string)($data['hasta']   ?? ''));

// Validar formatos de fecha para evitar inyección
if ($desde !== '' && !preg_match('/^\d{4}-\d{2}-\d{2}$/', $desde)) { $desde = ''; }
if ($hasta !== '' && !preg_match('/^\d{4}-\d{2}-\d{2}$/', $hasta)) { $hasta = ''; }

$where  = ['1=1'];
$params = [];

if ($placa   !== '') { $where[] = 'i.placa LIKE :placa';           $params[':placa']   = '%' . $placa . '%'; }
if ($tecnico !== '') { $where[] = 'i.tecnico LIKE :tecnico';       $params[':tecnico'] = '%' . $tecnico . '%'; }
if ($nombre  !== '') { $where[] = 'i.nombre_cliente LIKE :nombre'; $params[':nombre']  = '%' . $nombre . '%'; }
if ($desde   !== '') { $where[] = 'i.fecha >= :desde';             $params[':desde']   = $desde; }
if ($hasta   !== '') { $where[] = 'i.fecha <= :hasta';             $params[':hasta']   = $hasta; }

$sql = "
    SELECT  i.id,
            i.fecha,
            i.tecnico,
            i.placa,
            i.nombre_cliente,
            i.telefono_cliente,
            i.novedades,
            COUNT(ii.id) AS total_items
    FROM    inspeccion i
    LEFT JOIN inspeccion_item ii ON ii.inspeccion_id = i.id
    WHERE   " . implode(' AND ', $where) . "
    GROUP BY i.id
    ORDER BY i.fecha DESC, i.id DESC
    LIMIT   500
";

try {
    $stmt = $conn->prepare($sql);
    $stmt->execute($params);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode(['success' => true, 'data' => $rows], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    error_log('apiGetInspecciones: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Error interno del servidor']);
}
