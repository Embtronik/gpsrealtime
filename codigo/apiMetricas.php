<?php
require_once __DIR__ . '/api_guard.php';

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'message' => 'Método no permitido']);
    exit;
}

require 'coneccion.php';

$raw  = file_get_contents('php://input');
$data = json_decode($raw, true);

$fechaDesde = $data['fechaDesde'] ?? null;
$fechaHasta = $data['fechaHasta'] ?? null;

if (!$fechaDesde || !$fechaHasta) {
    echo json_encode(['success' => false, 'message' => 'fechaDesde y fechaHasta son requeridos']);
    exit;
}

// Validar formato de fecha (YYYY-MM-DD)
if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $fechaDesde) || !preg_match('/^\d{4}-\d{2}-\d{2}$/', $fechaHasta)) {
    echo json_encode(['success' => false, 'message' => 'Formato de fecha inválido']);
    exit;
}

try {
    $stmt = $conn->prepare("CALL sp_MetricasServiciosPorMes(:fechaDesde, :fechaHasta)");
    $stmt->bindParam(':fechaDesde', $fechaDesde);
    $stmt->bindParam(':fechaHasta', $fechaHasta);
    $stmt->execute();

    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(['success' => true, 'data' => $rows]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}
