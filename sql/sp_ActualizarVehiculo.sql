DROP PROCEDURE IF EXISTS sp_ActualizarVehiculo;


DELIMITER //

CREATE PROCEDURE sp_ActualizarVehiculo(
    IN p_idvehiculo INT,
    IN p_placa VARCHAR(45),
    IN p_marca VARCHAR(45),
    IN p_referencia VARCHAR(45),
    IN p_modelo VARCHAR(45),
    IN p_cilindraje VARCHAR(45)
)
BEGIN
    DECLARE v_count INT;
    
    -- Verificar si el vehículo existe con estadoRegistro=1
    SELECT COUNT(*) INTO v_count
    FROM vehiculo
    WHERE idvehiculo = p_idvehiculo;
        -- AND estadoRegistro = 1;
    
    IF v_count > 0 THEN
        -- El vehículo existe con estadoRegistro=1, actualizarlo
        UPDATE vehiculo
        SET
            placa = p_placa,
            marca = p_marca,
            referencia = p_referencia,
            cilindraje = p_cilindraje,
            modelo = p_modelo
        WHERE idvehiculo = p_idvehiculo;
    ELSE
        -- El vehículo no existe o está desactivado, crear uno nuevo
        INSERT INTO vehiculo (
            placa,
            marca,
            referencia,
            cilindraje,
            modelo,
            estadoRegistro,
            fechaRegistro
        ) VALUES (
            p_placa,
            p_marca,
            p_referencia,
            p_cilindraje,
            p_modelo,
            1, -- Estado activo
            NOW() -- Fecha actual
        );
    END IF;
END //

DELIMITER ;
