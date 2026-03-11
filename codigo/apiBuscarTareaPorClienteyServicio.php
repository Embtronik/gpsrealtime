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
        $cliente_idusuario_param = $data['idCliente'];
        $servicio_idservicio_param = $data['idServicio'];

        try {
            // Preparar el procedimiento almacenado
            $stmt = $conn->prepare("CALL SP_BuscarTareasPorClienteYServicio(:cliente_idusuario, :servicio_idservicio)");

            // Enlazar los parámetros de entrada por nombre
            $stmt->bindParam(':cliente_idusuario', $cliente_idusuario_param);
            $stmt->bindParam(':servicio_idservicio', $servicio_idservicio_param);

            // Ejecutar el procedimiento almacenado
            $stmt->execute();

            // Obtener resultados
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // Cerrar cursor para liberar la conexión
            do { $stmt->closeCursor(); } while ($stmt->nextRowset());

            // Imprimir los resultados
            header('Content-Type: application/json');
            echo json_encode(array('success' => true, 'data' => $result));
        } catch (PDOException $e) {
            // Capturar la excepción de PDO y enviar una respuesta de error
            $response = array('success' => false, 'message' => 'Error al buscar tareas: ' . $e->getMessage());
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
