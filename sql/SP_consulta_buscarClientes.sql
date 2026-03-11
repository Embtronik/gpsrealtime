DROP PROCEDURE IF EXISTS consulta_buscarClientes;
DELIMITER //

CREATE PROCEDURE consulta_buscarClientes(
    IN p_nombre VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_identificacion VARCHAR(255),
    IN p_fechaDesde DATE,
    IN p_fechaHasta DATE,
    IN p_placa VARCHAR(45)
)
BEGIN
	SET p_nombre = NULLIF(p_nombre, '');
    SET p_email = NULLIF(p_email, '');
    SET p_identificacion = NULLIF(p_identificacion, '');
    SET p_fechaDesde = NULLIF(p_fechaDesde, '');
    SET p_fechaHasta = NULLIF(p_fechaHasta, '');
    SET p_placa = NULLIF(p_placa, '');
    
    SELECT DISTINCT
        u.idusuario AS idUsuario,
        u.nombre AS Nombre,
        s.idservicio AS idServicio,
        s.fechaInicioFormulario AS FechaInicio,
        ts.descripcion AS Servicio,
        dds.id AS idDatosServicio,
        pes.descripcion AS Estado,
        IFNULL(dds.asignado, '') AS Asignado,
        IFNULL(dds.operador, '') AS Operador,
        IFNULL(dds.imei, '') AS IMEI,
        IFNULL(dds.linea, '') AS Linea,
        IFNULL(dds.renovacion, '') AS Renovacion,
        IFNULL(dds.fechaRenovacion, NOW()) AS FechaRenovacion,
        IFNULL(dds.recarga, '') AS Recarga,
        IFNULL(dds.fechaRecarga, NOW()) AS FechaRecarga,
        IFNULL(dds.instalacion, '') AS Instalacion,
        IFNULL(dds.instalador, '') AS Instalador,
        IFNULL(dds.valorInstalacion, '') AS ValorInstalacion,
        IFNULL(dds.pagoInstalacion, '') AS PagoInstalacion,
        IFNULL(dds.valorVenta, '') AS ValorVenta,
        IFNULL(dds.medotoPago, '') AS MetodoPago,
        IFNULL(dds.realizarFactura, '') AS RealizarFactura,
        IFNULL(dds.manejo, '') AS Manejo,
        IFNULL(dds.ingresoPago, '') AS IngresoPago,
        IFNULL(dds.remision, '') AS Remision,
        IFNULL(dds.facturaNumero, '') AS FacturaNumero,
        IFNULL(dds.actualizacion, '') AS Actualizacion,
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
        us.nombre AS Auxiliar,
        co.descripcion AS Comercial,
        IFNULL(t.nombreTercero,'') AS nombreTercero,
		IFNULL(t.identificacionTercero,'') AS identificacionTercero,
		IFNULL(t.emailTercero,'') AS emailTercero,
		IFNULL(t.telefonoTercero,'') AS telefonoTercero
    FROM usuario u
    LEFT JOIN usuariorol ur ON u.idusuario=ur.usuario_idusuario
    LEFT JOIN serviciosparausuario spu ON u.idusuario = spu.usuario_idusuario AND spu.estadoRegistro = 1
    LEFT JOIN servicio s ON spu.servicio_idservicio = s.idservicio
    LEFT JOIN estadoServicio es ON s.idservicio = es.idservicio AND es.estadoRegistro = 1
    LEFT JOIN p_estadoServicio pes ON es.idp_estadoservicio=pes.idp_estadoServicio
    LEFT JOIN usuario us ON es.usuario_idusuario = us.idusuario AND us.estadoRegistro = 1
    LEFT JOIN p_tipoidentificacion ti ON u.tipoIdentificacion_idtipoIdentificacion = ti.idtipoIdentificacion
    LEFT JOIN datosDelServicio dds ON s.idservicio = dds.servicio_idservicio AND dds.estadoRegistro = 1
    LEFT JOIN vehiculo v ON s.vehiculo_idvehiculo = v.idvehiculo AND v.estadoRegistro=1
    LEFT JOIN p_comoseentero cse ON s.p_comoSeEntero_idp_comoSeEntero = cse.idp_comoSeEntero
    LEFT JOIN p_tiposervicio ts ON s.p_tipoServicio_idp_tipoServicio = ts.idp_tipoServicio
    LEFT JOIN p_comercial co ON s.p_comercial_idp_comercial=co.idp_comercial
    LEFT JOIN vehiculoporusuario vpu ON vpu.usuario_idusuario=u.idusuario AND vpu.vehiculo_idvehiculo=v.idvehiculo AND vpu.estadoRegistro=1
    LEFT JOIN tercero t ON vpu.idvehiculoPorUsuario=t.idvehiculoPorUsuario
    WHERE
        (p_nombre IS NULL OR u.nombre LIKE CONCAT('%', p_nombre, '%'))
        AND (p_email IS NULL OR u.email = p_email)
        AND (p_identificacion IS NULL OR u.identificacion = p_identificacion)
        AND (p_fechaDesde IS NULL OR s.fechaInicioFormulario >= p_fechaDesde)
        AND (p_fechaHasta IS NULL OR s.fechaInicioFormulario <= p_fechaHasta)
        AND (p_placa IS NULL OR v.placa LIKE CONCAT('%', p_placa, '%'))
        AND ur.p_rol_idp_rol=2
        AND es.id IS NOT NULL
        AND v.estadoRegistro=1;
END //

DELIMITER ;
