<?php
require_once __DIR__ . '/api_guard.php';

    require 'coneccion.php';

    $sql = "SELECT idp_tipoServicio, descripcion FROM p_tiposervicio where estadoRegistro=1";
    $result = $conn->query($sql);
    
    $options = array();
    while($row = $result->fetch(PDO::FETCH_ASSOC)) {
        $options[$row['idp_tipoServicio']] = $row['descripcion'];
    }
    echo json_encode($options);
?>