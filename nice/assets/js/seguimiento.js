// Obtén los parámetros de la URL
const urlParams = new URLSearchParams(window.location.search);
const servicio = parseInt((urlParams.get('servicio') || '').trim());
const vehiculo = parseInt((urlParams.get('vehiculo') || '').trim());

if (isNaN(servicio) || isNaN(vehiculo)) {
    document.querySelector('.card-body h5.card-title').insertAdjacentHTML(
        'afterend',
        '<div class="alert alert-danger mt-2">Error: parámetros de URL inválidos. Vuelva a la lista y haga clic en Ver nuevamente.</div>'
    );
} else {
    generateTableRows(servicio, vehiculo);
}
generateComercial();
generateResultado();

async function generateTableRows(in_servicio, in_vehiculo) {
    
    try {
      const response = await fetch('../codigo/apiConsultarClienteEditar.php', {
        method: 'POST',
        body: JSON.stringify({ 
            servicio: in_servicio,
            vehiculo: in_vehiculo
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
      data.data.forEach(async row => {
        //console.log(row);
        const fechaInicio = row.FechaInicio.split(' ')[0];
        const fechaRen =row.FechaRenovacion.split(' ')[0];
        const fechaRec =row.FechaRecarga.split(' ')[0];
        
        var inputName = document.getElementById("inputName");
        var inputPlaca = document.getElementById("inputPlaca");
        var inputTelefono = document.getElementById("inputTelefono");
        var inputFechaInicio = document.getElementById("fechaInicio");
        var inputFechaFin = document.getElementById("fechaFin");
        var servicio = document.getElementById("servicio");
        var cliente = document.getElementById("cliente");
        
        inputName.value = row.Nombre;
        inputPlaca.value = row.Placa;
        inputTelefono.value = row.Telefono;
        inputFechaInicio.value = fechaInicio;
        inputFechaFin.value = fechaRen;
        cliente.value = row.idUsuario;
        servicio.value = row.idServicio; 

        generateTablaTarea();

      });
    } catch (error) {
      console.error(error);
    }
  }

  function Guardar() {
    const confirmacion = confirm('¿Guardar el Seguimiento??');
    if (confirmacion) {
        grabarTarea()
    } else {
      // El usuario hizo clic en Cancelar, no hacer nada
      return;
    }
  }

  
    function generateComercial() {
        return fetch('../codigo/apiCanalComercial.php', {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                // Obtener el elemento select del DOM
                const selectElement = document.getElementById('metodoContacto');
                
                // Limpiar las opciones anteriores
                selectElement.innerHTML = '';
    
                // Agregar la opción predeterminada
                const defaultOption = document.createElement('option');
                defaultOption.value = '';
                defaultOption.textContent = 'Seleccione ...';
                selectElement.appendChild(defaultOption);
    
                // Agregar las opciones generadas dinámicamente
                data.forEach(row => {
                    const option = document.createElement('option');
                    option.value = parseInt(row.id);
                    option.textContent = row.descripcion;
                    selectElement.appendChild(option);
                });
            })
            .catch(error => {
                console.error(error);
            });
    }
    
    function generateResultado() {
        return fetch('../codigo/apiResultados.php', {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                // Obtener el elemento select del DOM
                const selectElement = document.getElementById('resultadoSeguimiento');
                
                // Limpiar las opciones anteriores
                selectElement.innerHTML = '';
    
                // Agregar la opción predeterminada
                const defaultOption = document.createElement('option');
                defaultOption.value = '';
                defaultOption.textContent = 'Seleccione ...';
                selectElement.appendChild(defaultOption);
    
                // Agregar las opciones generadas dinámicamente
                data.forEach(row => {
                    const option = document.createElement('option');
                    option.value = parseInt(row.idp_resultado);
                    option.textContent = row.descripcion;
                    selectElement.appendChild(option);
                });
            })
            .catch(error => {
                console.error(error);
            });
    }

    async function generateTablaTarea() {
        try {
            var idCliente = parseInt(document.getElementById("cliente").value);
            var idServicio = parseInt(document.getElementById("servicio").value);
            const tableBody = document.querySelector('#tableClientes tbody');
            tableBody.innerHTML = '';

            const response = await fetch('../codigo/apiBuscarTareaPorClienteyServicio.php', {
                method: 'POST',
                body: JSON.stringify({ 
                    idCliente,
                    idServicio
                }),
                headers: {
                    'Content-Type': 'application/json'
                }
            });
    
            if (!response.ok) {
                throw new Error('Error en la respuesta del servidor');
            }
            
            const data = await response.json();
            let counter1 = 1;
            if (!data.success || !data.data || data.data.length === 0) {
                return;
            }
            data.data.forEach(row => {
                const fechaContacto = (row.fechaContacto || '').split(' ')[0];
                const fechaProximo  = (row.proximo || '').split(' ')[0];
                const newRow = document.createElement('tr');
                newRow.innerHTML = `
                    <th scope="row">${counter1}</th>
                    <td style="display: none">${row.idTarea}</td>
                    <td>${fechaContacto}</td>
                    <td>${row.funcionario}</td>
                    <td>${row.metodoContacto}</td>
                    <td>${row.descripcion}</td>
                    <td>${row.resultado}</td>
                    <td>${fechaProximo}</td>
                    <td>
                        <div class="btn-group" role="group" aria-label="Basic example">
                            <button type="button" class="btn btn-success" onclick="Eliminar(this)">Eliminar</button>
                        </div>
                    </td>`;
                
                tableBody.appendChild(newRow);
                counter1++;
            });
        } catch (error) {
            console.error(error);
        }
    }
    
    async function grabarTarea() {
        var descripcionGestion = document.getElementById("descripcion").value;
        var fechaSiguienteTarea = document.getElementById("proximoContacto").value;
        var cliente_idusuario = parseInt(document.getElementById("cliente").value);
        var funcionario_idusuario = userData.id_usuario;
        var p_canalComercial_id = parseInt(document.getElementById("metodoContacto").value);
        var servicio_idservicio = parseInt(document.getElementById("servicio").value);
        var resultado = parseInt(document.getElementById("resultadoSeguimiento").value);
    
        var fechaActual = new Date();
        var fechaSeguimiento = fechaActual.toISOString().split('T')[0];
    
        // Validar que p_canalComercial_id y resultado sean obligatorios y números
        if (isNaN(p_canalComercial_id) || isNaN(resultado)) {
            alert('Los campos "Canal Comercial" y "Resultado" son obligatorios y deben ser números.');
            return;
        }
    
        // Asignar null a fechaSiguienteTarea si está vacía
        if (fechaSiguienteTarea === '') {
            fechaSiguienteTarea = null;
        }
    
        const dataToSend = {
            descripcionGestion: descripcionGestion,
            fechaSiguienteTarea: fechaSiguienteTarea,
            cliente_idusuario: cliente_idusuario,
            funcionario_idusuario: funcionario_idusuario,
            p_canalComercial_id: p_canalComercial_id,
            servicio_idservicio: servicio_idservicio,
            resultado: resultado,
            fechaSeguimiento: fechaSeguimiento
        };
    
        try {
            const response = await fetch('../codigo/apiInsertarTarea.php', {
                method: 'POST',
                body: JSON.stringify(dataToSend),
                headers: {
                    'Content-Type': 'application/json'
                }
            });
    
            if (!response.ok) {
                throw new Error('Error en la respuesta del servidor');
            }
    
            const data = await response.json();
            console.log(data);
            if (data.success) {
                generateTablaTarea();
            }
        } catch (error) {
            console.error(error);
        }
    }
    
    
     
    async function Eliminar(button) {
        const row = button.closest('tr');
    
        const confirmacion = confirm('¿Desea Eliminar la Tarea??');
        if (confirmacion) {        
            const dataToSend = {
                idtareaCliente: row.cells[1].innerText            
            }
            
            try {
                const response = await fetch('../codigo/apiEliminarTareaCliente.php', {
                    method: 'POST',
                    body: JSON.stringify(dataToSend),
                    headers: {
                        'Content-Type': 'application/json'
                    }
                });
    
                if (!response.ok) {
                    throw new Error('Error en la respuesta del servidor');
                }
    
                const data = await response.json();
                if (data.success) {
                    generateTablaTarea();
                }
            } catch (error) {
                console.error(error);
            }
        } else {
            // El usuario hizo clic en Cancelar, no hacer nada
            return;
        }
    }
    
    