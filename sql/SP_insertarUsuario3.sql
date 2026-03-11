DROP PROCEDURE IF EXISTS insertar_usuario;

DELIMITER //

CREATE PROCEDURE `insertar_usuario`(
    -- Parámetros de entrada
    IN p_nombre VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_identificacion VARCHAR(45),
    IN p_direccion VARCHAR(255),
    IN p_telefono VARCHAR(45),
    IN p_tipoIdentificacion_id INT,
    
    IN v_placa VARCHAR(45),
    IN v_marca VARCHAR(45),
    IN v_referencia VARCHAR(45),
    IN v_cilindraje VARCHAR(45),
    IN v_modelo VARCHAR(45),      
    
    IN s_fecha DATETIME,
    IN s_tratamiento BOOLEAN,
    IN s_recomendacion BOOLEAN,
    IN s_comercial INT,
    IN s_metodopago INT,
    IN s_comoseentero INT,
    IN s_tiposervicio INT
)
BEGIN
	DECLARE vehiculo_existente INT;
    DECLARE id_user INT;
    DECLARE id_car INT;
    DECLARE usuario_con_rol INT;
    DECLARE id_service INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error en el procedimiento insertar_usuario';
    END;

    
    
    START TRANSACTION;

    -- Insertar o actualizar usuario
    INSERT INTO usuario (nombre, email, identificacion, direccion, telefono, estadoRegistro, tipoIdentificacion_idtipoIdentificacion)
    VALUES (p_nombre, p_email, p_identificacion, p_direccion, p_telefono, 1, p_tipoIdentificacion_id)
    ON DUPLICATE KEY UPDATE
    nombre = VALUES(nombre),
    email = VALUES(email),
    direccion = VALUES(direccion),
    telefono = VALUES(telefono),
    estadoRegistro = 1,
    tipoIdentificacion_idtipoIdentificacion = VALUES(tipoIdentificacion_idtipoIdentificacion);
       
    -- Verificar si el vehículo ya existe
    SET vehiculo_existente = (SELECT COUNT(*) FROM vehiculo WHERE placa = v_placa AND estadoRegistro = 1);

    IF vehiculo_existente > 0 THEN
        -- Desactivar el vehículo existente
        UPDATE vehiculo SET estadoRegistro = 0 WHERE placa = v_placa AND estadoRegistro = 1;
    END IF;

    -- Insertar nuevo vehículo
    INSERT INTO vehiculo (placa, marca, referencia, cilindraje, modelo, estadoRegistro, fechaRegistro)
    VALUES (v_placa, v_marca, v_referencia, v_cilindraje, v_modelo, 1, NOW());

    -- Obtener IDs
    SELECT idusuario INTO id_user FROM usuario WHERE identificacion = p_identificacion AND estadoRegistro = 1;
    SELECT idvehiculo INTO id_car FROM vehiculo WHERE placa = v_placa AND estadoRegistro = 1;
	
    -- Verificar si el usuario ya tiene el rol deseado
    SET usuario_con_rol = (SELECT COUNT(*) FROM usuariorol WHERE usuario_idusuario = id_user AND p_rol_idp_rol = 2);

    -- Si el usuario no tiene el rol deseado, inserta un nuevo registro
    IF usuario_con_rol = 0 THEN
        INSERT INTO usuariorol (estadoRegistro, usuario_idusuario, p_rol_idp_rol)
        VALUES (1, id_user, 2);
    END IF;
    
    -- Registrar vehículo por cada cliente
    INSERT INTO vehiculoporusuario (estadoRegistro, fechaRegistro, vehiculo_idvehiculo, usuario_idusuario)
    VALUES (1, NOW(), id_car, id_user);
    
    -- Registrar el servicio solicitado por el cliente
    INSERT INTO servicio (fechaInicioFormulario, otro, tratamiento, recomendacion, p_comercial_idp_comercial, p_metodoPago_idp_metodoPago, p_comoseentero_idp_comoseentero, p_tiposervicio_idp_tiposervicio, vehiculo_idvehiculo)
    VALUES (s_fecha, NULL, s_tratamiento, s_recomendacion, s_comercial, s_metodopago, s_comoseentero, s_tiposervicio, id_car);

    SELECT LAST_INSERT_ID() INTO id_service;
    INSERT INTO serviciosparausuario (estadoRegistro, fechaRegistro, usuario_idusuario, servicio_idservicio)
    VALUES (1, NOW(), id_user, id_service);
    
    INSERT INTO estadoServicio (estadoRegistro, fechaRegistro, idp_estadoservicio, idservicio, usuario_idusuario)
    VALUES (1, NOW(), 1, id_service, 5);

    COMMIT;

    -- Devuelve el ID del servicio creado
    SELECT id_service AS servicio_id;
    
END //

DELIMITER ;
