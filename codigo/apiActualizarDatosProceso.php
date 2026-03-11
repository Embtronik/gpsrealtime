<?php
require_once __DIR__ . '/api_guard.php';

/*ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);*/

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
        $idUsuario = $data['idUsuario'];
        $nombre = $data['nombre'];
        $idServicio = $data['idServicio'];
        if ($idServicio === 'null') {
            $idServicio = null;
        }
        $fechaInicio = $data['fechaInicio'];
        $tipoServicio = $data['tipoServicio'];
        $idDatosServicio = $data['idDatosServicio'];
        if ($idDatosServicio === 'null') {
            $idDatosServicio = null;
        }
        $estadoServicio = $data['estadoServicio'];
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
        $idVehiculo = $data['idVehiculo'];
        if ($idVehiculo === 'null') {
            $idVehiculo = null;
        }
        $placa = $data['placa'];
        $marca = $data['marca'];
        $referencia = $data['referencia'];
        $modelo = $data['modelo'];
        $cilindraje = $data['cilindraje'];
        $tipoIdentificacion = $data['tipoIdentificacion'];
        $numeroIdentificacion = $data['numeroIdentificacion'];
        $telefono = $data['telefono'];
        $email = $data['email'];
        $direccion = $data['direccion'];
        $comercial = intval($data['comercial']);
        $comoSeEntero = intval($data['comoSeEntero']);
        $idAuxiliar = $data['idAuxiliar'];
        if ($idAuxiliar === 'null') {
            $idAuxiliar = null;
        }
        $idTercero = $data['idTercero'];
        if ($idTercero === 'null') {
            $idTercero = null;
        }
        $nombreTercero = $data['nombreTercero'];
        $identificacionTercero = $data['identificacionTercero'];
        $emailTercero = $data['emailTercero'];
        $telefonoTercero = $data['telefonoTercero'];
        
        //echo "IMEI: " . $IMEI . "\n";
        //echo "Operador: " . $operador . "\n";
        //echo "Linea: " . $linea . "\n";
        try {
                        // Preparar la llamada al procedimiento almacenado
                        $stmt = $conn->prepare('CALL SP_ActualizarDatosProceso(
                            :idUsuario,
                            :nombre,
                            :idServicio,
                            :fechaInicio,
                            :tipoServicio,
                            :idDatosServicio,
                            :estadoServicio,
                            :operador,
                            :IMEI,
                            :linea,
                            :renovacion,
                            :fechaRenovacion,
                            :recarga,
                            :fechaRecarga,
                            :instalacion,
                            :instalador,
                            :valorInstalacion,
                            :pagoInstalacion,
                            :valorVenta,
                            :metodoPago,
                            :realizarFactura,
                            :manejo,
                            :ingresoPago,
                            :remision,
                            :facturaNumero,
                            :actualizacion,
                            :idVehiculo,
                            :placa,
                            :marca,
                            :referencia,
                            :modelo,
                            :cilindraje,
                            :tipoIdentificacion,
                            :numeroIdentificacion,
                            :telefono,
                            :email,
                            :direccion,
                            :comercial,
                            :comoSeEntero,
                            :idAuxiliar,
                            :idTercero,
                            :nombreTercero,
                            :identificacionTercero,
                            :emailTercero,
                            :telefonoTercero
                        )');
                        
    
            // Enlazar los parámetros de entrada
            $stmt->bindParam(':idUsuario', $idUsuario);
            $stmt->bindParam(':nombre', $nombre);
            $stmt->bindParam(':idServicio', $idServicio);
            $stmt->bindParam(':fechaInicio', $fechaInicio);
            $stmt->bindParam(':tipoServicio', $tipoServicio);
            $stmt->bindParam(':idDatosServicio', $idDatosServicio);
            $stmt->bindParam(':estadoServicio', $estadoServicio);
            $stmt->bindParam(':operador', $operador);
            $stmt->bindParam(':IMEI', $IMEI);
            $stmt->bindParam(':linea', $linea);
            $stmt->bindParam(':renovacion', $renovacion);
            $stmt->bindParam(':fechaRenovacion', $fechaRenovacion);
            $stmt->bindParam(':recarga', $recarga);
            $stmt->bindParam(':fechaRecarga', $fechaRecarga);
            $stmt->bindParam(':instalacion', $instalacion);
            $stmt->bindParam(':instalador', $instalador);
            $stmt->bindParam(':valorInstalacion', $valorInstalacion);
            $stmt->bindParam(':pagoInstalacion', $pagoInstalacion);
            $stmt->bindParam(':valorVenta', $valorVenta);
            $stmt->bindParam(':metodoPago', $metodoPago);
            $stmt->bindParam(':realizarFactura', $realizarFactura);
            $stmt->bindParam(':manejo', $manejo);
            $stmt->bindParam(':ingresoPago', $ingresoPago);
            $stmt->bindParam(':remision', $remision);
            $stmt->bindParam(':facturaNumero', $facturaNumero);
            $stmt->bindParam(':actualizacion', $actualizacion);
            $stmt->bindParam(':idVehiculo', $idVehiculo);
            $stmt->bindParam(':placa', $placa);
            $stmt->bindParam(':marca', $marca);
            $stmt->bindParam(':referencia', $referencia);
            $stmt->bindParam(':modelo', $modelo);
            $stmt->bindParam(':cilindraje', $cilindraje);
            $stmt->bindParam(':tipoIdentificacion', $tipoIdentificacion);
            $stmt->bindParam(':numeroIdentificacion', $numeroIdentificacion);
            $stmt->bindParam(':telefono', $telefono);
            $stmt->bindParam(':email', $email);
            $stmt->bindParam(':direccion', $direccion);
            $stmt->bindParam(':comercial', $comercial);
            $stmt->bindParam(':comoSeEntero', $comoSeEntero);
            $stmt->bindParam(':idAuxiliar', $idAuxiliar);
            $stmt->bindParam(':idTercero', $idTercero);
            $stmt->bindParam(':nombreTercero', $nombreTercero);
            $stmt->bindParam(':identificacionTercero', $identificacionTercero);
            $stmt->bindParam(':emailTercero', $emailTercero);
            $stmt->bindParam(':telefonoTercero', $telefonoTercero);
            // Ejecutar el procedimiento almacenado

            //echo json_encode($stmt);
            //error_log('Antes de ejecutar el procedimiento almacenado: ' . json_encode($data));
            $stmt->execute();
            //error_log('Después de ejecutar el procedimiento almacenado');

            // Imprimir los resultados
            header('Content-Type: application/json');
            echo json_encode(array('success' => true));
        }
        catch (PDOException $e) {
            // Capturar la excepción de PDO y enviar una respuesta de error
            $response = array('success' => false, 'message' => 'Error insertar Detalle del Servicio: ' . $e->getMessage());
            header('Content-Type: application/json');
            echo json_encode($response);

            error_log('Error en ejecución de SP_ActualizarDatosProceso: ' . $e->getMessage());
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