<?php
require_once __DIR__ . '/api_guard.php';


// Verificar si se realiza una solicitud POST a la API
if ($_SERVER['REQUEST_METHOD'] === 'POST') 
{
    require 'coneccion.php';
  // Obtener los datos enviados en el cuerpo de la solicitud
  $jsonData = file_get_contents('php://input');
  $data = json_decode($jsonData, true);

  //echo $jsonData;

    // Verificar si la decodificación fue exitosa
    if (json_last_error() === JSON_ERROR_NONE) {
        $idServicio= $data['idServicio'];
        $FechaInicio= $data['FechaInicio'];
        $idDatosServicio= $data['idDatosServicio'];
        if ($idDatosServicio === 'null') {
            $idDatosServicio = null;
        }
        $Asignado= $data['Asignado'];
        $Estado = $data['Estado'];
        $Operador= $data['Operador'];
        $IMEI= $data['IMEI'];
        $Linea= $data['Linea'];
        $Renovacion= $data['Renovacion'];
        $FechaRenovacion= $data['FechaRenovacion'];
        $Recarga= $data['Recarga'];
        $FechaRecarga = $data['FechaRecarga'];
        $Instalacion= $data['Instalacion'];
        $Instalador= $data['Instalador'];
        $ValorInstalacion= $data['ValorInstalacion'];
        $PagoInstalacion= $data['PagoInstalacion'];
        $ValorVenta= $data['ValorVenta'];
        $MetodoPago= $data['MetodoPago'];
        $RealizarFactura= $data['RealizarFactura'];
        $Manejo= $data['Manejo'];
        $IngresoPago= $data['IngresoPago'];
        $Remision= $data['Remision'];
        $FacturaNumero= $data['FacturaNumero'];
        $Actualizacion = $data['Actualizacion'];

        try {
                        // Preparar la llamada al procedimiento almacenado
            $stmt = $conn->prepare('CALL insertar_actualizar_datosDelServicio(
                :idDatosServicio,
                :fechaInicioServicio,
                :Asignado,
                :Estado,
                :Operador,
                :IMEI,
                :Linea,
                :Renovacion,
                :FechaRenovacion,
                :Recarga,
                :FechaRecarga,
                :Instalacion,
                :Instalador,
                :ValorInstalacion,
                :PagoInstalacion,
                :ValorVenta,
                :MetodoPago,
                :RealizarFactura,
                :Manejo,
                :IngresoPago,
                :Remision,
                :FacturaNumero,
                :Actualizacion,
                :idServicio
                )');
    
            // Enlazar los parámetros de entrada
            $stmt->bindParam(':idDatosServicio', $idDatosServicio);
            $stmt->bindParam(':idServicio', $idServicio);
            $stmt->bindParam(':fechaInicioServicio', $FechaInicio);
            $stmt->bindParam(':Asignado', $Asignado);
            $stmt->bindParam(':Estado', $Estado);
            $stmt->bindParam(':Operador', $Operador);
            $stmt->bindParam(':IMEI', $IMEI);
            $stmt->bindParam(':Linea', $Linea);
            $stmt->bindParam(':Renovacion', $Renovacion);
            $stmt->bindParam(':FechaRenovacion', $FechaRenovacion);
            $stmt->bindParam(':Recarga', $Recarga);
            $stmt->bindParam(':FechaRecarga', $FechaRecarga);
            $stmt->bindParam(':Instalacion', $Instalacion);
            $stmt->bindParam(':Instalador', $Instalador);
            $stmt->bindParam(':ValorInstalacion', $ValorInstalacion);
            $stmt->bindParam(':PagoInstalacion', $PagoInstalacion);
            $stmt->bindParam(':ValorVenta', $ValorVenta);
            $stmt->bindParam(':MetodoPago', $MetodoPago);
            $stmt->bindParam(':RealizarFactura', $RealizarFactura);
            $stmt->bindParam(':Manejo', $Manejo);
            $stmt->bindParam(':IngresoPago', $IngresoPago);
            $stmt->bindParam(':Remision', $Remision);
            $stmt->bindParam(':FacturaNumero', $FacturaNumero);
            $stmt->bindParam(':Actualizacion', $Actualizacion);
            // Ejecutar el procedimiento almacenado

            //echo json_encode($stmt);
            $stmt->execute();

            // Imprimir los resultados
            header('Content-Type: application/json');
            echo json_encode(array('success' => true));
        }
        catch (PDOException $e) {
            // Capturar la excepción de PDO y enviar una respuesta de error
            $response = array('success' => false, 'message' => 'Error insertar Detalle del Servicio: ' . $e->getMessage());
            header('Content-Type: application/json');
            echo json_encode($response);
        }
        catch (Exception $e) {
            // Manejo de la excepción
            echo "Excepción capturada: " . $e->getMessage();
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