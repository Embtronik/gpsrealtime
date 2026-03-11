<?php
require_once __DIR__ . '/api_guard.php';

// Verificar si se realiza una solicitud POST a la API
if ($_SERVER['REQUEST_METHOD'] === 'POST') 
{
    require 'coneccion.php';
  
    // Obtener los datos enviados en el cuerpo de la solicitud
    $jsonData = file_get_contents('php://input');
    $data = json_decode($jsonData, true);

    // Verificar si la decodificación fue exitosa
    if (json_last_error() === JSON_ERROR_NONE) {        
        // Asignar valores a las variables necesarias
        $idDatosServicio = $data['idDatosServicio'];
        $fechaInicio = $data['fechaInicio'];
        $estadoServicio = $data['estadoServicio'];
        $asignado = $data['idAuxiliar'];
        $operador = $data['operador'];
        $IMEI = $data['IMEI'];
        $linea = $data['linea'];
        $renovacion = $data['renovacion'];
        $fechaRenovacion = $data['fechaRenovacion'];
        $recarga = $data['recarga'];
        $fechaRecarga = $data['fechaRecarga'];
        $instalacion = $data['instalacion'];
        $instalador = $data['instalador'];
        $valorInstalacion = $data['valorInstalacion'];
        $pagoInstalacion = $data['pagoInstalacion'];
        $valorVenta = $data['valorVenta'];
        $metodoPago = $data['metodoPago'];
        $realizarFactura = $data['realizarFactura'];
        $manejo = $data['manejo'];
        $ingresoPago = $data['ingresoPago'];
        $remision = $data['remision'];
        $facturaNumero = $data['facturaNumero'];
        $actualizacion = $data['actualizacion'];
        $idServicio = $data['idServicio'];

        try {
            // Preparar la llamada al procedimiento almacenado
            $stmt = $conn->prepare('CALL insertar_actualizar_datosDelServicio(
                :p_id,
                :p_fechaInicioServicio,
                :p_asignado,
                :p_estado,
                :p_operador,
                :p_imei,
                :p_linea,
                :p_renovacion,
                :p_fechaRenovacion,
                :p_recarga,
                :p_fechaRecarga,
                :p_instalacion,
                :p_instalador,
                :p_valorInstalacion,
                :p_pagoInstalacion,
                :p_valorVenta,
                :p_metodoPago,
                :p_realizarFactura,
                :p_manejo,
                :p_ingresoPago,
                :p_remision,
                :p_facturaNumero,
                :p_actualizacion,
                :p_servicio_idservicio
            )');
            
            // Enlazar los parámetros de entrada
            $stmt->bindParam(':p_id', $idDatosServicio);
            $stmt->bindParam(':p_fechaInicioServicio', $fechaInicio);
            $stmt->bindParam(':p_asignado', $asignado);
            $stmt->bindParam(':p_estado', $estadoServicio);
            $stmt->bindParam(':p_operador', $operador);
            $stmt->bindParam(':p_imei', $IMEI);
            $stmt->bindParam(':p_linea', $linea);
            $stmt->bindParam(':p_renovacion', $renovacion);
            $stmt->bindParam(':p_fechaRenovacion', $fechaRenovacion);
            $stmt->bindParam(':p_recarga', $recarga);
            $stmt->bindParam(':p_fechaRecarga', $fechaRecarga);
            $stmt->bindParam(':p_instalacion', $instalacion);
            $stmt->bindParam(':p_instalador', $instalador);
            $stmt->bindParam(':p_valorInstalacion', $valorInstalacion);
            $stmt->bindParam(':p_pagoInstalacion', $pagoInstalacion);
            $stmt->bindParam(':p_valorVenta', $valorVenta);
            $stmt->bindParam(':p_metodoPago', $metodoPago);
            $stmt->bindParam(':p_realizarFactura', $realizarFactura);
            $stmt->bindParam(':p_manejo', $manejo);
            $stmt->bindParam(':p_ingresoPago', $ingresoPago);
            $stmt->bindParam(':p_remision', $remision);
            $stmt->bindParam(':p_facturaNumero', $facturaNumero);
            $stmt->bindParam(':p_actualizacion', $actualizacion);
            $stmt->bindParam(':p_servicio_idservicio', $idServicio);
            
            // Enlazar el parámetro de salida

            // Ejecutar el procedimiento almacenado
            $stmt->execute();

            // Obtener el valor de p_success después de la ejecución
            $stmt->closeCursor();  // Es necesario cerrar el cursor antes de leer el parámetro de salida
                        // Imprimir los resultados
                        header('Content-Type: application/json');
                        echo json_encode(array('success' => true));
        }
        catch (PDOException $e) {
            /// Capturar la excepción de PDO y enviar una respuesta de error
            $response = array('success' => false, 'message' => 'Error insertar Detalle del Servicio: ' . $e->getMessage());
            header('Content-Type: application/json');
            echo json_encode($response);

            // Imprimir detalles específicos sobre la excepción
            error_log('Error en ejecución de SP_ActualizarDatosProceso: ' . $e->getMessage());
            error_log('SQLSTATE: ' . $e->errorInfo[0]);
            error_log('Driver Code: ' . $e->errorInfo[1]);
            error_log('Driver Message: ' . (isset($e->errorInfo[2]) ? $e->errorInfo[2] : 'Key 2 not defined in errorInfo array'));
        }
    }
    else {
        // La decodificación JSON falló, enviar una respuesta de error
        $response = array('success' => false, 'message' => 'Error en el formato JSON');
        header('Content-Type: application/json');
        echo json_encode($response);
    }
}
?>
