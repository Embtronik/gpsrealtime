DROP PROCEDURE IF EXISTS sp_insert_p_comercial;

DELIMITER $$

CREATE PROCEDURE sp_insert_p_comercial(
  IN p_descripcion VARCHAR(255)
)
BEGIN
  INSERT INTO p_comercial (descripcion, estadoRegistro, fechaRegistro)
  VALUES (p_descripcion, 1, NOW());
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS sp_read_p_comercial;
DELIMITER $$

CREATE PROCEDURE sp_read_p_comercial(
)
BEGIN
  SELECT * FROM p_comercial WHERE estadoRegistro=1;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_update_p_comercial;
DELIMITER $$

CREATE PROCEDURE sp_update_p_comercial(
  IN p_idp_comercial INT
)
BEGIN
  UPDATE p_comercial
  SET estadoRegistro = 0
  WHERE idp_comercial = p_idp_comercial;
END$$

DELIMITER ;
