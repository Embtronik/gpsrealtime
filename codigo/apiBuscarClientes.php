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
        $nombre = $data['name'];
        $email = $data['correo'];
        $identificacion = $data['ident'];
        $fechaDesde = validateAndFormatDate($data['fechaInicio']);
        $fechaHasta = validateAndFormatDate($data['fechaFin']);
        $placa = $data['matricula'];
        $imei = $data['imei'];
        $linea = $data['linea'];
        $extraParam = $data['extraParam'];
        $extraParamValue = $data['extraParamValue'];

        // Paginación server-side
        $page      = max(1, (int)($data['page']      ?? 1));
        $pageSize  = max(1, min(2000, (int)($data['pageSize']  ?? 50)));
        $exportAll = !empty($data['exportAll']);
        $limite         = $exportAll ? 0 : $pageSize;
        $desplazamiento = $exportAll ? 0 : ($page - 1) * $pageSize;

        try {
            // Preparar el procedimiento almacenado
            $stmt = $conn->prepare("CALL consulta_buscarClientes(
                                    :nombre, :email, :identificacion,:fechaDesde,:fechaHasta, :placa, :imei, :linea, :extraParam, :extraParamValue, :limite, :desplazamiento)");

            // Enlazar los parámetros de entrada por nombre
            $stmt->bindParam(':nombre', $nombre);
            $stmt->bindParam(':email', $email);
            $stmt->bindParam(':identificacion', $identificacion);
            $stmt->bindParam(':fechaDesde', $fechaDesde);
            $stmt->bindParam(':fechaHasta', $fechaHasta);
            $stmt->bindParam(':placa', $placa);
            $stmt->bindParam(':imei', $imei);
            $stmt->bindParam(':linea', $linea);
            $stmt->bindParam(':extraParam', $extraParam);
            $stmt->bindParam(':extraParamValue', $extraParamValue);
            $stmt->bindParam(':limite', $limite, PDO::PARAM_INT);
            $stmt->bindParam(':desplazamiento', $desplazamiento, PDO::PARAM_INT);

            // Ejecutar el procedimiento almacenado
            $stmt->execute();

            // Primer resultset: filas de datos
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // Segundo resultset: total de filas (FOUND_ROWS)
            $total = 0;
            while ($stmt->nextRowset()) {
                $countRow = $stmt->fetch(PDO::FETCH_ASSOC);
                if ($countRow !== false && isset($countRow['total'])) {
                    $total = (int)$countRow['total'];
                    break;
                }
            }
            $stmt->closeCursor();

            $response = array('success' => true, 'data' => $result, 'total' => $total, 'page' => $page, 'pageSize' => $pageSize);
            header('Content-Type: application/json; charset=utf-8');
            echo json_encode($response, JSON_UNESCAPED_UNICODE);

        } catch (PDOException $e) {
            // Capturar la excepción de PDO y enviar una respuesta de error
            $response = array('success' => false, 'message' => 'Error al buscar el cliente: ' . $e->getMessage());
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

function validateAndFormatDate($date)
{
    $parsedDate = date_parse($date);
    if ($parsedDate && $parsedDate['error_count'] === 0 && $parsedDate['warning_count'] === 0) {
        return $parsedDate['year'] . '-' . sprintf('%02d', $parsedDate['month']) . '-' . sprintf('%02d', $parsedDate['day']);
    } else {
        // Devolver NULL si la fecha no es válida
        return NULL;
    }
}
?>
