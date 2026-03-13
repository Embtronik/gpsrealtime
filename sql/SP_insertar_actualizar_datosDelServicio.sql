DROP PROCEDURE IF EXISTS insertar_actualizar_datosDelServicio;

DELIMITER //

CREATE PROCEDURE insertar_actualizar_datosDelServicio(
    IN p_id INT,
    IN p_fechaInicioServicio DATETIME,
    IN p_asignado INT,
    IN p_estado INT,
    IN p_operador VARCHAR(45),
    IN p_imei VARCHAR(45),
    IN p_linea VARCHAR(45),
    IN p_renovacion VARCHAR(45),
    IN p_fechaRenovacion DATETIME,
    IN p_recarga VARCHAR(45),
    IN p_fechaRecarga DATETIME,
    IN p_instalacion VARCHAR(45),
    IN p_instalador VARCHAR(100),
    IN p_valorInstalacion VARCHAR(45),
    IN p_pagoInstalacion VARCHAR(45),
    IN p_valorVenta VARCHAR(45),
    IN p_metodoPago VARCHAR(45),
    IN p_realizarFactura VARCHAR(45),
    IN p_manejo VARCHAR(45),
    IN p_ingresoPago VARCHAR(45),
    IN p_remision VARCHAR(45),
    IN p_facturaNumero VARCHAR(45),
    IN p_actualizacion VARCHAR(100),
    IN p_servicio_idservicio INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- Actualizar registro existente
    UPDATE estadoServicio
    SET estadoRegistro = 0,
        fechaRegistro = NOW()
    WHERE idservicio = p_servicio_idservicio;
    
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se encontraron registros para actualizar.';
    END IF;

    -- Insertar nuevo registro
    INSERT INTO estadoServicio (estadoRegistro, fechaRegistro, idp_estadoservicio, idservicio, usuario_idusuario)
    VALUES (1, NOW(), p_estado, p_servicio_idservicio, p_asignado);
    
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se pudo insertar el nuevo registro en estadoServicio.';
    END IF;

    IF p_id IS NOT NULL AND EXISTS (SELECT * FROM datosDelServicio WHERE id = p_id AND servicio_idservicio = p_servicio_idservicio) THEN
        -- Actualizar los datos existentes
        UPDATE datosDelServicio
        SET
            fechaInicioServicio = p_fechaInicioServicio,
            asignado = p_asignado,
            operador = p_operador,
            imei = p_imei,
            linea = p_linea,
            renovacion = p_renovacion,
            fechaRenovacion = p_fechaRenovacion,
            recarga = p_recarga,
            fechaRecarga = p_fechaRecarga,
            instalacion = p_instalacion,
            instalador = p_instalador,
            valorInstalacion = p_valorInstalacion,
            pagoInstalacion = p_pagoInstalacion,
            valorVenta = p_valorVenta,
            medotoPago = p_metodoPago,
            realizarFactura = p_realizarFactura,
            manejo = p_manejo,
            ingresoPago = p_ingresoPago,
            remision = p_remision,
            facturaNumero = p_facturaNumero,
            actualizacion = p_actualizacion,
            estadoRegistro = 1,
            fechaRegistro = NOW()
        WHERE id = p_id AND servicio_idservicio = p_servicio_idservicio;

        IF ROW_COUNT() = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se encontraron registros en datosDelServicio para actualizar.';
        END IF;
    ELSE
        -- Insertar nuevos datos
        INSERT INTO datosDelServicio (
            fechaInicioServicio,
            asignado,
            operador,
            imei,
            linea,
            renovacion,
            fechaRenovacion,
            recarga,
            fechaRecarga,
            instalacion,
            instalador,
            valorInstalacion,
            pagoInstalacion,
            valorVenta,
            medotoPago,
            realizarFactura,
            manejo,
            ingresoPago,
            remision,
            facturaNumero,
            actualizacion,
            estadoRegistro,
            fechaRegistro,
            servicio_idservicio
        )
        VALUES (
            p_fechaInicioServicio,
            p_asignado,
            p_operador,
            p_imei,
            p_linea,
            p_renovacion,
            p_fechaRenovacion,
            p_recarga,
            p_fechaRecarga,
            p_instalacion,
            p_instalador,
            p_valorInstalacion,
            p_pagoInstalacion,
            p_valorVenta,
            p_metodoPago,
            p_realizarFactura,
            p_manejo,
            p_ingresoPago,
            p_remision,
            p_facturaNumero,
            p_actualizacion,
            1,
            NOW(),
            p_servicio_idservicio
        );

        IF ROW_COUNT() = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se pudo insertar un nuevo registro en datosDelServicio.';
        END IF;
    END IF;

    COMMIT;
END //

DELIMITER ;
