-- ============================================================
-- Gestión de Usuarios del Aplicativo
-- Módulo: Admin (rol 1) — listar, cambiar password, desactivar
-- ============================================================

DELIMITER //

-- ----------------------------------------------------------
-- SP_ListarUsuariosAcceso
-- Retorna todos los usuarios con credenciales activas
-- ----------------------------------------------------------
DROP PROCEDURE IF EXISTS SP_ListarUsuariosAcceso //
CREATE PROCEDURE SP_ListarUsuariosAcceso()
BEGIN
  SELECT
    u.idusuario,
    u.nombre,
    u.email,
    uc.idusuarioCredenciales,
    uc.username,
    uc.estadoRegistro,
    DATE_FORMAT(uc.fechaRegistro, '%Y-%m-%d') AS fechaRegistro,
    r.idp_rol                               AS id_rol,
    r.descripcion                           AS rol_nombre
  FROM usuario u
  JOIN usuarioCredenciales uc
       ON uc.usuario_idusuario = u.idusuario
  LEFT JOIN (
    SELECT usuario_idusuario, MIN(p_rol_idp_rol) AS p_rol_idp_rol
    FROM usuariorol
    WHERE p_rol_idp_rol NOT IN (2)
    GROUP BY usuario_idusuario
  ) subrol ON subrol.usuario_idusuario = u.idusuario
  LEFT JOIN p_rol r ON r.idp_rol = subrol.p_rol_idp_rol
  WHERE uc.estadoRegistro = 1
    AND EXISTS (
        SELECT 1 FROM usuariorol
        WHERE usuario_idusuario = u.idusuario
          AND p_rol_idp_rol != 2
    )
  ORDER BY u.nombre;
END //

-- ----------------------------------------------------------
-- SP_EditarUsuarioAcceso
-- Edita nombre, email, rol y opcionalmente la contraseña
-- ----------------------------------------------------------
DROP PROCEDURE IF EXISTS SP_EditarUsuarioAcceso //
CREATE PROCEDURE SP_EditarUsuarioAcceso(
  IN p_idusuario             INT,
  IN p_idusuarioCredenciales INT,
  IN p_nombre                VARCHAR(255),
  IN p_email                 VARCHAR(255),
  IN p_id_rol                INT,
  IN p_newPasswordHash       VARCHAR(255)
)
BEGIN
  UPDATE usuario
  SET    nombre = p_nombre,
         email  = p_email
  WHERE  idusuario = p_idusuario;

  IF p_newPasswordHash IS NOT NULL AND p_newPasswordHash != '' THEN
    UPDATE usuarioCredenciales
    SET    password = p_newPasswordHash
    WHERE  idusuarioCredenciales = p_idusuarioCredenciales;
  END IF;

  DELETE FROM usuariorol WHERE usuario_idusuario = p_idusuario;
  INSERT INTO usuariorol (usuario_idusuario, p_rol_idp_rol)
  VALUES (p_idusuario, p_id_rol);
END //

-- ----------------------------------------------------------
-- SP_CambiarPasswordUsuario
-- Actualiza el hash de contraseña de una credencial
-- ----------------------------------------------------------
DROP PROCEDURE IF EXISTS SP_CambiarPasswordUsuario //
CREATE PROCEDURE SP_CambiarPasswordUsuario(
  IN p_idusuarioCredenciales INT,
  IN p_newPasswordHash       VARCHAR(255)
)
BEGIN
  UPDATE usuarioCredenciales
  SET    password = p_newPasswordHash
  WHERE  idusuarioCredenciales = p_idusuarioCredenciales;
END //

-- ----------------------------------------------------------
-- SP_EliminarUsuarioLogico
-- Desactiva las credenciales (impide el login) sin borrar datos
-- ----------------------------------------------------------
DROP PROCEDURE IF EXISTS SP_EliminarUsuarioLogico //
CREATE PROCEDURE SP_EliminarUsuarioLogico(
  IN p_idusuarioCredenciales INT
)
BEGIN
  UPDATE usuarioCredenciales
  SET    estadoRegistro = 0
  WHERE  idusuarioCredenciales = p_idusuarioCredenciales;
END //

DELIMITER ;
