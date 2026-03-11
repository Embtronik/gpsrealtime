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
        $servicio = $data['servicio'];
        $vehiculo = $data['vehiculo'];

        try {
            // Preparar el procedimiento almacenado
            $stmt = $conn->prepare("CALL SP_consultarClienteEditar(:servicio , :vehiculo)");

            // Enlazar los parámetros de entrada por nombre
            $stmt->bindParam(':servicio', $servicio);
            $stmt->bindParam(':vehiculo', $vehiculo);

            // Ejecutar el procedimiento almacenado
            $stmt->execute();

            // Obtener los resultados como un arreglo asociativo
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // Combinar el arreglo de resultados con el arreglo de éxito
            $response = array('success' => true, 'data' => $result);

            // Convertir el arreglo combinado en una cadena JSON
            $jsonResponse = json_encode($response, JSON_UNESCAPED_UNICODE);

            // Imprimir la cadena JSON
            echo $jsonResponse;

        } catch (PDOException $e) {
            // Capturar la excepción de PDO y enviar una respuesta de error
            $response = array('success' => false, 'message' => 'Error al consultar el usuario: ' . $e->getMessage());
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
