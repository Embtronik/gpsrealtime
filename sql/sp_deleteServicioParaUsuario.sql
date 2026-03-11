DROP PROCEDURE IF EXISTS sp_delete_servicioparausuario;
/* Este procedimiento borra logicamente un servicio de la relación de usuario con el servicio */
 
DELIMITER //

CREATE PROCEDURE sp_delete_servicioparausuario(IN servicio_id INT)
BEGIN
    -- Actualizar los registros relacionados con el servicio_id especificado
    UPDATE serviciosparausuario
    SET estadoRegistro = 0,
        fechaRegistro = NOW()
    WHERE servicio_idservicio = servicio_id;
END//

DELIMITER ;
