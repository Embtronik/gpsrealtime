DROP PROCEDURE IF EXISTS sp_ActualizarServicio;


DELIMITER //

CREATE PROCEDURE sp_ActualizarServicio(
    IN p_idservicio INT,
    IN p_fechaInicioFormulario DATETIME,
    IN p_otro VARCHAR(255),
    IN p_tratamiento TINYINT,
    IN p_p_comercial_idp_comercial INT,
    IN p_p_metodoPago_idp_metodoPago INT,
    IN p_p_comoSeEntero_idp_comoSeEntero INT,
    IN p_p_tipoServicio_idp_tipoServicio INT,
    IN p_recomendacion TINYINT,
    IN p_vehiculo_idvehiculo INT
)
BEGIN
    DECLARE v_count INT;
    
    -- Verificar si el servicio existe
    SELECT COUNT(*) INTO v_count
    FROM servicio
    WHERE idservicio = p_idservicio;
    
    IF v_count > 0 THEN
        -- El servicio existe, actualizarlo
        UPDATE servicio
        SET
            fechaInicioFormulario = p_fechaInicioFormulario,
            otro = p_otro,
            tratamiento = p_tratamiento,
            p_comercial_idp_comercial = p_p_comercial_idp_comercial,
            p_metodoPago_idp_metodoPago = p_p_metodoPago_idp_metodoPago,
            p_comoSeEntero_idp_comoSeEntero = p_p_comoSeEntero_idp_comoSeEntero,
            p_tipoServicio_idp_tipoServicio = p_p_tipoServicio_idp_tipoServicio,
            recomendacion = p_recomendacion,
            vehiculo_idvehiculo = p_vehiculo_idvehiculo
        WHERE idservicio = p_idservicio;
    ELSE
        -- El servicio no existe, crear uno nuevo
        INSERT INTO servicio (
            fechaInicioFormulario,
            otro,
            tratamiento,
            p_comercial_idp_comercial,
            p_metodoPago_idp_metodoPago,
            p_comoSeEntero_idp_comoSeEntero,
            p_tipoServicio_idp_tipoServicio,
            recomendacion,
            vehiculo_idvehiculo
        ) VALUES (
            p_fechaInicioFormulario,
            p_otro,
            p_tratamiento,
            p_p_comercial_idp_comercial,
            p_p_metodoPago_idp_metodoPago,
            p_p_comoSeEntero_idp_comoSeEntero,
            p_p_tipoServicio_idp_tipoServicio,
            p_recomendacion,
            p_vehiculo_idvehiculo
        );
    END IF;
END //

DELIMITER ;
