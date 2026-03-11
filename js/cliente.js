document.addEventListener("DOMContentLoaded", () => {
  const $ = (s) => document.querySelector(s);

  // ----- Habilitar submit cuando ambos checks estén marcados
  const chkTrat = $('#tratamiento');
  const chkTerm = $('#recomendaciones');
  const btnEnviar = $('#enviar');

  const toggleSubmit = () => {
    btnEnviar.disabled = !(chkTrat?.checked && chkTerm?.checked);
  };
  chkTrat?.addEventListener('change', toggleSubmit);
  chkTerm?.addEventListener('change', toggleSubmit);
  toggleSubmit();

  // ----- Fecha por defecto: hoy
  const fecha = $('#fecha');
  if (fecha && !fecha.value) fecha.valueAsDate = new Date();

  // ----- Cargar selects (DRY)
  const endpoints = [
    { url: './codigo/apitiposervicio.php',     sel: '#servicio' },
    { url: './codigo/apitipoidentificacion.php', sel: '#tipo_identificacion' },
    { url: './codigo/apimetodopago.php',       sel: '#metodoPago' },
    { url: './codigo/apicomercial.php',        sel: '#comercial' },
    { url: './codigo/apicomoseentero.php',     sel: '#comoSeEntero' } // <— unifica este nombre
  ];

  const populateSelect = async ({ url, sel }) => {
    const select = $(sel);
    if (!select) return;

    try {
      const res = await fetch(url, { headers: { 'Accept': 'application/json' } });
      if (!res.ok) throw new Error(`${res.status} ${res.statusText}`);
      const data = await res.json();

      // preserva el primer option si era “Seleccione…”
      const first = select.querySelector('option:first-child')?.cloneNode(true);
      select.innerHTML = '';
      if (first) select.appendChild(first);

      Object.entries(data).forEach(([value, text]) => {
        select.add(new Option(text, value));
      });
    } catch (err) {
      console.error(`Error cargando ${url}:`, err);
      const opt = new Option('Error cargando datos', '', true, true);
      opt.disabled = true;
      select.add(opt);
      select.disabled = true;
    }
  };

  Promise.all(endpoints.map(populateSelect));

  // ----- Transformaciones de inputs
  // Mayúsculas para todos los text menos email
  document.querySelectorAll('input[type="text"]').forEach((inp) => {
    if (inp.id !== 'email') {
      inp.addEventListener('input', () => {
        inp.value = inp.value.toUpperCase();
      });
    }
  });

  // Email en minúsculas
  const email = $('#email');
  email?.addEventListener('input', () => {
    email.value = email.value.toLowerCase();
  });

  // Placa sin espacios
  const placa = $('#placa');
  placa?.addEventListener('input', () => {
    placa.value = placa.value.replace(/\s+/g, '');
  });

  // ----- Tamaño del form (para decidir tamaño de la imagen de fondo)
  const rect = $('#formulario')?.getBoundingClientRect();
  if (rect) {
    console.log(`form: ${Math.round(rect.width)}×${Math.round(rect.height)} px`);
  }
});
