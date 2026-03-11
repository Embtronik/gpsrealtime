DROP PROCEDURE IF EXISTS obtener_tipoComercial;
/* Este procedimiento muestra los usuarios a los cuales les pueden asignar clientes
 y aparte sirve para hacer acordeones por cada usuario */
 
Delimiter //

CREATE PROCEDURE obtener_tipoComercial()
BEGIN
    SELECT DISTINCT
        *
    FROM
        p_comercial
	WHERE
		estadoRegistro=1;
END //

Delimiter ;