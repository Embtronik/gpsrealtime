<?php
require_once __DIR__ . '/api_guard.php';

header('Content-Type: application/json; charset=utf-8');

if ((int)$_SESSION['rol_usuario'] !== 1) {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Acceso denegado. Se requiere rol de administrador.']);
    exit;
}

require 'coneccion.php';

try {
    $stmt = $conn->query("CALL SP_ListarUsuariosAcceso()");
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
    do { $stmt->closeCursor(); } while ($stmt->nextRowset());
    echo json_encode(['success' => true, 'data' => $data]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Error al listar usuarios: ' . $e->getMessage()]);
}
