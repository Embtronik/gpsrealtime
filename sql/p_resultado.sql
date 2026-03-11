DROP TABLE IF EXISTS p_resultado;

CREATE TABLE IF NOT EXISTS `mydb`.`p_resultado` (
  `idp_resultado` INT NOT NULL AUTO_INCREMENT,
  `descripcion` VARCHAR(45) NULL,
  `estadoRegistro` TINYINT(1) NULL,
  `fechaRegistro` TIMESTAMP(1) NULL,
  PRIMARY KEY (`idp_resultado`))
ENGINE = InnoDB;


DROP PROCEDURE IF EXISTS InsertarResultado;
DELIMITER //

CREATE PROCEDURE InsertarResultado(
    IN descripcion_param VARCHAR(45)
)
BEGIN
    INSERT INTO mydb.p_resultado (descripcion, estadoRegistro, fechaRegistro) 
    VALUES (descripcion_param, 1, NOW());
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS ObtenerResultados;
DELIMITER //
CREATE PROCEDURE ObtenerResultados()
BEGIN
    SELECT * FROM mydb.p_resultado WHERE estadoRegistro = 1;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS ActualizarResultado;
DELIMITER //
CREATE PROCEDURE ActualizarResultado(
    IN id_param INT,
    IN nueva_descripcion_param VARCHAR(45)
)
BEGIN
    UPDATE mydb.p_resultado 
    SET descripcion = nueva_descripcion_param
    WHERE idp_resultado = id_param;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS EliminarResultado;
DELIMITER //
CREATE PROCEDURE EliminarResultado(
    IN id_param INT
)
BEGIN
    UPDATE mydb.p_resultado 
    SET estadoRegistro = 0 
    WHERE idp_resultado = id_param;
END //
DELIMITER ;
