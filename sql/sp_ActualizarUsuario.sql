DROP PROCEDURE IF EXISTS sp_ActualizarUsuario;


DELIMITER //

CREATE PROCEDURE sp_ActualizarUsuario(
    IN p_idusuario INT,
    IN p_nombre VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_identificacion VARCHAR(45),
    IN p_direccion VARCHAR(255),
    IN p_telefono VARCHAR(45),
    IN p_tipoIdentificacion_idtipoIdentificacion INT
)
BEGIN
    DECLARE v_idusuario INT;
    
    -- Verificar si el idUsuario existe
    SELECT idusuario INTO v_idusuario
    FROM usuario
    WHERE idusuario = p_idusuario;
    
    IF v_idusuario IS NOT NULL THEN
        -- El idUsuario existe, actualizar el registro
        UPDATE usuario
        SET
            nombre = p_nombre,
            email = p_email,
            identificacion = p_identificacion,
            direccion = p_direccion,
            telefono = p_telefono,
            tipoIdentificacion_idtipoIdentificacion = p_tipoIdentificacion_idtipoIdentificacion
        WHERE idusuario = p_idusuario;
    ELSE
        -- El idUsuario no existe, intentar actualizar por identificación
        UPDATE usuario
        SET
            nombre = p_nombre,
            email = p_email,
            direccion = p_direccion,
            telefono = p_telefono,
            tipoIdentificacion_idtipoIdentificacion = p_tipoIdentificacion_idtipoIdentificacion
        WHERE identificacion = p_identificacion;
    END IF;
END //

DELIMITER ;
