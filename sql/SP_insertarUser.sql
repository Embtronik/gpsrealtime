DROP PROCEDURE IF EXISTS insertar_user;

DELIMITER //

CREATE PROCEDURE `insertar_user`(
    IN p_name VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_identificacion VARCHAR(45),        
    IN p_direccion VARCHAR(255),
    IN p_telefono VARCHAR(45),
    IN p_tipoIdentificacion INT,
    IN p_username VARCHAR(45),
    IN p_password VARCHAR(45),
    IN p_rol INT
)
BEGIN
    DECLARE id_user INT;
    
    -- Verificar si el número de identificación ya existe en la tabla 'usuario'
    SELECT idusuario INTO id_user FROM usuario WHERE identificacion = p_identificacion;
    
    IF id_user IS NULL THEN
        -- El número de identificación no existe, insertar un nuevo registro en la tabla 'usuario'
        INSERT INTO usuario(nombre, email, identificacion, direccion, telefono, estadoRegistro, tipoIdentificacion_idtipoIdentificacion)
        VALUES(p_name, p_email, p_identificacion, p_direccion, p_telefono, 1, p_tipoIdentificacion);
        
        SET id_user = LAST_INSERT_ID(); -- Obtener el ID del nuevo registro insertado
    ELSE
        -- El número de identificación ya existe, actualizar los datos en la tabla 'usuario'
        UPDATE usuario
        SET nombre = p_name,
            email = CASE WHEN email = p_email THEN email ELSE p_email END,
            direccion = p_direccion,
            telefono = p_telefono,
            estadoRegistro = 1,
            tipoIdentificacion_idtipoIdentificacion = p_tipoIdentificacion
        WHERE idusuario = id_user;
    END IF;
    
    -- Registrar al usuario el rol seleccionado
    INSERT INTO usuariorol (estadoRegistro, usuario_idusuario, p_rol_idp_rol)
    VALUES (1, id_user, p_rol);
    
    -- Registrar las credenciales del usuario
    INSERT INTO usuariocredenciales(username, password, estadoRegistro, fechaRegistro, usuario_idusuario)
    VALUES (p_username, p_password, 1, NOW(), id_user);
    
END //

DELIMITER ;
