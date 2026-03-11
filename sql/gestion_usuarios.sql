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
    GROUP BY usuario_idusuario
  ) subrol ON subrol.usuario_idusuario = u.idusuario
  LEFT JOIN p_rol r ON r.idp_rol = subrol.p_rol_idp_rol
  WHERE uc.estadoRegistro = 1
  ORDER BY u.nombre;
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
