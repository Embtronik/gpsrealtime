
/*Este procedimiento es para Consultar por Identificación y por Placa*/
DROP PROCEDURE IF EXISTS SP_consultarClienteEditar;

DELIMITER //

CREATE PROCEDURE SP_consultarClienteEditar(
    IN p_servicio INT,
    IN p_vehiculo INT
)
BEGIN
    DECLARE resultadosEncontrados INT;

    SELECT 
        u.idusuario AS idUsuario,
        u.nombre AS Nombre,
        s.idservicio AS idServicio,
        s.fechaInicioFormulario AS FechaInicio,
        ts.idp_tipoServicio AS idtiposervicio,
        ts.descripcion AS Servicio,
        dds.id AS idDatosServicio,
        es.idp_estadoservicio AS Estado,
        IFNULL(dds.asignado,'') AS Asignado,
        IFNULL(dds.operador,'') AS Operador,
        IFNULL(dds.imei,'') AS IMEI,
        IFNULL(dds.linea,'') AS Linea,
        IFNULL(dds.renovacion,'') AS Renovacion,
        IFNULL(dds.fechaRenovacion,NOW()) AS FechaRenovacion,
        IFNULL(dds.recarga,'') AS Recarga,
        IFNULL(dds.fechaRecarga,NOW()) AS FechaRecarga,
        IFNULL(dds.instalacion,'') AS Instalacion,
        IFNULL(dds.instalador,'') AS Instalador,
        IFNULL(dds.valorInstalacion,'') AS ValorInstalacion,
        IFNULL(dds.pagoInstalacion,'') AS PagoInstalacion,
        IFNULL(dds.valorVenta,'') AS ValorVenta,
        IFNULL(dds.medotoPago,'') AS MetodoPago,
        IFNULL(dds.realizarFactura,'') AS RealizarFactura,
        IFNULL(dds.manejo,'') AS Manejo,
        IFNULL(dds.ingresoPago,'') AS IngresoPago,
        IFNULL(dds.remision,'') AS Remision,
        IFNULL(dds.facturaNumero,'') AS FacturaNumero,
        IFNULL(dds.actualizacion,'') AS Actualizacion,
        v.idvehiculo AS idVehiculo,
        v.placa AS Placa,
        v.marca AS Marca,
        v.referencia AS Referencia,
        v.modelo AS Modelo,
        v.cilindraje AS Cilindraje,
	ti.idtipoIdentificacion AS idtipoIdentificacion,
        ti.descripcion AS TipoIdentificacion,
        u.identificacion AS NumeroIdentificacion,
        u.telefono AS Telefono,
        u.email AS Email,
        u.direccion AS Direccion,
        cse.descripcion AS ComoSeEntero,
	cse.idp_comoSeEntero AS idcomoSeEntero,
        us.idusuario AS idAuxiliar,
        co.descripcion AS Comercial,
        co.idp_comercial AS idComercial,
	t.idtercero AS idTercero,
	IFNULL(t.nombreTercero,'') AS nombreTercero,
	IFNULL(t.identificacionTercero,'') AS identificacionTercero,
	IFNULL(t.emailTercero,'') AS emailTercero,
	IFNULL(t.telefonoTercero,'') AS telefonoTercero
    FROM usuario u
    LEFT JOIN serviciosparausuario spu ON u.idusuario = spu.usuario_idusuario AND spu.estadoRegistro = 1
    LEFT JOIN servicio s ON spu.servicio_idservicio = s.idservicio
    LEFT JOIN (
        SELECT idservicio, MAX(id) AS max_id
        FROM estadoServicio
        WHERE estadoRegistro = 1
        GROUP BY idservicio
    ) es_max ON s.idservicio = es_max.idservicio
    LEFT JOIN estadoServicio es ON es.id = es_max.max_id AND es.estadoRegistro = 1
    LEFT JOIN usuario us ON es.usuario_idusuario = us.idusuario AND us.estadoRegistro = 1
    LEFT JOIN p_tipoidentificacion ti ON u.tipoIdentificacion_idtipoIdentificacion = ti.idtipoIdentificacion
    LEFT JOIN (
    SELECT servicio_idservicio, MAX(id) AS max_id
    FROM datosDelServicio
    WHERE estadoRegistro = 1
    GROUP BY servicio_idservicio
	) dds_max ON s.idservicio = dds_max.servicio_idservicio
	LEFT JOIN datosDelServicio dds ON dds.id = dds_max.max_id AND dds.estadoRegistro=1
    LEFT JOIN vehiculo v ON s.vehiculo_idvehiculo = v.idvehiculo
    LEFT JOIN p_comoseentero cse ON s.p_comoSeEntero_idp_comoSeEntero = cse.idp_comoSeEntero
    LEFT JOIN p_tiposervicio ts ON s.p_tipoServicio_idp_tipoServicio = ts.idp_tipoServicio
    LEFT JOIN p_comercial co ON s.p_comercial_idp_comercial=co.idp_comercial
    LEFT JOIN vehiculoporusuario vpu ON vpu.usuario_idusuario=u.idusuario AND vpu.vehiculo_idvehiculo=v.idvehiculo AND vpu.estadoRegistro=1
    LEFT JOIN tercero t ON vpu.idvehiculoPorUsuario=t.idvehiculoPorUsuario
    WHERE
        s.idServicio = p_servicio
        AND v.idVehiculo = p_vehiculo;
        
    -- Almacenar la cantidad de resultados encontrados
    SET resultadosEncontrados = ROW_COUNT();

    -- Manejar el caso en el que no se encuentren resultados
    IF resultadosEncontrados = 0 THEN
        -- Realizar alguna acción o generar un mensaje de error
        SELECT 'No se encontraron resultados' AS mensaje;
    END IF;
END //

DELIMITER ;
