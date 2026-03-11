-- Eliminar la tabla si existe
DROP TABLE IF EXISTS p_canalComercial;

-- Crear la nueva tabla
CREATE TABLE IF NOT EXISTS `mydb`.`p_canalComercial` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `descripcion` VARCHAR(45) NULL,
  `estadoRegistro` TINYINT(1) NULL,
  `fechaRegistro` DATETIME(1) NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB;




DROP PROCEDURE IF EXISTS InsertarCanalComercial;
-- SP para Insertar un nuevo registro
DELIMITER //
CREATE PROCEDURE InsertarCanalComercial(
    IN descripcion_param VARCHAR(45)
)
BEGIN
    INSERT INTO p_canalComercial (descripcion, estadoRegistro, fechaRegistro)
    VALUES (descripcion_param, 1, NOW());
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS ActualizarCanalComercial;
-- SP para Actualizar un registro existente
DELIMITER //
CREATE PROCEDURE ActualizarCanalComercial(
    IN id_param INT,
    IN nueva_descripcion_param VARCHAR(45)
)
BEGIN
    UPDATE p_canalComercial
    SET descripcion = nueva_descripcion_param,
        estadoRegistro = 1,
        fechaRegistro = NOW()
    WHERE id = id_param;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS EliminarCanalComercial;
-- SP para Cambiar el estadoRegistro a 0 en lugar de borrar
DELIMITER //
CREATE PROCEDURE EliminarCanalComercial(
    IN id_param INT
)
BEGIN
    UPDATE p_canalComercial
    SET estadoRegistro = 0,
        fechaRegistro = NOW()
    WHERE id = id_param;
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS ObtenerTodosCanalesComerciales;
-- SP para Obtener todos los registros
DELIMITER //
CREATE PROCEDURE ObtenerTodosCanalesComerciales()
BEGIN
    SELECT * FROM p_canalComercial where estadoRegistro=1;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS ObtenerCanalComercialPorID;
-- SP para Obtener un registro por ID
DELIMITER //
CREATE PROCEDURE ObtenerCanalComercialPorID(
    IN id_param INT
)
BEGIN
    SELECT * FROM p_canalComercial WHERE id = id_param;
END //

DELIMITER ;
