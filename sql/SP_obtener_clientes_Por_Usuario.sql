DROP PROCEDURE IF EXISTS obtener_clientes_Por_Usuario;

DELIMITER //

CREATE PROCEDURE obtener_clientes_Por_Usuario(IN idUser INT)
BEGIN
    SELECT 
        u.idusuario AS idUsuario,
        u.nombre AS Nombre,
        s.idservicio AS idServicio,
        s.fechaInicioFormulario AS FechaInicio,
        ts.descripcion AS Servicio,
        dds.id AS idDatosServicio,
        es.idp_estadoservicio AS Estado,
        IFNULL(dds.asignado,'') AS Asignado,
        IFNULL(dds.operador,'') AS Operador,
        IFNULL(dds.imei,'') AS IMEI,
        IFNULL(dds.linea,'') AS Linea,
        IFNULL(dds.renovacion,'') AS Renovacion,
        IFNULL(dds.fechaRenovacion,NOW()) AS FechaRenovacion,
        IFNULL(dds.recarga,'') AS Recarga,
        IFNULL(dds.fechaRecarga,NOW()) AS FechaRecarga,
        IFNULL(dds.instalacion,'') AS Instalacion,
        IFNULL(dds.instalador,'') AS Instalador,
        IFNULL(dds.valorInstalacion,'') AS ValorInstalacion,
        IFNULL(dds.pagoInstalacion,'') AS PagoInstalacion,
        IFNULL(dds.valorVenta,'') AS ValorVenta,
        IFNULL(dds.medotoPago,'') AS MetodoPago,
        IFNULL(dds.realizarFactura,'') AS RealizarFactura,
        IFNULL(dds.manejo,'') AS Manejo,
        IFNULL(dds.ingresoPago,'') AS IngresoPago,
        IFNULL(dds.remision,'') AS Remision,
        IFNULL(dds.facturaNumero,'') AS FacturaNumero,
        IFNULL(dds.actualizacion,'') AS Actualizacion,
        v.idvehiculo AS idVehiculo,
        v.placa AS Placa,
        v.marca AS Marca,
        v.referencia AS Referencia,
        v.modelo AS Modelo,
        v.cilindraje AS Cilindraje,
        ti.descripcion AS TipoIdentificacion,
        u.identificacion AS NumeroIdentificacion,
        u.telefono AS Telefono,
        u.email AS Email,
        u.direccion AS Direccion,
        cse.descripcion AS ComoSeEntero,
        us.idusuario AS idAuxiliar
    FROM usuario u
    LEFT JOIN serviciosparausuario spu ON u.idusuario = spu.usuario_idusuario AND spu.estadoRegistro = 1
    LEFT JOIN servicio s ON spu.servicio_idservicio = s.idservicio
    LEFT JOIN estadoServicio es ON s.idservicio = es.idservicio AND es.estadoRegistro = 1
    LEFT JOIN usuario us ON es.usuario_idusuario = us.idusuario AND us.estadoRegistro = 1
    LEFT JOIN p_tipoidentificacion ti ON u.tipoIdentificacion_idtipoIdentificacion = ti.idtipoIdentificacion
    LEFT JOIN datosDelServicio dds ON s.idservicio = dds.servicio_idservicio AND dds.estadoRegistro = 1
    LEFT JOIN vehiculo v ON s.vehiculo_idvehiculo = v.idvehiculo AND v.estadoRegistro=1
    LEFT JOIN p_comoseentero cse ON s.p_comoSeEntero_idp_comoSeEntero = cse.idp_comoSeEntero
    LEFT JOIN p_tiposervicio ts ON s.p_tipoServicio_idp_tipoServicio = ts.idp_tipoServicio
    WHERE
        v.placa IS NOT NULL
        AND es.idp_estadoservicio not in (3,4) -- para que no muestre los finalizados
        AND us.idusuario = idUser
    ORDER BY Nombre;
END //

DELIMITER ;
