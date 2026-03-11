DROP TABLE IF EXISTS tercero;

CREATE TABLE IF NOT EXISTS `mydb`.`tercero` (
  `idtercero` INT NOT NULL AUTO_INCREMENT,
  `nombreTercero` VARCHAR(255) NULL,
  `identificacionTercero` VARCHAR(45) NULL,
  `emailTercero` VARCHAR(45) NULL,
  `telefonoTercero` VARCHAR(45) NULL,
  `estadoRegistro` TINYINT(1) NULL,
  `fechaRegistro` DATETIME NULL,
  `idvehiculoPorUsuario` INT NOT NULL,
  `idvehiculo` INT NOT NULL,
  `idusuario` INT NOT NULL,
  PRIMARY KEY (`idtercero`, `idvehiculoPorUsuario`, `idvehiculo`, `idusuario`),
  INDEX `fk_tercero_vehiculoPorUsuario1_idx` (`idvehiculoPorUsuario` ASC, `idvehiculo` ASC, `idusuario` ASC),
  CONSTRAINT `fk_tercero_vehiculoPorUsuario1`
    FOREIGN KEY (`idvehiculoPorUsuario` , `idvehiculo` , `idusuario`)
    REFERENCES `mydb`.`vehiculoporusuario` (`idvehiculoPorUsuario` , `vehiculo_idvehiculo` , `usuario_idusuario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB