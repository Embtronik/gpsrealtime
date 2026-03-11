// Recuperar los datos del usuario de localStorage
const userDataString = localStorage.getItem('userData');
const userData = JSON.parse(userDataString);

if (userData) {
  // Mostrar el menú correspondiente según el rol del usuario
  switch (userData.rol_usuario) {
    case 1: // Suponiendo que el rol 1 es administrador
      document.getElementById('menu-admin').style.display = 'block';
      break;
    case 2: // Suponiendo que el rol 2 es cliente
      document.getElementById('menu-auxiliar').style.display = 'block';
      break;
    default:
      console.log('Rol desconocido');
  }
} else {
  // Redirigir a la página de inicio de sesión si no hay datos de usuario
  window.location.href = 'index.html';
}

document.getElementById('logoutAux-button').addEventListener('click', () => {
    // Borrar los datos de usuario de localStorage
    localStorage.removeItem('userData');
  
    // Redirigir al usuario a la página de inicio de sesión
    window.location.href = 'index.html';
  });

  document.getElementById('logoutAdm-button').addEventListener('click', () => {
    // Borrar los datos de usuario de localStorage
    localStorage.removeItem('userData');
  
    // Redirigir al usuario a la página de inicio de sesión
    window.location.href = 'index.html';
  });
  