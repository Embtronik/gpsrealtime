const form = document.getElementById('formulario');
const btnEnviar = document.getElementById('enviar');

// Muestra un mensaje de error visible en pantalla (no console.error)
function mostrarError(msg) {
  let banner = document.getElementById('form-error-banner');
  if (!banner) {
    banner = document.createElement('div');
    banner.id = 'form-error-banner';
    banner.style.cssText = [
      'background:#c0392b','color:#fff','border-radius:8px',
      'padding:14px 18px','margin:16px 0','font-size:0.95rem',
      'line-height:1.5','text-align:center'
    ].join(';');
    form.insertAdjacentElement('beforebegin', banner);
  }
  banner.textContent = msg;
  banner.style.display = 'block';
  banner.scrollIntoView({ behavior: 'smooth', block: 'center' });
}

function ocultarError() {
  const banner = document.getElementById('form-error-banner');
  if (banner) banner.style.display = 'none';
}

// Estado del botón durante el envío
function setLoading(loading) {
  if (loading) {
    btnEnviar.disabled = true;
    btnEnviar.dataset.originalText = btnEnviar.innerHTML;
    btnEnviar.innerHTML = '<span style="display:inline-block;width:16px;height:16px;border:2px solid #fff;border-top-color:transparent;border-radius:50%;animation:spin 0.7s linear infinite;vertical-align:middle;margin-right:8px"></span>Enviando...';
    if (!document.getElementById('spin-style')) {
      const s = document.createElement('style');
      s.id = 'spin-style';
      s.textContent = '@keyframes spin{to{transform:rotate(360deg)}}';
      document.head.appendChild(s);
    }
  } else {
    btnEnviar.disabled = false;
    if (btnEnviar.dataset.originalText) {
      btnEnviar.innerHTML = btnEnviar.dataset.originalText;
    }
  }
}

form.addEventListener('submit', async (event) => {
  event.preventDefault();
  ocultarError();

  const payload = {
    fecha:              document.getElementById('fecha').value,
    servicio:           document.getElementById('servicio').value,
    tipoIdentificacion: document.getElementById('tipo_identificacion').value,
    identificacion:     document.getElementById('identificacion').value,
    nombre:             document.getElementById('nombre').value,
    telefono:           document.getElementById('prefijo').value + ' ' + document.getElementById('telefono').value,
    direccion:          document.getElementById('direccion').value,
    email:              document.getElementById('email').value,
    marcaVehiculo:      document.getElementById('marcaVehiculo').value,
    referenciaVehiculo: document.getElementById('referenciaVehiculo').value,
    modeloVehiculo:     document.getElementById('modeloVehiculo').value,
    cilindrajeVehiculo: document.getElementById('cilindrajeVehiculo').value,
    placa:              document.getElementById('placa').value,
    comercial:          document.getElementById('comercial').value,
    metodoPago:         document.getElementById('metodoPago').value,
    comoSeEntero:       document.getElementById('comoSeEntero').value,
    tratamiento:        document.getElementById('tratamiento').checked,
    recomendaciones:    document.getElementById('recomendaciones').checked,
  };

  setLoading(true);
  try {
    const response = await fetch('./codigo/apidatos.php', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      throw new Error('Error del servidor (' + response.status + '). Intenta de nuevo.');
    }

    const data = await response.json();

    if (data.success) {
      window.location.href = 'exitregister.html';
    } else {
      setLoading(false);
      mostrarError(data.message || 'No se pudo enviar el formulario. Por favor intenta de nuevo.');
    }
  } catch (err) {
    setLoading(false);
    mostrarError('No se pudo enviar el formulario. Verifica tu conexión e intenta de nuevo.');
  }
});
