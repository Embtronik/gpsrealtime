// Recuperar los datos del usuario de localStorage
const userDataString = localStorage.getItem('userData');
const userData = JSON.parse(userDataString);

if (userData) {
  document.getElementById('perfil').textContent = userData.nombre_usuario;
  document.getElementById('user-name').textContent = userData.nombre_usuario;
  document.getElementById('rol').textContent = userData.p_rol_descripcion;
  /*
  // Mostrar el menú correspondiente según el rol del usuario
  switch (userData.rol_usuario) {
    case 1:
      break;
    case 3: // Suponiendo que el rol 2 es cliente
      window.location.href = 'auxiliar.html';
      break;
    default:
      window.location.href = '../index.html';
      break;
  }*/
} else {
  // Redirigir a la página de inicio de sesión si no hay datos de usuario
  window.location.href = '../index.html';
}

 
  document.getElementById('sign-out-button').addEventListener('click', () => {
    // Borrar los datos de usuario de localStorage
    localStorage.removeItem('userData');

    // Redirigir al usuario a la página de inicio de sesión
    window.location.href = '../index.html';
  });