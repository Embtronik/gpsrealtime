// Obtén los parámetros de la URL
const urlParams = new URLSearchParams(window.location.search);
const placa = urlParams.get('placa');
const identificacion = urlParams.get('identificacion');

generateTableRows(placa,identificacion);

async function generateTableRows(in_placa, in_identificacion) {
    const table = document.getElementsByClassName('datatable-table')[0];
    

    //const table = document.querySelector('.table.datatable');
    const tableBody = table.querySelector('tbody');
    tableBody.innerHTML = '';

    try {
      const response = await fetch('../codigo/apiConsultarClienteEditar.php', {
        method: 'POST',
        body: JSON.stringify({ 
            placa: in_placa,
            identificacion: in_identificacion
         }),
        headers: {
          'Content-Type': 'application/json'
        }
      });
      if (!response.ok) {
        throw new Error('Error en la respuesta del servidor');
      }
      const data = await response.json();
      //console.log(data);
      //const selectStade = await generateStade();
      //const selectService = await generateServicio(data.data.idservicio);
      data.data.forEach(async row => {
        //console.log(row);
        const selectService = await generateServicio(row.idtiposervicio);
        const selectStade = await generateStade(row.Estado);
        const selectTipoIdent = await generateTipoIdentificacion(row.idtipoIdentificacion);
        const selectComercial = await generateComercial(row.idComercial);
        const selectComoSeEntero = await generateComoSeEntero(row.idcomoSeEntero);

        const fechaInicio = row.FechaInicio.split(' ')[0];
        const fechaRen =row.FechaRenovacion.split(' ')[0];
        const fechaRec =row.FechaRecarga.split(' ')[0];
        
        const newRow = document.createElement('tr');
        newRow.innerHTML = `
          <tr>
            <th style="display: none" scope="row">1</th>
            <td style="display: none">${row.idUsuario}</td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.Nombre}">
                </div>
            </td>            
            <td style="display: none">${row.idServicio}</td>
            <td>
                <div class="col-sm-10">
                    <input type="date" class="form-control" value="${fechaInicio}">
                </div>
            </td>
            <td>
                <div class="input-group">
                        ${selectService}
                </div>
            </td>
            <td style="display: none">${row.idDatosServicio}</td>            
            <td>
                <div class="input-group">
                        ${selectStade}
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.Operador}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" placeholder="IMEI" value="${row.IMEI}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" placeholder="Linea" value="${row.Linea}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.Renovacion}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="date" class="form-control" value ="${fechaRen}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.Recarga}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="date" class="form-control" value ="${fechaRec}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.Instalacion}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.Instalador}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.ValorInstalacion}">
                </div>
            </td>
            <td>                
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.PagoInstalacion}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value=" ${row.ValorVenta}">
                </div>           
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.MetodoPago}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.RealizarFactura}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.Manejo}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.IngresoPago}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.Remision}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.FacturaNumero}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.Actualizacion}">
                </div>
            </td>
            <td style="display: none">${row.idVehiculo}</td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.Placa}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.Marca}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.Referencia}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.Modelo}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.Cilindraje}">
                </div>
            </td>
            <td>${selectTipoIdent}</td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.NumeroIdentificacion}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.Telefono}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.Email}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.Direccion}">
                </div>
            </td>
            <td>${selectComercial}</td>
            <td>${selectComoSeEntero}</td>
            <td style="display: none">${row.idAuxiliar}</td>
            <td style="display: none">${row.idTercero}</td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.nombreTercero}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.identificacionTercero}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.emailTercero}">
                </div>
            </td>
            <td>
                <div class="col-sm-10">
                    <input type="text" class="form-control" value="${row.telefonoTercero}">
                </div>
            </td>           
            <td>
            <div class="btn-group" role="group" aria-label="Basic example">
              <button type="button" class="btn btn-primary" onclick="Guardar(this)">Guardar</button>
            </div>          
        </td>
          </tr>`;
          tableBody.appendChild(newRow);
      });
    } catch (error) {
      console.error(error);
    }
  }

  function Guardar(button) {
    const row = button.closest('tr');

    const confirmacion = confirm('¿Guardar el cambio??');
    if (confirmacion) {
    
    //console.log(row.cells[0].innerText);
    const dataToSend = {
        idUsuario: parseInt(row.cells[1].innerText),
        nombre: row.cells[2].querySelector('input').value,
        idServicio:  parseInt(row.cells[3].innerText),
        fechaInicio: row.cells[4].querySelector('input').value,
        tipoServicio: row.cells[5].querySelector('select').value,
        idDatosServicio:  parseInt(row.cells[6].innerText),
        estadoServicio: row.cells[7].querySelector('select').value,
        operador: row.cells[8].querySelector('input').value,
        IMEI: row.cells[9].querySelector('input').value,
        linea: row.cells[10].querySelector('input').value,
        renovacion: row.cells[11].querySelector('input').value,
        fechaRenovacion: row.cells[12].querySelector('input').value,
        recarga: row.cells[13].querySelector('input').value,
        fechaRecarga: row.cells[14].querySelector('input').value,
        instalacion: row.cells[15].querySelector('input').value,
        instalador: row.cells[16].querySelector('input').value,
        valorInstalacion: row.cells[17].querySelector('input').value,
        pagoInstalacion: row.cells[18].querySelector('input').value,
        valorVenta: row.cells[19].querySelector('input').value,
        metodoPago: row.cells[20].querySelector('input').value,
        realizarFactura: row.cells[21].querySelector('input').value,
        manejo: row.cells[22].querySelector('input').value,
        ingresoPago: row.cells[23].querySelector('input').value,
        remision: row.cells[24].querySelector('input').value,
        facturaNumero: row.cells[25].querySelector('input').value,
        actualizacion: row.cells[26].querySelector('input').value,
        idVehiculo: parseInt(row.cells[27].innerText),
        placa: row.cells[28].querySelector('input').value,
        marca: row.cells[29].querySelector('input').value,
        referencia: row.cells[30].querySelector('input').value,
        modelo: row.cells[31].querySelector('input').value,
        cilindraje: row.cells[32].querySelector('input').value,
        tipoIdentificacion: row.cells[33].querySelector('select').value,
        numeroIdentificacion: row.cells[34].querySelector('input').value,
        telefono: row.cells[35].querySelector('input').value,
        email: row.cells[36].querySelector('input').value,
        direccion: row.cells[37].querySelector('input').value,
        comercial: parseInt(row.cells[38].querySelector('select').value),
        comoSeEntero: parseInt(row.cells[39].querySelector('select').value),
        idAuxiliar: parseInt(row.cells[40].innerText),
        idTercero: parseInt(row.cells[41].innerText),
        nombreTercero: row.cells[42].querySelector('input').value,
        identificacionTercero: row.cells[43].querySelector('input').value,
        emailTercero: row.cells[44].querySelector('input').value,
        telefonoTercero: row.cells[45].querySelector('input').value
    };

    console.log(dataToSend);
    
    fetch('../codigo/apiActualizarDatosProceso.php', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(dataToSend),
    })
    .then((response) => {
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        console.log(response.json);
        return response.json();
      })
      .then((data) => {
        console.log('Success:', data);
        location.reload(); //cambiar de página
      })
      .catch((error) => {
        console.error('Error:', error);
      });
    } else {
      // El usuario hizo clic en Cancelar, no hacer nada
      return;
    }
  }

  
  function generateStade(defaultValue) {
    return fetch('../codigo/apiEstadoServicio.php', {
        method: 'POST'
      })
      .then(response => response.json())
      .then(data => {
        let optionsHTML = '';
        // Genera las opciones dinámicamente utilizando los datos obtenidos
        data.forEach(row => {
          const option = document.createElement('option');
          option.value = parseInt(row.idp_estadoServicio);
          option.textContent = row.descripcion;
          
          // Compara con el valor por defecto y establece 'selected' si coincide
          if (parseInt(row.idp_estadoServicio) === parseInt(defaultValue)) {
            option.setAttribute('selected', 'selected');
          }else {
            option.removeAttribute('selected'); // Elimina la selección si no coincide
          }
          // Agrega la opción al código HTML
          optionsHTML += option.outerHTML;
        });

        // Crea un elemento select
        const selectElement = document.createElement('select');
        selectElement.classList.add('form-select');
        selectElement.setAttribute('aria-label', 'auxiliar');
        selectElement.style.width = '150px';
                        
        // Agrega las opciones generadas al elemento select
        selectElement.innerHTML = optionsHTML;
                
                        
        return selectElement.outerHTML;
      })
      .catch(error => {
        console.error(error);
      });
    }
    
    function generateServicio(defaultValue) {
            return fetch('../codigo/apiservicios.php', {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                let optionsHTML = '';
                // Genera las opciones dinámicamente utilizando los datos obtenidos
                data.forEach(row => {
                    const option = document.createElement('option');
                    option.value = parseInt(row.idp_tipoServicio);
                    option.textContent = row.descripcion;
                    
                    // Compara con el valor por defecto y establece 'selected' si coincide
                    if (parseInt(row.idp_tipoServicio) === parseInt(defaultValue)) {
                        option.setAttribute('selected', 'selected');
                        //option.selected = 'selected';
                    }else {
                        option.removeAttribute('selected'); // Elimina la selección si no coincide
                    }
                    // Agrega la opción al código HTML
                    optionsHTML += option.outerHTML;
                });
                
                // Crea un elemento select
                const selectElement = document.createElement('select');
                selectElement.classList.add('form-select');
                selectElement.setAttribute('aria-label', 'auxiliar');
                selectElement.style.width = '150px';
                
                // Agrega las opciones generadas al elemento select
                selectElement.innerHTML = optionsHTML;
        
                
                return selectElement.outerHTML;
            })
            .catch(error => {
                console.error(error);
        });
    }
     
    function generateTipoIdentificacion(defaultValue) {
        return fetch('../codigo/apitipoident.php', {
            method: 'POST'
        })
        .then(response => response.json())
        .then(data => {
            let optionsHTML = '';
            // Genera las opciones dinámicamente utilizando los datos obtenidos
            data.forEach(row => {
                const option = document.createElement('option');
                option.value = parseInt(row.idtipoIdentificacion);
                option.textContent = row.descripcion;
                
                // Compara con el valor por defecto y establece 'selected' si coincide
                if (parseInt(row.idtipoIdentificacion) === parseInt(defaultValue)) {
                    option.setAttribute('selected', 'selected');
                    //option.selected = 'selected';
                }else {
                    option.removeAttribute('selected'); // Elimina la selección si no coincide
                }
                // Agrega la opción al código HTML
                optionsHTML += option.outerHTML;
            });
            
            // Crea un elemento select
            const selectElement = document.createElement('select');
            selectElement.classList.add('form-select');
            selectElement.setAttribute('aria-label', 'auxiliar');
            selectElement.style.width = '150px';
            
            // Agrega las opciones generadas al elemento select
            selectElement.innerHTML = optionsHTML;
    
            
            return selectElement.outerHTML;
        })
        .catch(error => {
            console.error(error);
    });
    }

    function generateComercial(defaultValue) {
        return fetch('../codigo/apitipocomercial.php', {
            method: 'POST'
        })
        .then(response => response.json())
        .then(data => {
            let optionsHTML = '';
            // Genera las opciones dinámicamente utilizando los datos obtenidos
            data.forEach(row => {
                const option = document.createElement('option');
                option.value = parseInt(row.idp_comercial);
                option.textContent = row.descripcion;
                
                // Compara con el valor por defecto y establece 'selected' si coincide
                if (parseInt(row.idp_comercial) === parseInt(defaultValue)) {
                    option.setAttribute('selected', 'selected');
                    //option.selected = 'selected';
                }else {
                    option.removeAttribute('selected'); // Elimina la selección si no coincide
                }
                // Agrega la opción al código HTML
                optionsHTML += option.outerHTML;
            });
            
            // Crea un elemento select
            const selectElement = document.createElement('select');
            selectElement.classList.add('form-select');
            selectElement.setAttribute('aria-label', 'auxiliar');
            selectElement.style.width = '150px';
            
            // Agrega las opciones generadas al elemento select
            selectElement.innerHTML = optionsHTML;
    
            
            return selectElement.outerHTML;
        })
        .catch(error => {
            console.error(error);
    });
    }

    function generateComoSeEntero(defaultValue) {
        return fetch('../codigo/apitipocomoseentero.php', {
            method: 'POST'
        })
        .then(response => response.json())
        .then(data => {
            let optionsHTML = '';
            // Genera las opciones dinámicamente utilizando los datos obtenidos
            data.forEach(row => {
                const option = document.createElement('option');
                option.value = parseInt(row.idp_comoSeEntero);
                option.textContent = row.descripcion;
                
                // Compara con el valor por defecto y establece 'selected' si coincide
                if (parseInt(row.idp_comoSeEntero) === parseInt(defaultValue)) {
                    option.setAttribute('selected', 'selected');
                    //option.selected = 'selected';
                }else {
                    option.removeAttribute('selected'); // Elimina la selección si no coincide
                }
                // Agrega la opción al código HTML
                optionsHTML += option.outerHTML;
            });
            
            // Crea un elemento select
            const selectElement = document.createElement('select');
            selectElement.classList.add('form-select');
            selectElement.setAttribute('aria-label', 'auxiliar');
            selectElement.style.width = '150px';
            
            // Agrega las opciones generadas al elemento select
            selectElement.innerHTML = optionsHTML;
    
            
            return selectElement.outerHTML;
        })
        .catch(error => {
            console.error(error);
    });
    }