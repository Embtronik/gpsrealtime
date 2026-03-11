DROP PROCEDURE IF EXISTS obtener_usuarios_empresa;
/* Este procedimiento muestra los usuarios a los cuales les pueden asignar clientes
 y aparte sirve para hacer acordeones por cada usuario */
 
Delimiter //

CREATE PROCEDURE obtener_usuarios_empresa()
BEGIN
    SELECT DISTINCT
        u.idusuario,
        uc.username,
        ur.p_rol_idp_rol
    /*--,ur.estadoRegistro*/
    /*,ur.idusuarioRol*/
    FROM
        usuario u
        INNER JOIN usuariorol ur ON u.idusuario = ur.usuario_idusuario AND ur.estadoRegistro = 1
        INNER JOIN usuariocredenciales uc ON u.idusuario = uc.usuario_idusuario AND uc.estadoRegistro = 1
    WHERE
        ur.p_rol_idp_rol IN (1, 3);
END //

Delimiter ;