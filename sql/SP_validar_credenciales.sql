DELIMITER $$

CREATE PROCEDURE `sp_validar_credenciales`(
  IN p_usuario VARCHAR(255),
  IN p_password VARCHAR(255),
  OUT p_id_usuario INT,
  OUT p_nombre_usuario VARCHAR(255),
  OUT p_rol_usuario INT,
  OUT p_rol_descripcion VARCHAR(45)
)
BEGIN
  DECLARE usuario_valido INT;

  SELECT COUNT(*)
  INTO usuario_valido
  FROM usuarioCredenciales
  WHERE username = p_usuario
    AND password = p_password
    AND estadoRegistro = 1;

  IF usuario_valido = 1 THEN
    SELECT u.idusuario, u.nombre, ur.p_rol_idp_rol, r.descripcion
    INTO p_id_usuario, p_nombre_usuario, p_rol_usuario, p_rol_descripcion
    FROM usuario u
    JOIN usuariorol ur ON u.idusuario = ur.usuario_idusuario
    JOIN usuarioCredenciales uc ON u.idusuario = uc.usuario_idusuario
    JOIN p_rol r ON r.idp_rol = ur.p_rol_idp_rol
    WHERE uc.username = p_usuario
      AND uc.estadoRegistro = 1
      AND ur.p_rol_idp_rol IN (1, 3, 4)
    ORDER BY ur.idusuarioRol DESC
    LIMIT 1; -- Obtiene el último registro de usuariorol para el usuario
  ELSE
    SET p_id_usuario = NULL;
    SET p_nombre_usuario = NULL;
    SET p_rol_usuario = NULL;
  END IF;

END $$

DELIMITER ;
