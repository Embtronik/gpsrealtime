<?php
require_once __DIR__ . '/api_guard.php';

    require 'coneccion.php';

    $sql = "SELECT idtipoidentificacion, descripcion FROM p_tipoidentificacion where estadoRegistro=1";
    $result = $conn->query($sql);
    
    $options = array();
    while($row = $result->fetch(PDO::FETCH_ASSOC)) {
        $options[$row['idtipoidentificacion']] = $row['descripcion'];
    }
    echo json_encode($options);
?>