const dataToSend = {
  action: 'get_data',
};

fetch('../codigo/apitablecomercial.php', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify(dataToSend),
})
  .then((response) => response.json())
  .then((data) => {
    console.log('Success:', data);
    llenarTabla(data);
  })
  .catch((error) => {
    console.error('Error:', error);
  });

  function llenarTabla(data) {
    const tabla = document.getElementById('tabla-dinamica');
    const tbody = tabla.querySelector('tbody');
    
    data.forEach((row) => {
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>${row.idp_comercial}</td>
        <td>${row.descripcion}</td>
        <td>
          ${row.estadoRegistro === "1" ? 'Activo' : 'Inactivo'}
        </td>
        <td>
            <div class="btn-group" role="group" aria-label="Basic example">
              <button type="button" class="btn btn-primary" onclick="eliminarFila(this)">Eliminar</button>
            </div>          
        </td>
      `;
      tbody.appendChild(tr);
    });
  }
  
  function eliminarFila(button) {
    const row = button.closest('tr');
    const confirmacion = confirm('¿Está seguro de eliminar este elemento?');
    if (confirmacion) {
    
    row.remove();
    //console.log(row.cells[0].innerText);
    const dataToSend = {
      idp_comercial: row.cells[0].innerText
    };
    
    fetch('../codigo/apiEliminarComercial.php', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(dataToSend),
    })
      .then((response) => response.json())
      .then((data) => {
        console.log('Success:', data);
        location.reload();
      })
      .catch((error) => {
        console.error('Error:', error);
      });
    } else {
      // El usuario hizo clic en Cancelar, no hacer nada
      return;
    }
  }
  
  function agregarFila() {
    const tabla = document.getElementById('tabla-dinamica');
    const tbody = tabla.querySelector('tbody');
    const nameComercial = document.getElementById('name-comercial').value;
    
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td></td>
      <td>${nameComercial}</td>
      <td>Pendiente</td>
      <td>
            <div class="btn-group" role="group" aria-label="Basic example">
              <button type="button" class="btn btn-primary" onclick="eliminarFila(this)">Eliminar</button>
            </div>          
        </td>
    `;    
    tbody.appendChild(tr);
    document.getElementById('name-comercial').value = '';
  }

  function aceptar() { 
 
      const tabla = document.getElementById('tabla-dinamica');
      const filas = tabla.querySelectorAll('tbody tr');
  
      filas.forEach((fila, indice) => {
        const celda = fila.cells[2];
  
        if (celda) { // Verificar si la celda es válida antes de acceder a su contenido
          const valor = celda.innerText;
  
          if (valor === 'Pendiente') {
            // Realizar acción si el valor es 'Pendiente'
            //console.log(`La fila ${indice} tiene estado 'Pendiente'`);

            const dataToSend = {
              descripcion: fila.cells[1].innerText
            };
            
            fetch('../codigo/apiInsertarComercial.php', {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
              },
              body: JSON.stringify(dataToSend),
            })
              .then((response) => response.json())
              .then((data) => {
                console.log('Success:', data);
                location.reload();
              })
              .catch((error) => {
                console.error('Error:', error);
              });
          }
        }
      });
  }
  