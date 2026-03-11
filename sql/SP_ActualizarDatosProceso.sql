DROP PROCEDURE IF EXISTS SP_ActualizarDatosProceso;
DELIMITER //

CREATE PROCEDURE SP_ActualizarDatosProceso(
    IN p_idUsuario INT,
    IN p_nombre VARCHAR(255),
    IN p_idServicio INT,
    IN p_fechaInicio DATETIME,
    IN p_tipoServicio INT,
    IN p_idDatosServicio INT,
    IN p_estadoServicio INT,
    IN p_operador VARCHAR(45),
    IN p_IMEI VARCHAR(45),
    IN p_linea VARCHAR(45),
    IN p_renovacion VARCHAR(45),
    IN p_fechaRenovacion DATETIME,
    IN p_recarga VARCHAR(45),
    IN p_fechaRecarga DATETIME,
    IN p_instalacion VARCHAR(45),
    IN p_instalador VARCHAR(100),
    IN p_valorInstalacion VARCHAR(45),
    IN p_pagoInstalacion VARCHAR(45),
    IN p_valorVenta VARCHAR(45),
    IN p_metodoPago VARCHAR(45),
    IN p_realizarFactura VARCHAR(45),
    IN p_manejo VARCHAR(45),
    IN p_ingresoPago VARCHAR(45),
    IN p_remision VARCHAR(45),
    IN p_facturaNumero VARCHAR(45),
    IN p_actualizacion VARCHAR(100),
    IN p_idVehiculo INT,
    IN p_placa VARCHAR(45),
    IN p_marca VARCHAR(45),
    IN p_referencia VARCHAR(45),
    IN p_modelo VARCHAR(45),
    IN p_cilindraje VARCHAR(45),
    IN p_tipoIdentificacion VARCHAR(45),
    IN p_numeroIdentificacion VARCHAR(45),
    IN p_telefono VARCHAR(45),
    IN p_email VARCHAR(255),
    IN p_direccion VARCHAR(255),
    IN p_comercial INT,
    IN p_comoSeEntero INT,
    IN p_idAuxiliar INT,
    IN p_idTercero INT,
    IN p_nombreTercero VARCHAR(255),    
    IN p_identificacionTercero VARCHAR(45),
    IN p_emailTercero VARCHAR(45),
    IN p_telefonoTercero VARCHAR(45)
)
BEGIN

	call insertar_actualizar_datosDelServicio(
    p_idDatosServicio, 
    p_fechaInicio, 
    p_idAuxiliar, 
    p_estadoServicio, 
    p_operador,
    p_IMEI,
    p_linea,
    p_renovacion,
    p_fechaRenovacion, 
    p_recarga,
    p_fechaRecarga, 
    p_instalacion, 
    p_instalador, 
    p_valorInstalacion, 
    p_pagoInstalacion,
    p_valorVenta, 
    p_metodoPago, 
    p_realizarFactura, 
    p_manejo,
    p_ingresoPago, 
    p_remision, 
    p_facturaNumero, 
    p_actualizacion, 
    p_idServicio);
    

    call sp_ActualizarServicio(
        p_idServicio,
        p_fechaInicio,
        (select otro from servicio where idservicio=p_idServicio),
        (select tratamiento from servicio where idservicio=p_idServicio),
        p_comercial,
        (select p_metodoPago_idp_metodoPago from servicio where idservicio=p_idServicio),
        p_comoSeEntero,
        p_tipoServicio,
        (select recomendacion from servicio where idservicio=p_idServicio),
        p_idVehiculo
    );
    
    call sp_ActualizarVehiculo(
    p_idVehiculo, p_placa, p_marca, p_referencia, p_modelo, p_cilindraje
    );
    
    call sp_ActualizarUsuario(
     p_idUsuario, p_nombre, p_email, p_numeroIdentificacion, p_direccion, p_telefono,
     p_tipoIdentificacion   
    );
    
    call sp_ActualizarTercero(
    p_idTercero, p_nombreTercero, p_identificacionTercero,
    p_emailTercero, p_telefonoTercero, (
    select
	vpu.idvehiculoPorUsuario
	from vehiculoporusuario vpu
	inner join usuario u on vpu.usuario_idusuario=u.idusuario
	inner join vehiculo v on vpu.vehiculo_idvehiculo=v.idvehiculo
	WHERE
	vpu.estadoRegistro=1 and
	vpu.vehiculo_idvehiculo=p_idVehiculo and
	vpu.usuario_idusuario=p_idUsuario),
    p_idVehiculo,
    p_idUsuario
    );   
END //

DELIMITER ;
