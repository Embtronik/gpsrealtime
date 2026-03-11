DROP PROCEDURE IF EXISTS sp_InsertarTercero;

DELIMITER //

CREATE PROCEDURE sp_InsertarTercero(
    IN p_nombreTercero VARCHAR(255),
    IN p_identificacionTercero VARCHAR(45),
    IN p_emailTercero VARCHAR(45),
    IN p_telefonoTercero VARCHAR(45),
    IN p_idvehiculoPorUsuario INT,
    IN p_idvehiculo INT,
    IN p_idusuario INT
)
BEGIN
    INSERT INTO tercero (
        nombreTercero,
        identificacionTercero,
        emailTercero,
        telefonoTercero,
        estadoRegistro,
        fechaRegistro,
        idvehiculoPorUsuario,
        idvehiculo,
        idusuario
    ) VALUES (
        p_nombreTercero,
        p_identificacionTercero,
        p_emailTercero,
        p_telefonoTercero,
        1, -- Estado activo
        NOW(), -- Fecha actual
        p_idvehiculoPorUsuario,
        p_idvehiculo,
        p_idusuario
    );
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS sp_ActualizarTercero;

DELIMITER //

CREATE PROCEDURE sp_ActualizarTercero(
    IN p_idtercero INT,
    IN p_nombreTercero VARCHAR(255),
    IN p_identificacionTercero VARCHAR(45),
    IN p_emailTercero VARCHAR(45),
    IN p_telefonoTercero VARCHAR(45),
    IN p_idvehiculoPorUsuario INT,
    IN p_idvehiculo INT,
    IN p_idusuario INT
)
BEGIN
    IF p_idtercero IS NULL THEN
        -- Si p_idtercero es nulo, crear un nuevo registro
        INSERT INTO tercero (
            nombreTercero,
            identificacionTercero,
            emailTercero,
            telefonoTercero,
            estadoRegistro,
            fechaRegistro,
            idvehiculoPorUsuario,
            idvehiculo,
            idusuario
        ) VALUES (
            p_nombreTercero,
            p_identificacionTercero,
            p_emailTercero,
            p_telefonoTercero,
            1,
            now(),
            p_idvehiculoPorUsuario,
            p_idvehiculo,
            p_idusuario
        );
    ELSE
        -- Si p_idtercero contiene un número válido, actualizar el registro
        UPDATE tercero
        SET
            nombreTercero = p_nombreTercero,
            identificacionTercero = p_identificacionTercero,
            emailTercero = p_emailTercero,
            telefonoTercero = p_telefonoTercero,
            estadoRegistro=1,
            fechaRegistro=now(),
            idvehiculoPorUsuario = p_idvehiculoPorUsuario,
            idvehiculo = p_idvehiculo,
            idusuario = p_idusuario
        WHERE idtercero = p_idtercero;
    END IF;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS sp_DesactivarTercero;

DELIMITER //

CREATE PROCEDURE sp_DesactivarTercero(
    IN p_idtercero INT
)
BEGIN
    UPDATE tercero
    SET estadoRegistro = 0
    WHERE idtercero = p_idtercero;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS sp_BuscarTerceroPorIDs;

DELIMITER //

CREATE PROCEDURE sp_BuscarTerceroPorIDs(
    IN p_idvehiculoPorUsuario INT,
    IN p_idvehiculo INT,
    IN p_idusuario INT
)
BEGIN
    SELECT *
    FROM tercero
    WHERE idvehiculoPorUsuario = p_idvehiculoPorUsuario
        AND idvehiculo = p_idvehiculo
        AND idusuario = p_idusuario
        AND estadoRegistro = 1; -- Solo registros activos
END //

DELIMITER ;
