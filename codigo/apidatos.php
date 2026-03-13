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
    // Obtener los valores de los campos del formulario
    $fecha = $data['fecha'];
    $servicio = $data['servicio'];
    $tipoIdentificacion = $data['tipoIdentificacion'];
    $identificacion = $data['identificacion'];
    $nombre = $data['nombre'];
    $telefono = $data['telefono'];
    $direccion = $data['direccion'];
    $email = $data['email'];
    $marcaVehiculo = $data['marcaVehiculo'];
    $referenciaVehiculo = $data['referenciaVehiculo'];
    $modeloVehiculo = $data['modeloVehiculo'];
    $cilindrajeVehiculo = $data['cilindrajeVehiculo'];
    $placa = $data['placa'];
    $comercial = $data['comercial'];
    $metodoPago = $data['metodoPago'];
    $comoSeEntero = $data['comoSeEntero'];
    $tratamiento = $data['tratamiento'];
    $recomendaciones = $data['recomendaciones'];
  
    /* INSERTAR USUARIO */
    try {
        // Lógica para manejar la solicitud POST a /api/usuarios
    
        // Realizar la inserción en la base de datos
        $stmt = $conn->prepare("CALL insertar_usuario(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
                              ?, ?, ?, ?, ?, ?, ?)");
        $stmt->bindParam(1, $nombre);
        $stmt->bindParam(2, $email);
        $stmt->bindParam(3, $identificacion);
        $stmt->bindParam(4, $direccion);
        $stmt->bindParam(5, $telefono);
        $stmt->bindParam(6, $tipoIdentificacion);
        $stmt->bindParam(7, $placa);
        $stmt->bindParam(8, $marcaVehiculo);
        $stmt->bindParam(9, $referenciaVehiculo);
        $stmt->bindParam(10, $cilindrajeVehiculo);
        $stmt->bindParam(11, $modeloVehiculo);
        $stmt->bindParam(12, $fecha);
        $stmt->bindParam(13, $tratamiento);
        $stmt->bindParam(14, $recomendaciones);
        $stmt->bindParam(15, $comercial);
        $stmt->bindParam(16, $metodoPago);
        $stmt->bindParam(17, $comoSeEntero);
        $stmt->bindParam(18, $servicio);
        $stmt->execute();

        // Enviar correo solo si la inserción fue exitosa
        try {
          // Envío de Correo
          $bienvenida = array(
              "emailUsuario" => $email,
              "nombreCliente" => $nombre,
              "codigo" => $placa
          );
          $json = json_encode($bienvenida);

          // Inicializar cURL
          $ch = curl_init();

          // Configurar URL destino y opciones
          curl_setopt($ch, CURLOPT_URL, "https://www.gpsrealtime.com.co/codigo/email.php"); // Cambia la URL según corresponda
          curl_setopt($ch, CURLOPT_POST, 1); // Enviar método POST
          curl_setopt($ch, CURLOPT_POSTFIELDS, $json); // Pasar el JSON
          curl_setopt($ch, CURLOPT_HTTPHEADER, array(
              'Content-Type: application/json',  // Tipo de contenido
              'Content-Length: ' . strlen($json)
          ));

          // Recibir la respuesta en lugar de imprimirla
          curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

          // Ejecutar la solicitud y obtener la respuesta
          $response = curl_exec($ch);

          // Verificar si hubo errores en cURL
          if (curl_errno($ch)) {
              // Registrar el error, pero no interrumpir la ejecución
              error_log('Error en cURL: ' . curl_error($ch));
          } else {
              // Si es exitoso, puedes manejar la respuesta si lo deseas
              // $response contiene la respuesta del servidor
          }

          // Cerrar cURL
          curl_close($ch);

      } catch (Exception $e) {
          // Registrar el error de envío de correo
          error_log('Error al enviar el correo: ' . $e->getMessage());
      }
      
        // Enviar una respuesta exitosa
        $response = array('success' => true, 'message' => 'Usuario creado exitosamente');
        header('Content-Type: application/json');
        echo json_encode($response);
    } catch (PDOException $e) {
        // Capturar la excepción de PDO y enviar una respuesta de error
        $response = array('success' => false, 'message' => 'Error al insertar usuario: ' . $e->getMessage());
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
