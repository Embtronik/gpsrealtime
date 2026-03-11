DROP PROCEDURE IF EXISTS sp_insert_p_metodopago;

DELIMITER $$

CREATE PROCEDURE sp_insert_p_metodopago(
  IN p_descripcion VARCHAR(255)
)
BEGIN
  INSERT INTO p_metodopago (descripcion, estadoRegistro)
  VALUES (p_descripcion, 1);
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS sp_read_p_metodopago;
DELIMITER $$

CREATE PROCEDURE sp_read_p_metodopago(
)
BEGIN
  SELECT * FROM p_metodopago WHERE estadoRegistro=1;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_update_p_metodopago;
DELIMITER $$

CREATE PROCEDURE sp_update_p_metodopago(
  IN p_idp_metodopago INT
)
BEGIN
  UPDATE p_metodopago
  SET estadoRegistro = 0
  WHERE idp_metodopago = p_idp_metodopago;
END$$

DELIMITER ;
