DROP PROCEDURE IF EXISTS consulta_buscarClientes;
DELIMITER //

CREATE PROCEDURE consulta_buscarClientes(
    IN p_nombre VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_identificacion VARCHAR(255),
    IN p_fechaDesde DATE,
    IN p_fechaHasta DATE,
    IN p_placa VARCHAR(45),
    IN p_imei VARCHAR(45),
    IN p_linea VARCHAR (45),
    IN p_extraParam VARCHAR(45),
    IN p_extraParamValue VARCHAR(45),
    IN p_limit          INT,
    IN p_offset         INT
)
BEGIN
    -- Declarar variables para SQL dinámico
    DECLARE v_sql TEXT;
    DECLARE v_where TEXT;

    -- Verificar y convertir valores nulos o vacíos a NULL
    SET p_nombre = NULLIF(p_nombre, '');
    SET p_email = NULLIF(p_email, '');
    SET p_identificacion = NULLIF(p_identificacion, '');
    SET p_placa = NULLIF(p_placa, '');
    SET p_imei = NULLIF(p_imei, '');
    SET p_linea = NULLIF(p_linea, '');
    SET p_extraParam = NULLIF(p_extraParam, '');
    SET p_extraParamValue = NULLIF(p_extraParamValue, '');

    -- Verificar y convertir fechas nulas o vacías a NULL
    IF p_fechaDesde = '' THEN
        SET p_fechaDesde = NULL;
    END IF;
    
    IF p_fechaHasta = '' THEN
        SET p_fechaHasta = NULL;
    END IF;

    -- Construir cláusula WHERE dinámica
    SET v_where = ' WHERE 1=1';
    
    IF p_nombre IS NOT NULL THEN
        SET v_where = CONCAT(v_where, ' AND u.nombre LIKE CONCAT("%", "', p_nombre, '", "%")');
    END IF;
    IF p_email IS NOT NULL THEN
        SET v_where = CONCAT(v_where, ' AND u.email = "', p_email, '"');
    END IF;
    IF p_identificacion IS NOT NULL THEN
        SET v_where = CONCAT(v_where, ' AND u.identificacion = "', p_identificacion, '"');
    END IF;
    IF p_imei IS NOT NULL THEN
        SET v_where = CONCAT(v_where, ' AND dds.imei LIKE CONCAT("%", "', p_imei, '", "%")');
    END IF;
    IF p_linea IS NOT NULL THEN
        SET v_where = CONCAT(v_where, ' AND dds.linea LIKE CONCAT("%", "', p_linea, '", "%")');
    END IF;
    IF p_fechaDesde IS NOT NULL THEN
        SET v_where = CONCAT(v_where, ' AND s.fechaInicioFormulario >= "', p_fechaDesde, '"');
    END IF;
    IF p_fechaHasta IS NOT NULL THEN
        SET v_where = CONCAT(v_where, ' AND s.fechaInicioFormulario <= "', p_fechaHasta, '"');
    END IF;
    IF p_placa IS NOT NULL THEN
        SET v_where = CONCAT(v_where, ' AND v.placa LIKE CONCAT("%", "', p_placa, '", "%")');
    END IF;

    -- Agregar condición dinámica basada en p_extraParam y p_extraParamValue
    IF p_extraParam IS NOT NULL AND p_extraParamValue IS NOT NULL THEN
        SET v_where = CONCAT(v_where, ' AND dds.', p_extraParam, ' LIKE "%', p_extraParamValue, '%"');
    END IF;

    -- Agregar condiciones estáticas
    SET v_where = CONCAT(v_where, ' AND ur.p_rol_idp_rol = 2');
    SET v_where = CONCAT(v_where, ' AND es.id IS NOT NULL');

    -- Construir consulta completa
    SET v_sql = CONCAT(
        'SELECT SQL_CALC_FOUND_ROWS DISTINCT
            u.idusuario AS idUsuario,
            u.nombre AS Nombre,
            s.idservicio AS idServicio,
            s.fechaInicioFormulario AS FechaInicio,
            ts.descripcion AS Servicio,
            dds.id AS idDatosServicio,
            pes.descripcion AS Estado,
            IFNULL(dds.asignado, "") AS Asignado,
            IFNULL(dds.operador, "") AS Operador,
            IFNULL(dds.imei, "") AS IMEI,
            IFNULL(dds.linea, "") AS Linea,
            IFNULL(dds.renovacion, "") AS Renovacion,
            IFNULL(dds.fechaRenovacion, NOW()) AS FechaRenovacion,
            IFNULL(dds.recarga, "") AS Recarga,
            IFNULL(dds.fechaRecarga, NOW()) AS FechaRecarga,
            IFNULL(dds.instalacion, "") AS Instalacion,
            IFNULL(dds.instalador, "") AS Instalador,
            IFNULL(dds.valorInstalacion, "") AS ValorInstalacion,
            IFNULL(dds.pagoInstalacion, "") AS PagoInstalacion,
            IFNULL(dds.valorVenta, "") AS ValorVenta,
            IFNULL(dds.medotoPago, "") AS MetodoPago,
            IFNULL(dds.realizarFactura, "") AS RealizarFactura,
            IFNULL(dds.manejo, "") AS Manejo,
            IFNULL(dds.ingresoPago, "") AS IngresoPago,
            IFNULL(dds.remision, "") AS Remision,
            IFNULL(dds.facturaNumero, "") AS FacturaNumero,
            IFNULL(dds.actualizacion, "") AS Actualizacion,
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
            IFNULL(t.nombreTercero,"") AS nombreTercero,
            IFNULL(t.identificacionTercero,"") AS identificacionTercero,
            IFNULL(t.emailTercero,"") AS emailTercero,
            IFNULL(t.telefonoTercero,"") AS telefonoTercero
        FROM usuario u
        LEFT JOIN usuariorol ur ON u.idusuario = ur.usuario_idusuario
        LEFT JOIN serviciosparausuario spu ON u.idusuario = spu.usuario_idusuario AND spu.estadoRegistro = 1
        LEFT JOIN servicio s ON spu.servicio_idservicio = s.idservicio AND s.vehiculo_idvehiculo IS NOT NULL
        LEFT JOIN (
            SELECT servicio_idservicio, MAX(id) AS max_id
            FROM datosDelServicio
            WHERE estadoRegistro = 1
            GROUP BY servicio_idservicio
        ) dds_max ON s.idservicio = dds_max.servicio_idservicio
        LEFT JOIN datosDelServicio dds ON dds.id = dds_max.max_id AND dds.estadoRegistro=1
        LEFT JOIN (
            SELECT idservicio, MAX(id) AS max_id
            FROM estadoServicio
            WHERE estadoRegistro = 1
            GROUP BY idservicio
        ) es_max ON s.idservicio = es_max.idservicio
        LEFT JOIN estadoServicio es ON es.id = es_max.max_id AND es.estadoRegistro = 1
        LEFT JOIN p_estadoServicio pes ON es.idp_estadoservicio = pes.idp_estadoServicio
        LEFT JOIN usuario us ON es.usuario_idusuario = us.idusuario AND us.estadoRegistro = 1
        LEFT JOIN p_tipoidentificacion ti ON u.tipoIdentificacion_idtipoIdentificacion = ti.idtipoIdentificacion
        LEFT JOIN vehiculo v ON s.vehiculo_idvehiculo = v.idvehiculo
        LEFT JOIN p_comoseentero cse ON s.p_comoSeEntero_idp_comoSeEntero = cse.idp_comoSeEntero
        LEFT JOIN p_tiposervicio ts ON s.p_tipoServicio_idp_tipoServicio = ts.idp_tipoServicio
        LEFT JOIN p_comercial co ON s.p_comercial_idp_comercial = co.idp_comercial
        LEFT JOIN vehiculoporusuario vpu ON vpu.usuario_idusuario = u.idusuario AND vpu.vehiculo_idvehiculo = v.idvehiculo AND vpu.estadoRegistro = 1
        LEFT JOIN tercero t ON vpu.idvehiculoPorUsuario = t.idvehiculoPorUsuario',
        v_where,
        ' ORDER BY idServicio DESC'
    );

    -- Aplicar paginación si se solicita (p_limit = 0 = sin límite, para exportación)
    IF p_limit > 0 THEN
        SET v_sql = CONCAT(v_sql, ' LIMIT ', p_offset, ', ', p_limit);
    END IF;

    -- Ejecutar la consulta dinámica
    PREPARE stmt FROM v_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Total de filas sin LIMIT (para paginación en el frontend)
    SELECT FOUND_ROWS() AS total;
END //

DELIMITER ;


/*DROP PROCEDURE IF EXISTS consulta_buscarClientes;
DELIMITER //

CREATE PROCEDURE consulta_buscarClientes(
    IN p_nombre VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_identificacion VARCHAR(255),
    IN p_fechaDesde DATE,
    IN p_fechaHasta DATE,
    IN p_placa VARCHAR(45),
    IN p_imei VARCHAR(45),
    IN p_linea VARCHAR (45),
    IN p_extraParam VARCHAR(45),
    IN p_extraParamValue VARCHAR(45)
)
BEGIN
    -- Verificar y convertir valores nulos o vacíos a NULL
    SET p_nombre = NULLIF(p_nombre, '');
    SET p_email = NULLIF(p_email, '');
    SET p_identificacion = NULLIF(p_identificacion, '');
    SET p_placa = NULLIF(p_placa, '');
    SET p_imei = NULLIF(p_imei, '');
    SET p_linea = NULLIF(p_linea, '');
    SET p_extraParam = NULLIF(p_extraParam, '');
    SET p_extraParamValue = NULLIF(p_extraParamValue, '');
    
    -- Verificar y convertir fechas nulas o vacías a NULL
    IF p_fechaDesde = '' THEN
        SET p_fechaDesde = NULL;
    END IF;
    
    IF p_fechaHasta = '' THEN
        SET p_fechaHasta = NULL;
    END IF;

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
	LEFT JOIN usuariorol ur ON u.idusuario = ur.usuario_idusuario
	LEFT JOIN serviciosparausuario spu ON u.idusuario = spu.usuario_idusuario AND spu.estadoRegistro = 1
	LEFT JOIN servicio s ON spu.servicio_idservicio = s.idservicio AND s.vehiculo_idvehiculo IS NOT NULL
	LEFT JOIN (
		SELECT servicio_idservicio, MAX(id) AS max_id
		FROM datosDelServicio
		WHERE estadoRegistro = 1
		GROUP BY servicio_idservicio
	) dds_max ON s.idservicio = dds_max.servicio_idservicio
	LEFT JOIN datosDelServicio dds ON dds.id = dds_max.max_id AND dds.estadoRegistro=1
	LEFT JOIN (
        SELECT idservicio, MAX(id) AS max_id
        FROM estadoServicio
        WHERE estadoRegistro = 1
        GROUP BY idservicio
    ) es_max ON s.idservicio = es_max.idservicio
    LEFT JOIN estadoServicio es ON es.id = es_max.max_id AND es.estadoRegistro = 1
	LEFT JOIN p_estadoServicio pes ON es.idp_estadoservicio = pes.idp_estadoServicio
	LEFT JOIN usuario us ON es.usuario_idusuario = us.idusuario AND us.estadoRegistro = 1
	LEFT JOIN p_tipoidentificacion ti ON u.tipoIdentificacion_idtipoIdentificacion = ti.idtipoIdentificacion
	LEFT JOIN vehiculo v ON s.vehiculo_idvehiculo = v.idvehiculo
	LEFT JOIN p_comoseentero cse ON s.p_comoSeEntero_idp_comoSeEntero = cse.idp_comoSeEntero
	LEFT JOIN p_tiposervicio ts ON s.p_tipoServicio_idp_tipoServicio = ts.idp_tipoServicio
	LEFT JOIN p_comercial co ON s.p_comercial_idp_comercial = co.idp_comercial
	LEFT JOIN vehiculoporusuario vpu ON vpu.usuario_idusuario = u.idusuario AND vpu.vehiculo_idvehiculo = v.idvehiculo AND vpu.estadoRegistro = 1
	LEFT JOIN tercero t ON vpu.idvehiculoPorUsuario = t.idvehiculoPorUsuario
	WHERE
    (p_nombre IS NULL OR u.nombre LIKE CONCAT('%', p_nombre, '%'))
    AND (p_email IS NULL OR u.email = p_email)
    AND (p_identificacion IS NULL OR u.identificacion = p_identificacion)
    AND (p_imei IS NULL OR dds.imei LIKE CONCAT('%', p_imei, '%'))
    AND (p_linea IS NULL OR dds.linea LIKE CONCAT('%', p_linea, '%'))
    AND (p_fechaDesde IS NULL OR s.fechaInicioFormulario >= p_fechaDesde)
    AND (p_fechaHasta IS NULL OR s.fechaInicioFormulario <= p_fechaHasta)
    AND (p_placa IS NULL OR v.placa LIKE CONCAT('%', p_placa, '%'))
    AND ur.p_rol_idp_rol = 2
    -- AND dds.estadoRegistro=1
	AND es.id IS NOT NULL
    AND (p_extraParam IS NOT NULL AND p_extraParamValue IS NOT NULL) OR CONCAT('dds.', p_extraParam, ' LIKE = "%', p_extraParamValue, '%"')
ORDER BY idServicio DESC;
  
    
END //

DELIMITER ;*/
