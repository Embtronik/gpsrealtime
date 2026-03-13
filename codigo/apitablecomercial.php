<?php
require_once __DIR__ . '/api_guard.php';

header('Content-Type: application/json; charset=utf-8');
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    require 'coneccion.php';
    try {
        $result = $conn->query('CALL sp_read_p_comercial()');
        $data = $result->fetchAll(PDO::FETCH_ASSOC);
        $result->closeCursor();
        echo json_encode($data);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}
?>
