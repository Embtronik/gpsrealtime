<?php
require_once __DIR__ . '/api_guard.php';

header('Content-Type: application/json');
// Verificar si se realiza una solicitud POST a la API
if ($_SERVER['REQUEST_METHOD'] === 'POST') 
{
    require 'coneccion.php';
  // Obtener los datos enviados en el cuerpo de la solicitud
  $jsonData = file_get_contents('php://input');
  $data = json_decode($jsonData, true);
  
  try {
    $sql = "CALL sp_read_p_metodopago()";
    $result = $conn->query($sql);

    $data = array();
    if ($result->rowCount() > 0) {     
        while ($row = $result->fetch(PDO::FETCH_ASSOC)) {
        $data[] = $row;
        }
    }
  }
  catch (PDOException $e) {
    // Capturar la excepción de PDO y enviar una respuesta de error
    $response = array('success' => false, 'message' => 'Error en Método de Pago: ' . $e->getMessage());
    header('Content-Type: application/json');
    echo json_encode($response);
    }
    echo json_encode($data);
}
?>
