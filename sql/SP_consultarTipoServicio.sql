DROP PROCEDURE IF EXISTS SP_consultarTipoServicio;

DELIMITER //

CREATE PROCEDURE SP_consultarTipoServicio()
BEGIN
    SELECT DISTINCT
        ts.idp_tipoServicio,
        ts.descripcion
    FROM
        p_tiposervicio ts
    WHERE
        estadoRegistro=1;
END //

DELIMITER ;
