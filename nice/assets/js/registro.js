fetch('../codigo/apitipoidentificacion.php')
.then(response => response.json())
.then(data => {
  const select = document.getElementById('tipoIdentificacion');
  for (let id in data) {
    const option = document.createElement('option');
      option.value = id;
      option.text = data[id];
      select.add(option);
  }
});

fetch('../codigo/apirol.php')
.then(response => response.json())
.then(data => {
  const select = document.getElementById('tipo-rol');
  for (let id in data) {
    const option = document.createElement('option');
      option.value = id;
      option.text = data[id];
      select.add(option);
  }
});

function Registrar(event) {
    event.preventDefault();
    // Obtener los valores de los campos del formulario
    const name = document.getElementById('name').value;
    const email = document.getElementById('email').value;
    const tipoIdentificacion = document.getElementById('tipoIdentificacion').value;
    const identificacion = document.getElementById('identificacion').value;
    const direccion = document.getElementById('direccion').value;
    const telefono = document.getElementById('telefono').value;
    const username = document.getElementById('yourUsername').value;
    const password = document.getElementById('password').value;
    const rol = document.getElementById('tipo-rol').value;
  
    // Validar los campos del formulario
    if (name === '') {
      alert('Ingrese el nombre!');
      return;
    }
    if (email === '') {
      alert('Ingrese un email válido!');
      return;
    }
    if (tipoIdentificacion === '') {
      alert('Ingrese un tipo de identificación!');
      return;
    }
    if (identificacion === '') {
      alert('Ingrese una identificación!');
      return;
    }
    if (direccion === '') {
      alert('Ingrese una dirección!');
      return;
    }
    if (telefono === '') {
      alert('Ingrese un número de teléfono!');
      return;
    }
    if (username === '') {
      alert('Ingrese un nombre de usuario!');
      return;
    }
    if (password === '') {
      alert('Ingrese una contraseña!');
      return;
    }
    if (rol === '') {
        alert('Ingrese un Rol!');
        return;
      }
  
    // Crear un objeto con los datos del formulario
    const data = {
      name,
      email,
      tipoIdentificacion,
      identificacion,
      direccion,
      telefono,
      username,
      password,
      rol
    };
  
    // Enviar los datos a PHP mediante fetch()
    fetch('../codigo/apiregistraruser.php', {        
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    })
    .then(response => response.json())
    .then(data => {
      console.log('Success:', data);
      // Hacer algo con la respuesta, por ejemplo, mostrar un mensaje al usuario
      alert('Usuario creado con éxito!');
      document.getElementById('formulario').reset();
    })
    .catch(error => {
      console.error('Error:', error);
      // Mostrar un mensaje de error al usuario
      alert('Ocurrió un error al crear el usuario.');
    });
  }
  