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
        $descripcionGestion = $data['descripcionGestion'];
        $fechaSeguimiento = $data['fechaSeguimiento'];
        $fechaSiguienteTarea = $data['fechaSiguienteTarea'];
        $cliente_idusuario = $data['cliente_idusuario'];
        $funcionario_idusuario = $data['funcionario_idusuario'];
        $p_canalComercial_id = $data['p_canalComercial_id'];
        $servicio_idservicio = $data['servicio_idservicio'];
        $p_resultado_id = $data['resultado'];

        try {
            // Preparar el procedimiento almacenado
            $stmt = $conn->prepare("CALL SP_InsertarTareaCliente
            (:descripcionGestion, :fechaSeguimiento, 
            :fechaSiguienteTarea, :cliente_idusuario, 
            :funcionario_idusuario, :p_canalComercial_id, :servicio_idservicio, :p_resultado_idresultado)");

            // Enlazar los parámetros de entrada por nombre
            $stmt->bindParam(':descripcionGestion', $descripcionGestion);
            $stmt->bindParam(':fechaSeguimiento', $fechaSeguimiento);
            $stmt->bindParam(':fechaSiguienteTarea', $fechaSiguienteTarea);
            $stmt->bindParam(':cliente_idusuario', $cliente_idusuario);
            $stmt->bindParam(':funcionario_idusuario', $funcionario_idusuario);
            $stmt->bindParam(':p_canalComercial_id', $p_canalComercial_id);
            $stmt->bindParam(':servicio_idservicio', $servicio_idservicio);
            $stmt->bindParam(':p_resultado_idresultado', $p_resultado_id);
            
            // Ejecutar el procedimiento almacenado
            $stmt->execute();
            do { $stmt->closeCursor(); } while ($stmt->nextRowset());

            // Imprimir los resultados
            header('Content-Type: application/json');
            echo json_encode(array('success' => true));
        } catch (PDOException $e) {
            // Capturar la excepción de PDO y enviar una respuesta de error
            $response = array('success' => false, 'message' => 'Error al insertar la tarea: ' . $e->getMessage());
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
