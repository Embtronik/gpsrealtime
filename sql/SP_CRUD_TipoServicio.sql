DROP PROCEDURE IF EXISTS sp_insert_p_servicios;

DELIMITER $$

CREATE PROCEDURE sp_insert_p_servicios(
  IN p_descripcion VARCHAR(255)
)
BEGIN
  INSERT INTO p_tiposervicio (descripcion, estadoRegistro, fechaRegistro)
  VALUES (p_descripcion, 1, now());
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS sp_read_p_servicios;
DELIMITER $$

CREATE PROCEDURE sp_read_p_servicios(
)
BEGIN
  SELECT * FROM p_tiposervicio WHERE estadoRegistro=1;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_update_p_servicios;
DELIMITER $$

CREATE PROCEDURE sp_update_p_servicios(
  IN p_idp_servicios INT
)
BEGIN
  UPDATE p_tiposervicio
  SET estadoRegistro = 0
  WHERE idp_tipoServicio = p_idp_servicios;
END$$

DELIMITER ;
