DROP PROCEDURE IF EXISTS sp_insert_p_comoseentero;

DELIMITER $$

CREATE PROCEDURE sp_insert_p_comoseentero(
  IN p_descripcion VARCHAR(255)
)
BEGIN
  INSERT INTO p_comoseentero (descripcion, estadoRegistro)
  VALUES (p_descripcion, 1);
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS sp_read_p_comoseentero;
DELIMITER $$

CREATE PROCEDURE sp_read_p_comoseentero(
)
BEGIN
  SELECT * FROM p_comoseentero WHERE estadoRegistro=1;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_update_p_comoseentero;
DELIMITER $$

CREATE PROCEDURE sp_update_p_comoseentero(
  IN p_idp_comoseentero INT
)
BEGIN
  UPDATE p_comoseentero
  SET estadoRegistro = 0
  WHERE idp_comoseentero = p_idp_comoseentero;
END$$

DELIMITER ;
