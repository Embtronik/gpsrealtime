const form = document.getElementById('formulario');
form.addEventListener('submit', (event) => {
  // Prevenir que se recargue la página al enviar el formulario
  event.preventDefault();

  // Obtener los valores del formulario
  const fecha = document.getElementById('fecha').value;
  const servicio =document.getElementById('servicio').value;
  const tipoIdentificacion = document.getElementById('tipo_identificacion').value;
  const identificacion = document.getElementById('identificacion').value;
  const nombre = document.getElementById('nombre').value;
  const telefono = document.getElementById('prefijo').value + " " + document.getElementById('telefono').value;
  const direccion = document.getElementById('direccion').value;
  const email = document.getElementById('email').value;
  const marcaVehiculo = document.getElementById('marcaVehiculo').value;
  const referenciaVehiculo = document.getElementById('referenciaVehiculo').value;
  const modeloVehiculo = document.getElementById('modeloVehiculo').value;
  const cilindrajeVehiculo = document.getElementById('cilindrajeVehiculo').value;
  const placa = document.getElementById('placa').value;
  const comercial = document.getElementById('comercial').value;
  const metodoPago = document.getElementById('metodoPago').value;
  const comoSeEntero = document.getElementById('comoSeEntero').value;
  const tratamiento = document.getElementById('tratamiento').checked;
  const recomendaciones = document.getElementById('recomendaciones').checked;

  // Enviar los datos a la API
  fetch('./codigo/apidatos.php', {
    method: 'POST',
    body: JSON.stringify({ 
        fecha,
        servicio,
        tipoIdentificacion,
        identificacion,
        nombre,
        telefono,
        direccion,
        email,
        marcaVehiculo,
        referenciaVehiculo,
        modeloVehiculo,
        cilindrajeVehiculo,
        placa,
        comercial,
        metodoPago,
        comoSeEntero,
        tratamiento,
        recomendaciones }),
    headers: {
      'Content-Type': 'application/json'
    }
  })
  .then(response => response.json())
  .then(data => {console.log(data)
      if (data.success) {
        window.location.href = 'exitregister.html';
          }})
  .catch(error => console.error(error));
});
