-- ============================================================
-- MIGRACIÓN DE SEGURIDAD - GPS Real Time
-- Fecha: 2026-03-10
-- Descripción: Correcciones de vulnerabilidades de autenticación
--
-- EJECUTAR EN ORDEN. Hacer backup antes:
--   mysqldump -u gps -p mydb > backup_pre_security.sql
-- ============================================================

USE mydb;

-- ─────────────────────────────────────────────────────────────
-- 1. Ampliar columna password para soportar hashes bcrypt (60 chars)
--    y otros algoritmos futuros. VARCHAR(45) era insuficiente.
-- ─────────────────────────────────────────────────────────────
ALTER TABLE usuarioCredenciales
    MODIFY COLUMN password VARCHAR(255) NOT NULL;

-- ─────────────────────────────────────────────────────────────
-- 2. Actualizar SP insertar_user para aceptar contraseñas hash
--    (el PHP ahora envía el hash bcrypt antes de llamar al SP)
-- ─────────────────────────────────────────────────────────────
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
    IN p_password           VARCHAR(255),  -- ahora acepta hash bcrypt
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

-- ─────────────────────────────────────────────────────────────
-- 3. (Opcional) Tabla para rate limiting de login en base de datos
--    Solo necesaria si se prefiere DB en lugar del enfoque de archivos tmp.
--    El código PHP actual usa archivos temporales (no requiere esta tabla).
-- ─────────────────────────────────────────────────────────────
-- CREATE TABLE IF NOT EXISTS login_attempts (
--     id          INT AUTO_INCREMENT PRIMARY KEY,
--     ip_address  VARCHAR(45)  NOT NULL,
--     attempted_at DATETIME    NOT NULL DEFAULT NOW(),
--     INDEX idx_ip_time (ip_address, attempted_at)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─────────────────────────────────────────────────────────────
-- 4. NOTA SOBRE MIGRACIÓN DE CONTRASEÑAS EXISTENTES
-- ─────────────────────────────────────────────────────────────
-- Las contraseñas actualmente almacenadas en texto plano NO necesitan
-- ser migradas manualmente. El sistema aplica migración automática:
--   - En el próximo login exitoso de cada usuario, el sistema detecta
--     que la contraseña es texto plano, la verifica, y automáticamente
--     la reemplaza con su hash bcrypt. El usuario no nota ningún cambio.
--
-- Si prefieres migrarlas ahora con una contraseña temporal, ejecuta:
-- UPDATE usuarioCredenciales SET password = '<hash_bcrypt_generado_en_php>'
-- WHERE username = '<usuario>';
-- (Generar hash: php -r "echo password_hash('nueva_clave', PASSWORD_BCRYPT);")

-- ─────────────────────────────────────────────────────────────
-- 5. Agregar Rol 5 = Supervisor
--    (ids 1-4 ya están en prod: 1=admin, 2=cliente, 3=auxiliar, 4=Tecnico_instalador)
--    Este rol puede ver clientes (solo lectura) e inspecciones GPS.
-- ─────────────────────────────────────────────────────────────
INSERT INTO p_rol (idp_rol, descripcion, estadoRegistro)
VALUES (5, 'Supervisor', 1)
ON DUPLICATE KEY UPDATE descripcion = 'Supervisor', estadoRegistro = 1;

-- ─────────────────────────────────────────────────────────────
-- FIN DE MIGRACIÓN
-- ─────────────────────────────────────────────────────────────
