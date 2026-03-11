DROP PROCEDURE IF EXISTS obtener_estadoServicio;
/* Este procedimiento muestra los usuarios a los cuales les pueden asignar clientes
 y aparte sirve para hacer acordeones por cada usuario */
 
Delimiter //

CREATE PROCEDURE obtener_estadoServicio()
BEGIN
    SELECT DISTINCT
        *
    FROM
        p_estadoServicio
	WHERE
		estadoRegistro=1;
END //

Delimiter ;