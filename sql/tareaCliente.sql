-- Eliminar la tabla si existe
DROP TABLE IF EXISTS tareacliente;

-- Eliminar la tabla si existe
DROP TABLE IF EXISTS mydb.tareaCliente;

-- Crear la tabla tareaCliente
CREATE TABLE IF NOT EXISTS mydb.tareaCliente (
    idtareaCliente INT NOT NULL AUTO_INCREMENT,
    fechaGestion TIMESTAMP NULL,
    descripcionGestion VARCHAR(200) NULL,
    fechaSeguimiento DATETIME NULL,
    fechaSiguienteTarea DATETIME NULL,
    cliente_idusuario INT NOT NULL,
    funcionario_idusuario INT NOT NULL,
    p_canalComercial_id INT NOT NULL,
    servicio_idservicio INT NULL,
    estadoRegistro TINYINT(1) NULL,
    fechaRegistro DATETIME NULL,
    p_resultado_idp_resultado INT NOT NULL,
    PRIMARY KEY (idtareaCliente, cliente_idusuario, funcionario_idusuario, p_canalComercial_id, servicio_idservicio, p_resultado_idp_resultado),
    INDEX fk_tareaCliente_usuario2_idx (funcionario_idusuario ASC),
    INDEX fk_tareaCliente_p_canalComercial1_idx (p_canalComercial_id ASC),
    INDEX fk_tareaCliente_servicio1_idx (servicio_idservicio ASC),
    INDEX fk_tareaCliente_p_resultado1_idx (p_resultado_idp_resultado ASC),
    CONSTRAINT fk_tareaCliente_usuario1
        FOREIGN KEY (cliente_idusuario)
        REFERENCES mydb.usuario (idusuario)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT fk_tareaCliente_usuario2
        FOREIGN KEY (funcionario_idusuario)
        REFERENCES mydb.usuario (idusuario)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT fk_tareaCliente_p_canalComercial1
        FOREIGN KEY (p_canalComercial_id)
        REFERENCES mydb.p_canalComercial (id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT fk_tareaCliente_servicio1
        FOREIGN KEY (servicio_idservicio)
        REFERENCES mydb.servicio (idservicio)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT fk_tareaCliente_p_resultado1
        FOREIGN KEY (p_resultado_idp_resultado)
        REFERENCES mydb.p_resultado (idp_resultado)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
) ENGINE = InnoDB;


DROP PROCEDURE IF EXISTS SP_InsertarTareaCliente;
-- SP para Insertar una nueva tareaCliente con validación de fechaSeguimiento
DELIMITER //

CREATE PROCEDURE SP_InsertarTareaCliente(
    IN descripcionGestion_param VARCHAR(200),
    IN fechaSeguimiento_param DATETIME,
    IN fechaSiguienteTarea_param DATETIME(1),
    IN cliente_idusuario_param INT,
    IN funcionario_idusuario_param INT,
    IN p_canalComercial_id_param INT,
    IN servicio_idservicio_param INT,
    IN p_resultado_idresultado_param INT
)
BEGIN
    -- Validar y ajustar fechaSeguimiento si no es válida
    IF fechaSeguimiento_param IS NULL OR fechaSeguimiento_param < CURDATE() THEN
        SET fechaSeguimiento_param = CURDATE();
    END IF;

    INSERT INTO tareaCliente (
        fechaGestion, descripcionGestion, fechaSeguimiento, fechaSiguienteTarea,
        cliente_idusuario, funcionario_idusuario, p_canalComercial_id, servicio_idservicio,
        estadoRegistro, fechaRegistro, p_resultado_idp_resultado
    )
    VALUES (
        NOW(), descripcionGestion_param, fechaSeguimiento_param, fechaSiguienteTarea_param,
        cliente_idusuario_param, funcionario_idusuario_param, p_canalComercial_id_param, servicio_idservicio_param,
        1, NOW(), p_resultado_idresultado_param
    );
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS SP_BuscarTareasPorClienteYServicio;

-- Crear el nuevo procedimiento almacenado
DELIMITER //
CREATE PROCEDURE SP_BuscarTareasPorClienteYServicio(
    IN cliente_idusuario_param INT,
    IN servicio_idservicio_param INT
)
BEGIN
    SELECT
    tc.idtareaCliente as idTarea,
    tc.fechaGestion as fechaContacto,
    fn.nombre as funcionario,
    cc.descripcion as metodoContacto,
    r.descripcion as  resultado,
    tc.descripcionGestion as descripcion,
    tc.fechaSiguienteTarea as proximo
    FROM tareaCliente tc
    inner join usuario cl on tc.cliente_idusuario=cl.idusuario
    inner join usuario fn on tc.funcionario_idusuario = fn.idusuario
    left join p_canalcomercial  cc on tc.p_canalComercial_id=cc.id
    left join p_resultado r on tc.p_resultado_idp_resultado=r.idp_resultado
    WHERE 
		tc.cliente_idusuario = cliente_idusuario_param
        AND tc.servicio_idservicio = servicio_idservicio_param
        AND tc.estadoRegistro = 1
	ORDER BY fechaContacto DESC;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS SP_ActualizarTareaCliente;

DELIMITER //
-- SP para Actualizar una tareaCliente existente
CREATE PROCEDURE SP_ActualizarTareaCliente(
    IN idtareaCliente_param INT,
    IN nueva_descripcionGestion_param VARCHAR(200),
    IN nueva_fechaSeguimiento_param DATETIME,
    IN nueva_fechaSiguienteTarea_param DATETIME(1)
)
BEGIN
    UPDATE tareaCliente
    SET descripcionGestion = nueva_descripcionGestion_param,
        fechaSeguimiento = nueva_fechaSeguimiento_param,
        fechaSiguienteTarea = nueva_fechaSiguienteTarea_param,
        estadoRegistro = 1,
        fechaRegistro = NOW()
    WHERE idtareaCliente = idtareaCliente_param;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS SP_EliminarTareaCliente;

DELIMITER //
-- SP para Cambiar el estadoRegistro a 0 en lugar de borrar
CREATE PROCEDURE SP_EliminarTareaCliente(
    IN idtareaCliente_param INT
)
BEGIN
    UPDATE tareaCliente
    SET estadoRegistro = 0,
        fechaRegistro = NOW()
    WHERE idtareaCliente = idtareaCliente_param;
END //

DELIMITER ;
