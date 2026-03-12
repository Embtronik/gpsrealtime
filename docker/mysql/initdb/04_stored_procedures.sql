-- ─────────────────────────────────────────────────────────────────────────────
-- 04_stored_procedures.sql
-- Recrea todos los procedimientos almacenados después del restore.
-- El backup de producción no incluye los SPs, por lo que deben recrearse aquí.
-- ─────────────────────────────────────────────────────────────────────────────
USE mydb;

-- ═══════════════════════════════════════════════════════════════════════════
-- AUTENTICACIÓN
-- ═══════════════════════════════════════════════════════════════════════════

DROP PROCEDURE IF EXISTS sp_validar_credenciales;

DELIMITER //

CREATE PROCEDURE `sp_validar_credenciales`(
  IN  p_usuario        VARCHAR(255),
  IN  p_password       VARCHAR(255),
  OUT p_id_usuario     INT,
  OUT p_nombre_usuario VARCHAR(255),
  OUT p_rol_usuario    INT,
  OUT p_rol_descripcion VARCHAR(45)
)
BEGIN
  DECLARE usuario_valido INT;

  SELECT COUNT(*)
  INTO usuario_valido
  FROM usuarioCredenciales
  WHERE username = p_usuario
    AND password = p_password
    AND estadoRegistro = 1;

  IF usuario_valido = 1 THEN
    SELECT u.idusuario, u.nombre, ur.p_rol_idp_rol, r.descripcion
    INTO p_id_usuario, p_nombre_usuario, p_rol_usuario, p_rol_descripcion
    FROM usuario u
    JOIN usuariorol ur ON u.idusuario = ur.usuario_idusuario
    JOIN usuarioCredenciales uc ON u.idusuario = uc.usuario_idusuario
    JOIN p_rol r ON r.idp_rol = ur.p_rol_idp_rol
    WHERE uc.username = p_usuario
      AND uc.estadoRegistro = 1
      AND ur.p_rol_idp_rol IN (1, 3, 4, 5)
    ORDER BY ur.idusuarioRol DESC
    LIMIT 1;
  ELSE
    SET p_id_usuario     = NULL;
    SET p_nombre_usuario = NULL;
    SET p_rol_usuario    = NULL;
  END IF;
END //

DELIMITER ;

-- ═══════════════════════════════════════════════════════════════════════════
-- REGISTRO DE CLIENTES
-- ═══════════════════════════════════════════════════════════════════════════

DROP PROCEDURE IF EXISTS insertar_usuario;

DELIMITER //

CREATE PROCEDURE `insertar_usuario`(
    IN p_nombre            VARCHAR(255),
    IN p_email             VARCHAR(255),
    IN p_identificacion    VARCHAR(45),
    IN p_direccion         VARCHAR(255),
    IN p_telefono          VARCHAR(45),
    IN p_tipoIdentificacion_id INT,
    IN v_placa             VARCHAR(45),
    IN v_marca             VARCHAR(45),
    IN v_referencia        VARCHAR(45),
    IN v_cilindraje        VARCHAR(45),
    IN v_modelo            VARCHAR(45),
    IN s_fecha             DATETIME,
    IN s_tratamiento       BOOLEAN,
    IN s_recomendacion     BOOLEAN,
    IN s_comercial         INT,
    IN s_metodopago        INT,
    IN s_comoseentero      INT,
    IN s_tiposervicio      INT
)
BEGIN
    SET SQL_SAFE_UPDATES = 0;

    INSERT INTO usuario (nombre, email, identificacion, direccion, telefono, estadoRegistro, tipoIdentificacion_idtipoIdentificacion)
    VALUES (p_nombre, p_email, p_identificacion, p_direccion, p_telefono, 1, p_tipoIdentificacion_id)
    ON DUPLICATE KEY UPDATE
        nombre     = VALUES(nombre),
        email      = VALUES(email),
        direccion  = VALUES(direccion),
        telefono   = VALUES(telefono),
        estadoRegistro = 1,
        tipoIdentificacion_idtipoIdentificacion = VALUES(tipoIdentificacion_idtipoIdentificacion);

    IF EXISTS (SELECT * FROM vehiculo WHERE placa = v_placa AND estadoRegistro = 1) THEN
        UPDATE vehiculo SET estadoRegistro = 0 WHERE placa = v_placa AND estadoRegistro = 1;
        INSERT INTO vehiculo (placa, marca, referencia, cilindraje, modelo, estadoRegistro, fechaRegistro)
        VALUES (v_placa, v_marca, v_referencia, v_cilindraje, v_modelo, 1, NOW());
    ELSE
        INSERT INTO vehiculo (placa, marca, referencia, cilindraje, modelo, estadoRegistro, fechaRegistro)
        VALUES (v_placa, v_marca, v_referencia, v_cilindraje, v_modelo, 1, NOW());
    END IF;

    SELECT idusuario  INTO @id_user FROM usuario  WHERE identificacion = p_identificacion AND estadoRegistro = 1;
    SELECT idvehiculo INTO @id_car  FROM vehiculo WHERE placa = v_placa AND estadoRegistro = 1;

    INSERT INTO usuariorol (estadoRegistro, usuario_idusuario, p_rol_idp_rol) VALUES (1, @id_user, 2);
    INSERT INTO vehiculoporusuario (estadoRegistro, fechaRegistro, vehiculo_idvehiculo, usuario_idusuario)
    VALUES (1, NOW(), @id_car, @id_user);
    INSERT INTO servicio (fechaInicioFormulario, otro, tratamiento, recomendacion, p_comercial_idp_comercial, p_metodoPago_idp_metodoPago, p_comoseentero_idp_comoseentero, p_tiposervicio_idp_tiposervicio, vehiculo_idvehiculo)
    VALUES (s_fecha, NULL, s_tratamiento, s_recomendacion, s_comercial, s_metodopago, s_comoseentero, s_tiposervicio, @id_car);

    SELECT LAST_INSERT_ID() INTO @id_service;
    INSERT INTO serviciosparausuario (estadoRegistro, fechaRegistro, usuario_idusuario, servicio_idservicio)
    VALUES (1, NOW(), @id_user, @id_service);
    INSERT INTO estadoServicio (estadoRegistro, fechaRegistro, idp_estadoservicio, idservicio, usuario_idusuario)
    VALUES (1, NOW(), 1, @id_service, 5);

    SET SQL_SAFE_UPDATES = 1;
END //

DELIMITER ;

-- ═══════════════════════════════════════════════════════════════════════════
-- GESTIÓN DE USUARIOS DEL APLICATIVO
-- ═══════════════════════════════════════════════════════════════════════════

DROP PROCEDURE IF EXISTS SP_ListarUsuariosAcceso;

DELIMITER //

CREATE PROCEDURE SP_ListarUsuariosAcceso()
BEGIN
  SELECT
    u.idusuario,
    u.nombre,
    u.email,
    uc.idusuarioCredenciales,
    uc.username,
    uc.estadoRegistro,
    DATE_FORMAT(uc.fechaRegistro, '%Y-%m-%d') AS fechaRegistro,
    r.idp_rol                                 AS id_rol,
    r.descripcion                             AS rol_nombre
  FROM usuario u
  JOIN usuarioCredenciales uc ON uc.usuario_idusuario = u.idusuario
  LEFT JOIN (
    SELECT usuario_idusuario, MIN(p_rol_idp_rol) AS p_rol_idp_rol
    FROM usuariorol
    WHERE p_rol_idp_rol NOT IN (2)
    GROUP BY usuario_idusuario
  ) subrol ON subrol.usuario_idusuario = u.idusuario
  LEFT JOIN p_rol r ON r.idp_rol = subrol.p_rol_idp_rol
  WHERE uc.estadoRegistro = 1
    AND EXISTS (
        SELECT 1 FROM usuariorol
        WHERE usuario_idusuario = u.idusuario
          AND p_rol_idp_rol != 2
    )
  ORDER BY u.nombre;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS SP_EditarUsuarioAcceso;

DELIMITER //

CREATE PROCEDURE SP_EditarUsuarioAcceso(
  IN p_idusuario             INT,
  IN p_idusuarioCredenciales INT,
  IN p_nombre                VARCHAR(255),
  IN p_email                 VARCHAR(255),
  IN p_id_rol                INT,
  IN p_newPasswordHash       VARCHAR(255)
)
BEGIN
  UPDATE usuario
  SET    nombre = p_nombre,
         email  = p_email
  WHERE  idusuario = p_idusuario;

  IF p_newPasswordHash IS NOT NULL AND p_newPasswordHash != '' THEN
    UPDATE usuarioCredenciales
    SET    password = p_newPasswordHash
    WHERE  idusuarioCredenciales = p_idusuarioCredenciales;
  END IF;

  DELETE FROM usuariorol WHERE usuario_idusuario = p_idusuario;
  INSERT INTO usuariorol (usuario_idusuario, p_rol_idp_rol)
  VALUES (p_idusuario, p_id_rol);
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS SP_CambiarPasswordUsuario;

DELIMITER //

CREATE PROCEDURE SP_CambiarPasswordUsuario(
  IN p_idusuarioCredenciales INT,
  IN p_newPasswordHash       VARCHAR(255)
)
BEGIN
  UPDATE usuarioCredenciales
  SET    password = p_newPasswordHash
  WHERE  idusuarioCredenciales = p_idusuarioCredenciales;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS SP_EliminarUsuarioLogico;

DELIMITER //

CREATE PROCEDURE SP_EliminarUsuarioLogico(
  IN p_idusuarioCredenciales INT
)
BEGIN
  UPDATE usuarioCredenciales
  SET    estadoRegistro = 0
  WHERE  idusuarioCredenciales = p_idusuarioCredenciales;
END //

DELIMITER ;

-- ═══════════════════════════════════════════════════════════════════════════
-- PARÁMETROS: COMERCIAL, COMO SE ENTERÓ, MÉTODO DE PAGO, TIPO SERVICIO
-- ═══════════════════════════════════════════════════════════════════════════

DROP PROCEDURE IF EXISTS sp_insert_p_comercial;
DELIMITER //
CREATE PROCEDURE sp_insert_p_comercial(IN p_descripcion VARCHAR(255))
BEGIN
  INSERT INTO p_comercial (descripcion, estadoRegistro, fechaRegistro) VALUES (p_descripcion, 1, NOW());
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_read_p_comercial;
DELIMITER //
CREATE PROCEDURE sp_read_p_comercial()
BEGIN
  SELECT * FROM p_comercial WHERE estadoRegistro = 1;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_update_p_comercial;
DELIMITER //
CREATE PROCEDURE sp_update_p_comercial(IN p_idp_comercial INT)
BEGIN
  UPDATE p_comercial SET estadoRegistro = 0 WHERE idp_comercial = p_idp_comercial;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_insert_p_comoseentero;
DELIMITER //
CREATE PROCEDURE sp_insert_p_comoseentero(IN p_descripcion VARCHAR(255))
BEGIN
  INSERT INTO p_comoseentero (descripcion, estadoRegistro) VALUES (p_descripcion, 1);
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_read_p_comoseentero;
DELIMITER //
CREATE PROCEDURE sp_read_p_comoseentero()
BEGIN
  SELECT * FROM p_comoseentero WHERE estadoRegistro = 1;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_update_p_comoseentero;
DELIMITER //
CREATE PROCEDURE sp_update_p_comoseentero(IN p_idp_comoseentero INT)
BEGIN
  UPDATE p_comoseentero SET estadoRegistro = 0 WHERE idp_comoseentero = p_idp_comoseentero;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_insert_p_metodopago;
DELIMITER //
CREATE PROCEDURE sp_insert_p_metodopago(IN p_descripcion VARCHAR(255))
BEGIN
  INSERT INTO p_metodopago (descripcion, estadoRegistro) VALUES (p_descripcion, 1);
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_read_p_metodopago;
DELIMITER //
CREATE PROCEDURE sp_read_p_metodopago()
BEGIN
  SELECT * FROM p_metodopago WHERE estadoRegistro = 1;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_update_p_metodopago;
DELIMITER //
CREATE PROCEDURE sp_update_p_metodopago(IN p_idp_metodopago INT)
BEGIN
  UPDATE p_metodopago SET estadoRegistro = 0 WHERE idp_metodopago = p_idp_metodopago;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_insert_p_servicios;
DELIMITER //
CREATE PROCEDURE sp_insert_p_servicios(IN p_descripcion VARCHAR(255))
BEGIN
  INSERT INTO p_tiposervicio (descripcion, estadoRegistro, fechaRegistro) VALUES (p_descripcion, 1, NOW());
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_read_p_servicios;
DELIMITER //
CREATE PROCEDURE sp_read_p_servicios()
BEGIN
  SELECT * FROM p_tiposervicio WHERE estadoRegistro = 1;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_update_p_servicios;
DELIMITER //
CREATE PROCEDURE sp_update_p_servicios(IN p_idp_servicios INT)
BEGIN
  UPDATE p_tiposervicio SET estadoRegistro = 0 WHERE idp_tipoServicio = p_idp_servicios;
END //
DELIMITER ;

-- ═══════════════════════════════════════════════════════════════════════════
-- CONSULTAS Y BÚSQUEDAS
-- ═══════════════════════════════════════════════════════════════════════════

DROP PROCEDURE IF EXISTS SP_consultarTipoServicio;

DELIMITER //

CREATE PROCEDURE SP_consultarTipoServicio()
BEGIN
  SELECT DISTINCT ts.idp_tipoServicio, ts.descripcion
  FROM p_tiposervicio ts
  WHERE estadoRegistro = 1;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS obtener_estadoServicio;

DELIMITER //

CREATE PROCEDURE obtener_estadoServicio()
BEGIN
  SELECT DISTINCT * FROM p_estadoServicio WHERE estadoRegistro = 1;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS obtener_usuarios_empresa;

DELIMITER //

CREATE PROCEDURE obtener_usuarios_empresa()
BEGIN
  SELECT DISTINCT u.idusuario, uc.username, ur.p_rol_idp_rol
  FROM usuario u
  INNER JOIN usuariorol ur ON u.idusuario = ur.usuario_idusuario AND ur.estadoRegistro = 1
  INNER JOIN usuarioCredenciales uc ON u.idusuario = uc.usuario_idusuario AND uc.estadoRegistro = 1
  WHERE ur.p_rol_idp_rol IN (1, 3);
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS obtener_clientes_Por_Usuario;

DELIMITER //

CREATE PROCEDURE obtener_clientes_Por_Usuario(IN idUser INT)
BEGIN
  SELECT
    u.idusuario       AS idUsuario,
    u.nombre          AS Nombre,
    s.idservicio      AS idServicio,
    s.fechaInicioFormulario AS FechaInicio,
    ts.descripcion    AS Servicio,
    dds.id            AS idDatosServicio,
    es.idp_estadoservicio AS Estado,
    IFNULL(dds.asignado,'')          AS Asignado,
    IFNULL(dds.operador,'')          AS Operador,
    IFNULL(dds.imei,'')              AS IMEI,
    IFNULL(dds.linea,'')             AS Linea,
    IFNULL(dds.renovacion,'')        AS Renovacion,
    IFNULL(dds.fechaRenovacion,NOW()) AS FechaRenovacion,
    IFNULL(dds.recarga,'')           AS Recarga,
    IFNULL(dds.fechaRecarga,NOW())   AS FechaRecarga,
    IFNULL(dds.instalacion,'')       AS Instalacion,
    IFNULL(dds.instalador,'')        AS Instalador,
    IFNULL(dds.valorInstalacion,'')  AS ValorInstalacion,
    IFNULL(dds.pagoInstalacion,'')   AS PagoInstalacion,
    IFNULL(dds.valorVenta,'')        AS ValorVenta,
    IFNULL(dds.medotoPago,'')        AS MetodoPago,
    IFNULL(dds.realizarFactura,'')   AS RealizarFactura,
    IFNULL(dds.manejo,'')            AS Manejo,
    IFNULL(dds.ingresoPago,'')       AS IngresoPago,
    IFNULL(dds.remision,'')          AS Remision,
    IFNULL(dds.facturaNumero,'')     AS FacturaNumero,
    IFNULL(dds.actualizacion,'')     AS Actualizacion,
    v.idvehiculo      AS idVehiculo,
    v.placa           AS Placa,
    v.marca           AS Marca,
    v.referencia      AS Referencia,
    v.modelo          AS Modelo,
    v.cilindraje      AS Cilindraje,
    ti.descripcion    AS TipoIdentificacion,
    u.identificacion  AS NumeroIdentificacion,
    u.telefono        AS Telefono,
    u.email           AS Email,
    u.direccion       AS Direccion,
    cse.descripcion   AS ComoSeEntero,
    us.idusuario      AS idAuxiliar
  FROM usuario u
  LEFT JOIN serviciosparausuario spu ON u.idusuario = spu.usuario_idusuario AND spu.estadoRegistro = 1
  LEFT JOIN servicio s ON spu.servicio_idservicio = s.idservicio
  LEFT JOIN estadoServicio es ON s.idservicio = es.idservicio AND es.estadoRegistro = 1
  LEFT JOIN usuario us ON es.usuario_idusuario = us.idusuario AND us.estadoRegistro = 1
  LEFT JOIN p_tipoidentificacion ti ON u.tipoIdentificacion_idtipoIdentificacion = ti.idtipoIdentificacion
  LEFT JOIN datosDelServicio dds ON s.idservicio = dds.servicio_idservicio AND dds.estadoRegistro = 1
  LEFT JOIN vehiculo v ON s.vehiculo_idvehiculo = v.idvehiculo AND v.estadoRegistro = 1
  LEFT JOIN p_comoseentero cse ON s.p_comoSeEntero_idp_comoSeEntero = cse.idp_comoSeEntero
  LEFT JOIN p_tiposervicio ts ON s.p_tipoServicio_idp_tipoServicio = ts.idp_tipoServicio
  WHERE v.placa IS NOT NULL
    AND es.idp_estadoservicio NOT IN (3, 4)
    AND us.idusuario = idUser
  ORDER BY Nombre;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS consulta_buscarClientes;

DELIMITER //

CREATE PROCEDURE consulta_buscarClientes(
    IN p_nombre          VARCHAR(255),
    IN p_email           VARCHAR(255),
    IN p_identificacion  VARCHAR(255),
    IN p_fechaDesde      DATE,
    IN p_fechaHasta      DATE,
    IN p_placa           VARCHAR(45),
    IN p_imei            VARCHAR(45),
    IN p_linea           VARCHAR(45),
    IN p_extraParam      VARCHAR(45),
    IN p_extraParamValue VARCHAR(45),
    IN p_limit           INT,
    IN p_offset          INT
)
BEGIN
    DECLARE v_sql   LONGTEXT;
    DECLARE v_where LONGTEXT;

    SET p_nombre          = NULLIF(p_nombre, '');
    SET p_email           = NULLIF(p_email, '');
    SET p_identificacion  = NULLIF(p_identificacion, '');
    SET p_placa           = NULLIF(p_placa, '');
    SET p_imei            = NULLIF(p_imei, '');
    SET p_linea           = NULLIF(p_linea, '');
    SET p_extraParam      = NULLIF(p_extraParam, '');
    SET p_extraParamValue = NULLIF(p_extraParamValue, '');

    SET v_where = ' WHERE 1=1';

    IF p_nombre IS NOT NULL THEN
        SET v_where = CONCAT(v_where, ' AND u.nombre LIKE ''%', p_nombre, '%''');
    END IF;
    IF p_email IS NOT NULL THEN
        SET v_where = CONCAT(v_where, ' AND u.email = ''', p_email, '''');
    END IF;
    IF p_identificacion IS NOT NULL THEN
        SET v_where = CONCAT(v_where, ' AND u.identificacion = ''', p_identificacion, '''');
    END IF;
    IF p_imei IS NOT NULL THEN
        SET v_where = CONCAT(v_where, ' AND dds.imei LIKE ''%', p_imei, '%''');
    END IF;
    IF p_linea IS NOT NULL THEN
        SET v_where = CONCAT(v_where, ' AND dds.linea LIKE ''%', p_linea, '%''');
    END IF;
    IF p_fechaDesde IS NOT NULL THEN
        SET v_where = CONCAT(v_where, ' AND s.fechaInicioFormulario >= ''', p_fechaDesde, '''');
    END IF;
    IF p_fechaHasta IS NOT NULL THEN
        SET v_where = CONCAT(v_where, ' AND s.fechaInicioFormulario <= ''', p_fechaHasta, '''');
    END IF;
    IF p_placa IS NOT NULL THEN
        SET v_where = CONCAT(v_where, ' AND v.placa LIKE ''%', p_placa, '%''');
    END IF;
    IF p_extraParam IS NOT NULL AND p_extraParamValue IS NOT NULL THEN
        SET v_where = CONCAT(v_where, ' AND dds.', p_extraParam, ' LIKE ''%', p_extraParamValue, '%''');
    END IF;

    SET v_where = CONCAT(v_where, ' AND ur.p_rol_idp_rol = 2');
    SET v_where = CONCAT(v_where, ' AND es.id IS NOT NULL');

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
            FROM datosDelServicio WHERE estadoRegistro = 1 GROUP BY servicio_idservicio
        ) dds_max ON s.idservicio = dds_max.servicio_idservicio
        LEFT JOIN datosDelServicio dds ON dds.id = dds_max.max_id AND dds.estadoRegistro = 1
        LEFT JOIN (
            SELECT idservicio, MAX(id) AS max_id
            FROM estadoServicio WHERE estadoRegistro = 1 GROUP BY idservicio
        ) es_max ON s.idservicio = es_max.idservicio
        LEFT JOIN estadoServicio es ON es.id = es_max.max_id AND es.estadoRegistro = 1
        LEFT JOIN p_estadoServicio pes ON es.idp_estadoservicio = pes.idp_estadoServicio
        LEFT JOIN usuario us ON es.usuario_idusuario = us.idusuario AND us.estadoRegistro = 1
        LEFT JOIN p_tipoidentificacion ti ON u.tipoIdentificacion_idtipoIdentificacion = ti.idtipoIdentificacion
        LEFT JOIN vehiculo v ON s.vehiculo_idvehiculo = v.idvehiculo
        LEFT JOIN p_comoseentero cse ON s.p_comoSeEntero_idp_comoSeEntero = cse.idp_comoSeEntero
        LEFT JOIN p_tiposervicio ts ON s.p_tipoServicio_idp_tipoServicio = ts.idp_tipoServicio
        LEFT JOIN p_comercial co ON s.p_comercial_idp_comercial = co.idp_comercial
        LEFT JOIN vehiculoporusuario vpu ON vpu.usuario_idusuario = u.idusuario
            AND vpu.vehiculo_idvehiculo = v.idvehiculo
            AND vpu.estadoRegistro = 1
        LEFT JOIN tercero t ON vpu.idvehiculoPorUsuario = t.idvehiculoPorUsuario',
        v_where,
        ' ORDER BY idServicio DESC'
    );

    IF p_limit > 0 THEN
        SET v_sql = CONCAT(v_sql, ' LIMIT ', p_offset, ', ', p_limit);
    END IF;

    SET @v_sql = v_sql;
    PREPARE stmt FROM @v_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    SELECT FOUND_ROWS() AS total;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS SP_consultarClienteEditar;

DELIMITER //

CREATE PROCEDURE SP_consultarClienteEditar(IN p_servicio INT, IN p_vehiculo INT)
BEGIN
    DECLARE resultadosEncontrados INT;

    SELECT
        u.idusuario           AS idUsuario,
        u.nombre              AS Nombre,
        s.idservicio          AS idServicio,
        s.fechaInicioFormulario AS FechaInicio,
        ts.idp_tipoServicio   AS idtiposervicio,
        ts.descripcion        AS Servicio,
        dds.id                AS idDatosServicio,
        es.idp_estadoservicio AS Estado,
        IFNULL(dds.asignado,'')          AS Asignado,
        IFNULL(dds.operador,'')          AS Operador,
        IFNULL(dds.imei,'')              AS IMEI,
        IFNULL(dds.linea,'')             AS Linea,
        IFNULL(dds.renovacion,'')        AS Renovacion,
        IFNULL(dds.fechaRenovacion,NOW()) AS FechaRenovacion,
        IFNULL(dds.recarga,'')           AS Recarga,
        IFNULL(dds.fechaRecarga,NOW())   AS FechaRecarga,
        IFNULL(dds.instalacion,'')       AS Instalacion,
        IFNULL(dds.instalador,'')        AS Instalador,
        IFNULL(dds.valorInstalacion,'')  AS ValorInstalacion,
        IFNULL(dds.pagoInstalacion,'')   AS PagoInstalacion,
        IFNULL(dds.valorVenta,'')        AS ValorVenta,
        IFNULL(dds.medotoPago,'')        AS MetodoPago,
        IFNULL(dds.realizarFactura,'')   AS RealizarFactura,
        IFNULL(dds.manejo,'')            AS Manejo,
        IFNULL(dds.ingresoPago,'')       AS IngresoPago,
        IFNULL(dds.remision,'')          AS Remision,
        IFNULL(dds.facturaNumero,'')     AS FacturaNumero,
        IFNULL(dds.actualizacion,'')     AS Actualizacion,
        v.idvehiculo          AS idVehiculo,
        v.placa               AS Placa,
        v.marca               AS Marca,
        v.referencia          AS Referencia,
        v.modelo              AS Modelo,
        v.cilindraje          AS Cilindraje,
        ti.idtipoIdentificacion AS idtipoIdentificacion,
        ti.descripcion        AS TipoIdentificacion,
        u.identificacion      AS NumeroIdentificacion,
        u.telefono            AS Telefono,
        u.email               AS Email,
        u.direccion           AS Direccion,
        cse.descripcion       AS ComoSeEntero,
        cse.idp_comoSeEntero  AS idcomoSeEntero,
        us.idusuario          AS idAuxiliar,
        co.descripcion        AS Comercial,
        co.idp_comercial      AS idComercial,
        t.idtercero           AS idTercero,
        IFNULL(t.nombreTercero,'')         AS nombreTercero,
        IFNULL(t.identificacionTercero,'') AS identificacionTercero,
        IFNULL(t.emailTercero,'')          AS emailTercero,
        IFNULL(t.telefonoTercero,'')       AS telefonoTercero
    FROM usuario u
    LEFT JOIN serviciosparausuario spu ON u.idusuario = spu.usuario_idusuario AND spu.estadoRegistro = 1
    LEFT JOIN servicio s ON spu.servicio_idservicio = s.idservicio
    LEFT JOIN (
        SELECT idservicio, MAX(id) AS max_id
        FROM estadoServicio WHERE estadoRegistro = 1 GROUP BY idservicio
    ) es_max ON s.idservicio = es_max.idservicio
    LEFT JOIN estadoServicio es ON es.id = es_max.max_id AND es.estadoRegistro = 1
    LEFT JOIN usuario us ON es.usuario_idusuario = us.idusuario AND us.estadoRegistro = 1
    LEFT JOIN p_tipoidentificacion ti ON u.tipoIdentificacion_idtipoIdentificacion = ti.idtipoIdentificacion
    LEFT JOIN (
        SELECT servicio_idservicio, MAX(id) AS max_id
        FROM datosDelServicio WHERE estadoRegistro = 1 GROUP BY servicio_idservicio
    ) dds_max ON s.idservicio = dds_max.servicio_idservicio
    LEFT JOIN datosDelServicio dds ON dds.id = dds_max.max_id AND dds.estadoRegistro = 1
    LEFT JOIN vehiculo v ON s.vehiculo_idvehiculo = v.idvehiculo
    LEFT JOIN p_comoseentero cse ON s.p_comoSeEntero_idp_comoSeEntero = cse.idp_comoSeEntero
    LEFT JOIN p_tiposervicio ts ON s.p_tipoServicio_idp_tipoServicio = ts.idp_tipoServicio
    LEFT JOIN p_comercial co ON s.p_comercial_idp_comercial = co.idp_comercial
    LEFT JOIN vehiculoporusuario vpu ON vpu.usuario_idusuario = u.idusuario AND vpu.vehiculo_idvehiculo = v.idvehiculo AND vpu.estadoRegistro = 1
    LEFT JOIN tercero t ON vpu.idvehiculoPorUsuario = t.idvehiculoPorUsuario
    WHERE s.idServicio = p_servicio AND v.idVehiculo = p_vehiculo;

    SET resultadosEncontrados = ROW_COUNT();
    IF resultadosEncontrados = 0 THEN
        SELECT 'No se encontraron resultados' AS mensaje;
    END IF;
END //

DELIMITER ;

-- ═══════════════════════════════════════════════════════════════════════════
-- DATOS DEL SERVICIO Y ACTUALIZACIÓN DE PROCESO
-- ═══════════════════════════════════════════════════════════════════════════

DROP PROCEDURE IF EXISTS insertar_actualizar_datosDelServicio;

DELIMITER //

CREATE PROCEDURE insertar_actualizar_datosDelServicio(
    IN p_id                  INT,
    IN p_fechaInicioServicio DATETIME,
    IN p_asignado            INT,
    IN p_estado              INT,
    IN p_operador            VARCHAR(45),
    IN p_imei                VARCHAR(45),
    IN p_linea               VARCHAR(45),
    IN p_renovacion          VARCHAR(45),
    IN p_fechaRenovacion     DATETIME,
    IN p_recarga             VARCHAR(45),
    IN p_fechaRecarga        DATETIME,
    IN p_instalacion         VARCHAR(45),
    IN p_instalador          VARCHAR(100),
    IN p_valorInstalacion    VARCHAR(45),
    IN p_pagoInstalacion     VARCHAR(45),
    IN p_valorVenta          VARCHAR(45),
    IN p_metodoPago          VARCHAR(45),
    IN p_realizarFactura     VARCHAR(45),
    IN p_manejo              VARCHAR(45),
    IN p_ingresoPago         VARCHAR(45),
    IN p_remision            VARCHAR(45),
    IN p_facturaNumero       VARCHAR(45),
    IN p_actualizacion       VARCHAR(100),
    IN p_servicio_idservicio INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; END;

    START TRANSACTION;

    UPDATE estadoServicio SET estadoRegistro = 0, fechaRegistro = NOW()
    WHERE idservicio = p_servicio_idservicio;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontraron registros para actualizar.';
    END IF;

    INSERT INTO estadoServicio (estadoRegistro, fechaRegistro, idp_estadoservicio, idservicio, usuario_idusuario)
    VALUES (1, NOW(), p_estado, p_servicio_idservicio, p_asignado);

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudo insertar el nuevo registro en estadoServicio.';
    END IF;

    IF p_id IS NOT NULL AND EXISTS (SELECT * FROM datosdelservicio WHERE id = p_id AND servicio_idservicio = p_servicio_idservicio) THEN
        UPDATE datosDelServicio
        SET fechaInicioServicio = p_fechaInicioServicio,
            asignado            = p_asignado,
            operador            = p_operador,
            imei                = p_imei,
            linea               = p_linea,
            renovacion          = p_renovacion,
            fechaRenovacion     = p_fechaRenovacion,
            recarga             = p_recarga,
            fechaRecarga        = p_fechaRecarga,
            instalacion         = p_instalacion,
            instalador          = p_instalador,
            valorInstalacion    = p_valorInstalacion,
            pagoInstalacion     = p_pagoInstalacion,
            valorVenta          = p_valorVenta,
            medotoPago          = p_metodoPago,
            realizarFactura     = p_realizarFactura,
            manejo              = p_manejo,
            ingresoPago         = p_ingresoPago,
            remision            = p_remision,
            facturaNumero       = p_facturaNumero,
            actualizacion       = p_actualizacion,
            estadoRegistro      = 1,
            fechaRegistro       = NOW()
        WHERE id = p_id AND servicio_idservicio = p_servicio_idservicio;

        IF ROW_COUNT() = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontraron registros en datosDelServicio para actualizar.';
        END IF;
    ELSE
        INSERT INTO datosdelservicio (
            fechaInicioServicio, asignado, operador, imei, linea, renovacion, fechaRenovacion,
            recarga, fechaRecarga, instalacion, instalador, valorInstalacion, pagoInstalacion,
            valorVenta, medotoPago, realizarFactura, manejo, ingresoPago, remision,
            facturaNumero, actualizacion, estadoRegistro, fechaRegistro, servicio_idservicio
        ) VALUES (
            p_fechaInicioServicio, p_asignado, p_operador, p_imei, p_linea, p_renovacion, p_fechaRenovacion,
            p_recarga, p_fechaRecarga, p_instalacion, p_instalador, p_valorInstalacion, p_pagoInstalacion,
            p_valorVenta, p_metodoPago, p_realizarFactura, p_manejo, p_ingresoPago, p_remision,
            p_facturaNumero, p_actualizacion, 1, NOW(), p_servicio_idservicio
        );

        IF ROW_COUNT() = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudo insertar un nuevo registro en datosDelServicio.';
        END IF;
    END IF;

    COMMIT;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS sp_ActualizarServicio;

DELIMITER //

CREATE PROCEDURE sp_ActualizarServicio(
    IN p_idservicio                      INT,
    IN p_fechaInicioFormulario           DATETIME,
    IN p_otro                            VARCHAR(255),
    IN p_tratamiento                     TINYINT,
    IN p_p_comercial_idp_comercial       INT,
    IN p_p_metodoPago_idp_metodoPago     INT,
    IN p_p_comoSeEntero_idp_comoSeEntero INT,
    IN p_p_tipoServicio_idp_tipoServicio INT,
    IN p_recomendacion                   TINYINT,
    IN p_vehiculo_idvehiculo             INT
)
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count FROM servicio WHERE idservicio = p_idservicio;
    IF v_count > 0 THEN
        UPDATE servicio
        SET fechaInicioFormulario             = p_fechaInicioFormulario,
            otro                              = p_otro,
            tratamiento                       = p_tratamiento,
            p_comercial_idp_comercial         = p_p_comercial_idp_comercial,
            p_metodoPago_idp_metodoPago       = p_p_metodoPago_idp_metodoPago,
            p_comoSeEntero_idp_comoSeEntero   = p_p_comoSeEntero_idp_comoSeEntero,
            p_tipoServicio_idp_tipoServicio   = p_p_tipoServicio_idp_tipoServicio,
            recomendacion                     = p_recomendacion,
            vehiculo_idvehiculo               = p_vehiculo_idvehiculo
        WHERE idservicio = p_idservicio;
    ELSE
        INSERT INTO servicio (fechaInicioFormulario, otro, tratamiento, p_comercial_idp_comercial,
            p_metodoPago_idp_metodoPago, p_comoSeEntero_idp_comoSeEntero,
            p_tipoServicio_idp_tipoServicio, recomendacion, vehiculo_idvehiculo)
        VALUES (p_fechaInicioFormulario, p_otro, p_tratamiento, p_p_comercial_idp_comercial,
            p_p_metodoPago_idp_metodoPago, p_p_comoSeEntero_idp_comoSeEntero,
            p_p_tipoServicio_idp_tipoServicio, p_recomendacion, p_vehiculo_idvehiculo);
    END IF;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS sp_ActualizarVehiculo;

DELIMITER //

CREATE PROCEDURE sp_ActualizarVehiculo(
    IN p_idvehiculo  INT,
    IN p_placa       VARCHAR(45),
    IN p_marca       VARCHAR(45),
    IN p_referencia  VARCHAR(45),
    IN p_modelo      VARCHAR(45),
    IN p_cilindraje  VARCHAR(45)
)
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count FROM vehiculo WHERE idvehiculo = p_idvehiculo;
    IF v_count > 0 THEN
        UPDATE vehiculo SET placa = p_placa, marca = p_marca, referencia = p_referencia,
            cilindraje = p_cilindraje, modelo = p_modelo
        WHERE idvehiculo = p_idvehiculo;
    ELSE
        INSERT INTO vehiculo (placa, marca, referencia, cilindraje, modelo, estadoRegistro, fechaRegistro)
        VALUES (p_placa, p_marca, p_referencia, p_cilindraje, p_modelo, 1, NOW());
    END IF;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS sp_ActualizarUsuario;

DELIMITER //

CREATE PROCEDURE sp_ActualizarUsuario(
    IN p_idusuario                              INT,
    IN p_nombre                                 VARCHAR(255),
    IN p_email                                  VARCHAR(255),
    IN p_identificacion                         VARCHAR(45),
    IN p_direccion                              VARCHAR(255),
    IN p_telefono                               VARCHAR(45),
    IN p_tipoIdentificacion_idtipoIdentificacion INT
)
BEGIN
    DECLARE v_idusuario INT;
    SELECT idusuario INTO v_idusuario FROM usuario WHERE idusuario = p_idusuario;
    IF v_idusuario IS NOT NULL THEN
        UPDATE usuario
        SET nombre = p_nombre, email = p_email, identificacion = p_identificacion,
            direccion = p_direccion, telefono = p_telefono,
            tipoIdentificacion_idtipoIdentificacion = p_tipoIdentificacion_idtipoIdentificacion
        WHERE idusuario = p_idusuario;
    ELSE
        UPDATE usuario
        SET nombre = p_nombre, email = p_email, direccion = p_direccion,
            telefono = p_telefono,
            tipoIdentificacion_idtipoIdentificacion = p_tipoIdentificacion_idtipoIdentificacion
        WHERE identificacion = p_identificacion;
    END IF;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS SP_ActualizarDatosProceso;

DELIMITER //

CREATE PROCEDURE SP_ActualizarDatosProceso(
    IN p_idUsuario            INT,
    IN p_nombre               VARCHAR(255),
    IN p_idServicio           INT,
    IN p_fechaInicio          DATETIME,
    IN p_tipoServicio         INT,
    IN p_idDatosServicio      INT,
    IN p_estadoServicio       INT,
    IN p_operador             VARCHAR(45),
    IN p_IMEI                 VARCHAR(45),
    IN p_linea                VARCHAR(45),
    IN p_renovacion           VARCHAR(45),
    IN p_fechaRenovacion      DATETIME,
    IN p_recarga              VARCHAR(45),
    IN p_fechaRecarga         DATETIME,
    IN p_instalacion          VARCHAR(45),
    IN p_instalador           VARCHAR(100),
    IN p_valorInstalacion     VARCHAR(45),
    IN p_pagoInstalacion      VARCHAR(45),
    IN p_valorVenta           VARCHAR(45),
    IN p_metodoPago           VARCHAR(45),
    IN p_realizarFactura      VARCHAR(45),
    IN p_manejo               VARCHAR(45),
    IN p_ingresoPago          VARCHAR(45),
    IN p_remision             VARCHAR(45),
    IN p_facturaNumero        VARCHAR(45),
    IN p_actualizacion        VARCHAR(100),
    IN p_idVehiculo           INT,
    IN p_placa                VARCHAR(45),
    IN p_marca                VARCHAR(45),
    IN p_referencia           VARCHAR(45),
    IN p_modelo               VARCHAR(45),
    IN p_cilindraje           VARCHAR(45),
    IN p_tipoIdentificacion   VARCHAR(45),
    IN p_numeroIdentificacion VARCHAR(45),
    IN p_telefono             VARCHAR(45),
    IN p_email                VARCHAR(255),
    IN p_direccion            VARCHAR(255),
    IN p_comercial            INT,
    IN p_comoSeEntero         INT,
    IN p_idAuxiliar           INT,
    IN p_idTercero            INT,
    IN p_nombreTercero        VARCHAR(255),
    IN p_identificacionTercero VARCHAR(45),
    IN p_emailTercero         VARCHAR(45),
    IN p_telefonoTercero      VARCHAR(45)
)
BEGIN
    CALL insertar_actualizar_datosDelServicio(
        p_idDatosServicio, p_fechaInicio, p_idAuxiliar, p_estadoServicio,
        p_operador, p_IMEI, p_linea, p_renovacion, p_fechaRenovacion,
        p_recarga, p_fechaRecarga, p_instalacion, p_instalador, p_valorInstalacion,
        p_pagoInstalacion, p_valorVenta, p_metodoPago, p_realizarFactura, p_manejo,
        p_ingresoPago, p_remision, p_facturaNumero, p_actualizacion, p_idServicio);

    CALL sp_ActualizarServicio(
        p_idServicio, p_fechaInicio,
        (SELECT otro FROM servicio WHERE idservicio = p_idServicio),
        (SELECT tratamiento FROM servicio WHERE idservicio = p_idServicio),
        p_comercial,
        (SELECT p_metodoPago_idp_metodoPago FROM servicio WHERE idservicio = p_idServicio),
        p_comoSeEntero, p_tipoServicio,
        (SELECT recomendacion FROM servicio WHERE idservicio = p_idServicio),
        p_idVehiculo);

    CALL sp_ActualizarVehiculo(p_idVehiculo, p_placa, p_marca, p_referencia, p_modelo, p_cilindraje);

    CALL sp_ActualizarUsuario(p_idUsuario, p_nombre, p_email, p_numeroIdentificacion,
        p_direccion, p_telefono, p_tipoIdentificacion);

    CALL sp_ActualizarTercero(
        p_idTercero, p_nombreTercero, p_identificacionTercero, p_emailTercero, p_telefonoTercero,
        (SELECT vpu.idvehiculoPorUsuario FROM vehiculoporusuario vpu
         INNER JOIN usuario u ON vpu.usuario_idusuario = u.idusuario
         INNER JOIN vehiculo v ON vpu.vehiculo_idvehiculo = v.idvehiculo
         WHERE vpu.estadoRegistro = 1 AND vpu.vehiculo_idvehiculo = p_idVehiculo AND vpu.usuario_idusuario = p_idUsuario),
        p_idVehiculo, p_idUsuario);
END //

DELIMITER ;

-- ═══════════════════════════════════════════════════════════════════════════
-- TAREAS DE CLIENTES
-- ═══════════════════════════════════════════════════════════════════════════

DROP PROCEDURE IF EXISTS SP_InsertarTareaCliente;

DELIMITER //

CREATE PROCEDURE SP_InsertarTareaCliente(
    IN descripcionGestion_param     VARCHAR(200),
    IN fechaSeguimiento_param       DATETIME,
    IN fechaSiguienteTarea_param    DATETIME,
    IN cliente_idusuario_param      INT,
    IN funcionario_idusuario_param  INT,
    IN p_canalComercial_id_param    INT,
    IN servicio_idservicio_param    INT,
    IN p_resultado_idresultado_param INT
)
BEGIN
    IF fechaSeguimiento_param IS NULL OR fechaSeguimiento_param < CURDATE() THEN
        SET fechaSeguimiento_param = CURDATE();
    END IF;

    INSERT INTO tareaCliente (
        fechaGestion, descripcionGestion, fechaSeguimiento, fechaSiguienteTarea,
        cliente_idusuario, funcionario_idusuario, p_canalComercial_id, servicio_idservicio,
        estadoRegistro, fechaRegistro, p_resultado_idp_resultado
    ) VALUES (
        NOW(), descripcionGestion_param, fechaSeguimiento_param, fechaSiguienteTarea_param,
        cliente_idusuario_param, funcionario_idusuario_param, p_canalComercial_id_param, servicio_idservicio_param,
        1, NOW(), p_resultado_idresultado_param
    );
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS SP_BuscarTareasPorClienteYServicio;

DELIMITER //

CREATE PROCEDURE SP_BuscarTareasPorClienteYServicio(
    IN cliente_idusuario_param   INT,
    IN servicio_idservicio_param INT
)
BEGIN
    SELECT
        tc.idtareaCliente           AS idTarea,
        tc.fechaGestion             AS fechaContacto,
        fn.nombre                   AS funcionario,
        cc.descripcion              AS metodoContacto,
        r.descripcion               AS resultado,
        tc.descripcionGestion       AS descripcion,
        tc.fechaSiguienteTarea      AS proximo
    FROM tareaCliente tc
    INNER JOIN usuario cl ON tc.cliente_idusuario = cl.idusuario
    INNER JOIN usuario fn ON tc.funcionario_idusuario = fn.idusuario
    LEFT JOIN p_canalComercial cc ON tc.p_canalComercial_id = cc.id
    LEFT JOIN p_resultado r ON tc.p_resultado_idp_resultado = r.idp_resultado
    WHERE tc.cliente_idusuario = cliente_idusuario_param
      AND tc.servicio_idservicio = servicio_idservicio_param
      AND tc.estadoRegistro = 1
    ORDER BY fechaContacto DESC;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS SP_ActualizarTareaCliente;

DELIMITER //

CREATE PROCEDURE SP_ActualizarTareaCliente(
    IN idtareaCliente_param            INT,
    IN nueva_descripcionGestion_param  VARCHAR(200),
    IN nueva_fechaSeguimiento_param    DATETIME,
    IN nueva_fechaSiguienteTarea_param DATETIME
)
BEGIN
    UPDATE tareaCliente
    SET descripcionGestion  = nueva_descripcionGestion_param,
        fechaSeguimiento    = nueva_fechaSeguimiento_param,
        fechaSiguienteTarea = nueva_fechaSiguienteTarea_param,
        estadoRegistro      = 1,
        fechaRegistro       = NOW()
    WHERE idtareaCliente = idtareaCliente_param;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS SP_EliminarTareaCliente;

DELIMITER //

CREATE PROCEDURE SP_EliminarTareaCliente(IN idtareaCliente_param INT)
BEGIN
    UPDATE tareaCliente
    SET estadoRegistro = 0, fechaRegistro = NOW()
    WHERE idtareaCliente = idtareaCliente_param;
END //

DELIMITER ;

-- ═══════════════════════════════════════════════════════════════════════════
-- TERCEROS Y VEHÍCULO POR USUARIO
-- ═══════════════════════════════════════════════════════════════════════════

DROP PROCEDURE IF EXISTS sp_InsertarTercero;

DELIMITER //

CREATE PROCEDURE sp_InsertarTercero(
    IN p_nombreTercero         VARCHAR(255),
    IN p_identificacionTercero VARCHAR(45),
    IN p_emailTercero          VARCHAR(45),
    IN p_telefonoTercero       VARCHAR(45),
    IN p_idvehiculoPorUsuario  INT,
    IN p_idvehiculo            INT,
    IN p_idusuario             INT
)
BEGIN
    INSERT INTO tercero (nombreTercero, identificacionTercero, emailTercero, telefonoTercero,
        estadoRegistro, fechaRegistro, idvehiculoPorUsuario, idvehiculo, idusuario)
    VALUES (p_nombreTercero, p_identificacionTercero, p_emailTercero, p_telefonoTercero,
        1, NOW(), p_idvehiculoPorUsuario, p_idvehiculo, p_idusuario);
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS sp_ActualizarTercero;

DELIMITER //

CREATE PROCEDURE sp_ActualizarTercero(
    IN p_idtercero             INT,
    IN p_nombreTercero         VARCHAR(255),
    IN p_identificacionTercero VARCHAR(45),
    IN p_emailTercero          VARCHAR(45),
    IN p_telefonoTercero       VARCHAR(45),
    IN p_idvehiculoPorUsuario  INT,
    IN p_idvehiculo            INT,
    IN p_idusuario             INT
)
BEGIN
    IF p_idtercero IS NULL THEN
        INSERT INTO tercero (nombreTercero, identificacionTercero, emailTercero, telefonoTercero,
            estadoRegistro, fechaRegistro, idvehiculoPorUsuario, idvehiculo, idusuario)
        VALUES (p_nombreTercero, p_identificacionTercero, p_emailTercero, p_telefonoTercero,
            1, NOW(), p_idvehiculoPorUsuario, p_idvehiculo, p_idusuario);
    ELSE
        UPDATE tercero
        SET nombreTercero         = p_nombreTercero,
            identificacionTercero = p_identificacionTercero,
            emailTercero          = p_emailTercero,
            telefonoTercero       = p_telefonoTercero,
            estadoRegistro        = 1,
            fechaRegistro         = NOW(),
            idvehiculoPorUsuario  = p_idvehiculoPorUsuario,
            idvehiculo            = p_idvehiculo,
            idusuario             = p_idusuario
        WHERE idtercero = p_idtercero;
    END IF;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS sp_DesactivarTercero;

DELIMITER //

CREATE PROCEDURE sp_DesactivarTercero(IN p_idtercero INT)
BEGIN
    UPDATE tercero SET estadoRegistro = 0 WHERE idtercero = p_idtercero;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS sp_BuscarTerceroPorIDs;

DELIMITER //

CREATE PROCEDURE sp_BuscarTerceroPorIDs(
    IN p_idvehiculoPorUsuario INT,
    IN p_idvehiculo           INT,
    IN p_idusuario            INT
)
BEGIN
    SELECT * FROM tercero
    WHERE idvehiculoPorUsuario = p_idvehiculoPorUsuario
      AND idvehiculo = p_idvehiculo
      AND idusuario  = p_idusuario
      AND estadoRegistro = 1;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS sp_delete_servicioparausuario;

DELIMITER //

CREATE PROCEDURE sp_delete_servicioparausuario(IN servicio_id INT)
BEGIN
    UPDATE serviciosparausuario
    SET estadoRegistro = 0, fechaRegistro = NOW()
    WHERE servicio_idservicio = servicio_id;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS ObtenerTodosCanalesComerciales;

DELIMITER //

CREATE PROCEDURE ObtenerTodosCanalesComerciales()
BEGIN
    SELECT * FROM p_canalComercial WHERE estadoRegistro = 1;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS ObtenerResultados;

DELIMITER //

CREATE PROCEDURE ObtenerResultados()
BEGIN
    SELECT * FROM p_resultado WHERE estadoRegistro = 1;
END //

DELIMITER ;

-- ── Métricas: servicios por mes en un rango de fechas ─────────────────────────
DROP PROCEDURE IF EXISTS sp_MetricasServiciosPorMes;

DELIMITER //

CREATE PROCEDURE sp_MetricasServiciosPorMes(
    IN p_fechaDesde DATE,
    IN p_fechaHasta DATE
)
BEGIN
    SELECT
        YEAR(s.fechaInicioFormulario)  AS anio,
        MONTH(s.fechaInicioFormulario) AS mes,
        ts.descripcion                 AS tipoServicio,
        COUNT(DISTINCT s.idservicio)   AS total
    FROM servicio s
    INNER JOIN p_tiposervicio ts ON s.p_tipoServicio_idp_tipoServicio = ts.idp_tipoServicio
    INNER JOIN serviciosparausuario spu ON spu.servicio_idservicio = s.idservicio AND spu.estadoRegistro = 1
    INNER JOIN usuariorol ur ON ur.usuario_idusuario = spu.usuario_idusuario AND ur.p_rol_idp_rol = 2
    WHERE s.fechaInicioFormulario BETWEEN p_fechaDesde AND p_fechaHasta
      AND s.vehiculo_idvehiculo IS NOT NULL
    GROUP BY anio, mes, ts.descripcion
    ORDER BY anio, mes, ts.descripcion;
END //

DELIMITER ;
