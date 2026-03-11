 DROP PROCEDURE IF EXISTS insertar_usuario;

 delimiter //
CREATE PROCEDURE `insertar_usuario`(
    IN p_nombre VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_identificacion VARCHAR(45),
    IN p_direccion VARCHAR(255),
    IN p_telefono VARCHAR(45),
    IN p_tipoIdentificacion_id INT(11),
    
    IN v_placa VARCHAR(45),
    IN v_marca VARCHAR(45),
    IN v_referencia VARCHAR(45),
    IN v_cilindraje VARCHAR(45),
    IN v_modelo VARCHAR(45),      
    
    IN s_fecha DATETIME(1),
    IN s_tratamiento BOOLEAN,
    IN s_recomendacion BOOLEAN,
    IN s_comercial INT(11),
    IN s_metodopago INT(11),
    IN s_comoseentero INT(11),
    IN s_tiposervicio INT(11)
)
BEGIN
    SET SQL_SAFE_UPDATES = 0;

    INSERT INTO usuario (nombre, email, identificacion, direccion, telefono, estadoRegistro, tipoIdentificacion_idtipoIdentificacion)
	VALUES (p_nombre, p_email, p_identificacion, p_direccion, p_telefono, 1, p_tipoIdentificacion_id)
	ON DUPLICATE KEY UPDATE
	nombre = VALUES(nombre),
	email = VALUES(email),
	direccion = VALUES(direccion),
	telefono = VALUES(telefono),
	estadoRegistro = 1,
	tipoIdentificacion_idtipoIdentificacion = VALUES(tipoIdentificacion_idtipoIdentificacion);
       
    IF EXISTS (SELECT * FROM vehiculo WHERE placa = v_placa and estadoRegistro=1) THEN
		UPDATE vehiculo	SET estadoRegistro= 0 WHERE placa = v_placa and estadoRegistro=1;
        INSERT INTO vehiculo (placa, marca, referencia, cilindraje, modelo, estadoRegistro,fechaRegistro)
		VALUES (v_placa, v_marca, v_referencia, v_cilindraje, v_modelo,1, now());
	ELSE
		INSERT INTO vehiculo (placa, marca, referencia, cilindraje, modelo, estadoRegistro,fechaRegistro)
		VALUES (v_placa, v_marca, v_referencia, v_cilindraje, v_modelo,1, now());
	END IF;

    SELECT idusuario INTO @id_user FROM usuario WHERE identificacion = p_identificacion AND estadoRegistro = 1;
    SELECT idvehiculo INTO @id_car FROM vehiculo WHERE placa = v_placa and estadoRegistro=1;
	
    SELECT @id_user;
    /*REGISTRA AL CLIENTE CON EL ROL DE CLIENTE */
    INSERT INTO usuariorol (estadoRegistro, usuario_idusuario,p_rol_idp_rol)
	VALUES (1,@id_user,2);
    
    /* REGISTRA VEHÍCULO POR CADA CLIENTE */
    INSERT INTO vehiculoporusuario (estadoRegistro,fechaRegistro,vehiculo_idvehiculo, usuario_idusuario)
    VALUES (1, now(), @id_car, @id_user);
    
    /* REGISTRA EL SERVICIO SOLICITADO POR EL CLIENTE*/
	INSERT INTO servicio (fechaInicioFormulario, otro, tratamiento, recomendacion, p_comercial_idp_comercial, p_metodoPago_idp_metodoPago, p_comoseentero_idp_comoseentero, p_tiposervicio_idp_tiposervicio, vehiculo_idvehiculo)
	VALUES (s_fecha, NULL, s_tratamiento, s_recomendacion, s_comercial, s_metodopago, s_comoseentero, s_tiposervicio, @id_car);

    SELECT LAST_INSERT_ID() INTO @id_service;
    INSERT INTO serviciosparausuario(estadoRegistro,fechaRegistro,usuario_idusuario,servicio_idservicio)
    VALUES (1,now(), @id_user, @id_service);
    
    INSERT INTO estadoServicio (estadoRegistro, fechaRegistro, idp_estadoservicio, idservicio, usuario_idusuario)
    VALUES(1,now(),1,@id_service,5);
    
SET SQL_SAFE_UPDATES = 1;    
END //
delimiter ;