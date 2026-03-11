<?php
require_once __DIR__ . '/api_guard.php';


// Verificar si se realiza una solicitud POST a la API
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    require 'coneccion.php';
    
    // Obtener los datos enviados en el cuerpo de la solicitud
    $jsonData = file_get_contents('php://input');
    $data = json_decode($jsonData, true);

    // Verificar si la decodificación fue exitosa
    if (json_last_error() === JSON_ERROR_NONE) {
        $idtareaCliente_param = $data['idtareaCliente'];

        try {
            // Preparar el procedimiento almacenado
            $stmt = $conn->prepare("CALL SP_EliminarTareaCliente(:idtareaCliente)");

            // Enlazar los parámetros de entrada por nombre
            $stmt->bindParam(':idtareaCliente', $idtareaCliente_param);

            // Ejecutar el procedimiento almacenado
            $stmt->execute();

            // Imprimir los resultados
            header('Content-Type: application/json');
            echo json_encode(array('success' => true));
        } catch (PDOException $e) {
            // Capturar la excepción de PDO y enviar una respuesta de error
            $response = array('success' => false, 'message' => 'Error al eliminar tarea: ' . $e->getMessage());
            header('Content-Type: application/json');
            echo json_encode($response);
        }
    } else {
        // La decodificación JSON falló, enviar una respuesta de error
        $response = array('success' => false, 'message' => 'Error en el formato JSON');
        header('Content-Type: application/json');
        echo json_encode($response);
    }
}
?>
