-- ─────────────────────────────────────────────────────────────────────────────
-- 03_security_migration.sql
-- Se ejecuta automáticamente después de 01_restore.sql y 02_supervisor_role.sql
-- Aplica las migraciones de seguridad necesarias post-restore:
--   1. Amplía columna password a VARCHAR(255) para soportar bcrypt
--   2. Recrea SP insertar_user con parámetro password VARCHAR(255)
--   3. Inserta rol Supervisor id=5 (redundante con 02 pero idempotente)
-- ─────────────────────────────────────────────────────────────────────────────
USE mydb;

-- 1. Ampliar columna password para bcrypt (60 chars mínimo, usamos 255)
ALTER TABLE usuarioCredenciales
    MODIFY COLUMN password VARCHAR(255) NOT NULL;

-- 2. Recrear SP insertar_user aceptando hash bcrypt
DROP PROCEDURE IF EXISTS insertar_user;

DELIMITER //

CREATE PROCEDURE `insertar_user`(
    IN p_name               VARCHAR(255),
    IN p_email              VARCHAR(255),
    IN p_identificacion     VARCHAR(45),
    IN p_direccion          VARCHAR(255),
    IN p_telefono           VARCHAR(45),
    IN p_tipoIdentificacion INT,
    IN p_username           VARCHAR(45),
    IN p_password           VARCHAR(255),
    IN p_rol                INT
)
BEGIN
    DECLARE id_user INT DEFAULT NULL;

    SELECT idusuario INTO id_user FROM usuario WHERE identificacion = p_identificacion;

    IF id_user IS NULL THEN
        INSERT INTO usuario(nombre, email, identificacion, direccion, telefono, estadoRegistro, tipoIdentificacion_idtipoIdentificacion)
        VALUES(p_name, p_email, p_identificacion, p_direccion, p_telefono, 1, p_tipoIdentificacion);
        SET id_user = LAST_INSERT_ID();
    ELSE
        UPDATE usuario
        SET nombre       = p_name,
            email        = p_email,
            direccion    = p_direccion,
            telefono     = p_telefono,
            estadoRegistro = 1,
            tipoIdentificacion_idtipoIdentificacion = p_tipoIdentificacion
        WHERE idusuario = id_user;
    END IF;

    INSERT INTO usuariorol (estadoRegistro, usuario_idusuario, p_rol_idp_rol)
    VALUES (1, id_user, p_rol);

    INSERT INTO usuariocredenciales(username, password, estadoRegistro, fechaRegistro, usuario_idusuario)
    VALUES (p_username, p_password, 1, NOW(), id_user);
END //

DELIMITER ;

-- 3. Insertar rol Supervisor id=5 (idempotente)
INSERT INTO p_rol (idp_rol, descripcion, estadoRegistro)
VALUES (5, 'Supervisor', 1)
ON DUPLICATE KEY UPDATE descripcion = 'Supervisor', estadoRegistro = 1;
