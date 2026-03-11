const form = document.getElementById('loginform');

form.addEventListener('submit', (event) => {
  event.preventDefault();

  const usuario = document.getElementById('login_user').value.trim();
  const password = document.getElementById('login_password').value.trim();

  // Validación rápida (igual a la tuya)
  const usuarioRegex = /^[a-zA-Z0-9_]+$/;
  const passwordRegex = /^[a-zA-Z0-9!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]+$/;

  if (!usuarioRegex.test(usuario)) {
    alert('Usuario no válido. Solo alfanuméricos y _');
    return;
  }
  if (!passwordRegex.test(password)) {
    alert('Contraseña no válida.');
    return;
  }

  fetch('./codigo/apicredenciales.php', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include', // ← importante para que PHP devuelva/guarde la cookie de sesión
    body: JSON.stringify({ usuario, password })
  })
  .then((response) => {
    if (!response.ok) throw new Error('Error de red');
    return response.json();
  })
  .then((data) => {
    if (!data.success) {
      alert(data.message || 'Credenciales incorrectas');
      return;
    }

    // Guarda lo que necesites en localStorage (opcional)
    localStorage.setItem('userData', JSON.stringify(data));

    // Redirección por rol (según respuesta del backend)
    switch (Number(data.rol_usuario)) {
      case 1:
        window.location.href = './nice/index.html';
        break;
      case 5:
        window.location.href = './nice/supervisor.html';
        break;
      case 3:
        window.location.href = './nice/auxiliar.html';
        break;
      case 4:
        window.location.href = './inspeccion.php';
        break;
      default:
        window.location.href = 'index.html';
        break;
    }
  })
  .catch((err) => {
    console.error(err);
    alert('No fue posible iniciar sesión.');
  });
});
