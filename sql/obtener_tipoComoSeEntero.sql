DROP PROCEDURE IF EXISTS obtener_tipoComoSeEntero;
/* Este procedimiento muestra los usuarios a los cuales les pueden asignar clientes
 y aparte sirve para hacer acordeones por cada usuario */
 
Delimiter //

CREATE PROCEDURE obtener_tipoComoSeEntero()
BEGIN
    SELECT DISTINCT
        *
    FROM
        p_comoseentero
	WHERE
		estadoRegistro=1;
END //

Delimiter ;