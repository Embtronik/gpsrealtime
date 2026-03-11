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
        $nueva_descripcionGestion_param = $data['nueva_descripcionGestion'];
        $nueva_fechaSeguimiento_param = $data['nueva_fechaSeguimiento'];
        $nueva_fechaSiguienteTarea_param = $data['nueva_fechaSiguienteTarea'];

        try {
            // Preparar el procedimiento almacenado
            $stmt = $conn->prepare("CALL SP_ActualizarTareaCliente(:idtareaCliente, :nueva_descripcionGestion, :nueva_fechaSeguimiento, :nueva_fechaSiguienteTarea)");

            // Enlazar los parámetros de entrada por nombre
            $stmt->bindParam(':idtareaCliente', $idtareaCliente_param);
            $stmt->bindParam(':nueva_descripcionGestion', $nueva_descripcionGestion_param);
            $stmt->bindParam(':nueva_fechaSeguimiento', $nueva_fechaSeguimiento_param);
            $stmt->bindParam(':nueva_fechaSiguienteTarea', $nueva_fechaSiguienteTarea_param);

            // Ejecutar el procedimiento almacenado
            $stmt->execute();

            // Imprimir los resultados
            header('Content-Type: application/json');
            echo json_encode(array('success' => true));
        } catch (PDOException $e) {
            // Capturar la excepción de PDO y enviar una respuesta de error
            $response = array('success' => false, 'message' => 'Error al actualizar tarea: ' . $e->getMessage());
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
