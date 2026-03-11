<?php
require_once __DIR__ . '/api_guard.php';

    require 'coneccion.php';

    $sql = "SELECT idp_metodoPago, descripcion FROM p_metodopago where estadoRegistro=1";
    $result = $conn->query($sql);
    
    $options = array();
    while($row = $result->fetch(PDO::FETCH_ASSOC)) {
        $options[$row['idp_metodoPago']] = $row['descripcion'];
    }
    echo json_encode($options);
?>