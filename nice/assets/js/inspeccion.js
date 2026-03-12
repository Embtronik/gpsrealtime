// assets/js/inspeccion.js

// Config del servidor (inyectada en la vista inspeccion.php)
const { ENDPOINT_SCHEMA, SESSION_USER } = window.APP || {};

// --- Opciones especiales para algunos ítems ---
const OPCIONES_UBICACION = [
  'paral izquierdo','parar derecho','silla conductor','silla copiloto',
  'techo','posa pie','palanca de cambios','silla trasera combustible','parte delantera motor'
];
const OPCIONES_ENERGIA = ['Corte de corriente','Corte de combustible','Sin corte'];

// Paleta de colores (para el select del ítem Color)
const COLOR_OPTIONS = [
  'Blanco','Negro','Gris','Rojo','Azul','Verde','Amarillo','Naranja','Plateado','Beige'
];

// --- Helpers ---
function hoyLocalYYYYMMDD() {
  const d = new Date();
  const y = d.getFullYear();
  const m = String(d.getMonth()+1).padStart(2,'0');
  const day = String(d.getDate()).padStart(2,'0');
  return `${y}-${m}-${day}`;
}
function normalize(str){return (str||'').toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g,'');}
function esItemUbicacion(n){return normalize(n)===normalize('Ubicación del GPS segura y discreta');}
function esItemEnergia(n){return normalize(n)===normalize('Donde Toma Energía para GPS');}
function esItemColor(n){return normalize(n)===normalize('Color');}

// Inicializa el comportamiento del select de color (mostrar input "Otro...")
function setupColorSelects(){
  document.querySelectorAll('.color-select-wrap').forEach(wrap => {
    const sel = wrap.querySelector('.observacion-color-sel');
    const otro = wrap.querySelector('.observacion-color-otro');
    if (!sel || !otro) return;

    // Estado inicial: ocultar input si no está "OTRO"
    if (sel.value !== 'OTRO') otro.classList.add('d-none');

    sel.addEventListener('change', () => {
      if (sel.value === 'OTRO') {
        otro.classList.remove('d-none');
        otro.focus();
      } else {
        otro.classList.add('d-none');
        otro.value = '';
      }
    });
  });
}

// --- Render principal ---
function renderFormulario(schema) {
  const cont = document.getElementById('form-container');
  cont.innerHTML = '';

  const fechaHoy = hoyLocalYYYYMMDD();

  // �"?�"? Sección: datos generales �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?
  const cardGen = document.createElement('div');
  cardGen.className = 'insp-card';
  cardGen.innerHTML = `
    <div class="insp-card-header">
      <i class="bi bi-clipboard2-fill"></i>
      <span>Datos Generales</span>
    </div>
    <div class="insp-card-body">
      <div class="generales-grid">
        <div>
          <label class="gps-label">Fecha</label>
          <input type="date" id="fecha" class="gps-input" value="${fechaHoy}" disabled>
          <input type="hidden" id="fecha_hidden" value="${fechaHoy}">
        </div>
        <div>
          <label class="gps-label">Técnico</label>
          <input type="text" id="tecnico" class="gps-input" value="${SESSION_USER?.nombre || ''}" disabled>
          <input type="hidden" id="tecnico_hidden" value="${SESSION_USER?.nombre || ''}">
          <input type="hidden" id="user_id_hidden" value="${SESSION_USER?.user_id || 0}">
        </div>
        <div>
          <label class="gps-label">Placa <span class="req">*</span></label>
          <input type="text" id="placa" class="gps-input" placeholder="ABC123" style="text-transform:uppercase;letter-spacing:.08em;font-weight:600">
        </div>
        <div>
          <label class="gps-label">Teléfono cliente</label>
          <input type="tel" id="telefono_cliente" class="gps-input" inputmode="tel" placeholder="+57 311 123 4567">
        </div>
        <div class="col-full">
          <label class="gps-label">Nombre del cliente <span class="req">*</span></label>
          <input type="text" id="nombre_cliente" class="gps-input" placeholder="Nombre y apellido" required>
        </div>
        <div class="col-full">
          <label class="gps-label">Email cliente</label>
          <input type="email" id="email_cliente" class="gps-input" inputmode="email" placeholder="cliente@dominio.com">
        </div>
      </div>
    </div>`;
  cont.appendChild(cardGen);

  // �"?�"? Secciones por categoría �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?
  schema.categorias.forEach(cat => {
    const card = document.createElement('div');
    card.className = 'insp-card';
    card.innerHTML = `
      <div class="insp-card-header">
        <i class="bi bi-check2-square"></i>
        <span>${cat.nombre}</span>
      </div>`;
    const body = document.createElement('div');
    body.className = 'insp-card-body';

    if (cat.items.length > 0) {
      cat.items.forEach(it => {
        const itemDiv = document.createElement('div');
        itemDiv.className = 'item-insp';

        // Estado HTML
        const estadoHtml = `
          <div>
            <label class="gps-label">Estado</label>
            <select class="gps-input gps-estado estado" data-item-id="${it.id}" required>
              <option value="">Seleccione...</option>
              <option value="BUENO">&#10004; BUENO</option>
              <option value="REGULAR">~ REGULAR</option>
              <option value="MALO">&#10008; MALO</option>
              <option value="NA">N/A</option>
            </select>
          </div>`;

        // Observación según el ítem
        let observacionHtml;
        if (esItemUbicacion(it.nombre)) {
          const opts = ['<option value="">Seleccione...</option>']
            .concat(OPCIONES_UBICACION.map(o => `<option value="${o}">${o}</option>`)).join('');
          observacionHtml = `
            <div class="col-full">
              <label class="gps-label">Ubicación</label>
              <select class="gps-input observacion" data-item-id="${it.id}">${opts}</select>
            </div>`;
        } else if (esItemEnergia(it.nombre)) {
          const opts = ['<option value="">Seleccione...</option>']
            .concat(OPCIONES_ENERGIA.map(o => `<option value="${o}">${o}</option>`)).join('');
          observacionHtml = `
            <div class="col-full">
              <label class="gps-label">Fuente de energía</label>
              <select class="gps-input observacion" data-item-id="${it.id}">${opts}</select>
            </div>`;
        } else if (esItemColor(it.nombre)) {
          const opts = ['<option value="">Seleccione...</option>']
            .concat(COLOR_OPTIONS.map(n => `<option value="${n}">${n}</option>`))
            .concat('<option value="OTRO">Otro...</option>').join('');
          observacionHtml = `
            <div class="col-full">
              <label class="gps-label">Color <span class="req">*</span></label>
              <div class="color-select-wrap" data-item-id="${it.id}">
                <select class="gps-input observacion-color-sel" data-item-id="${it.id}" required>${opts}</select>
                <input type="text" class="gps-input mt-2 observacion-color-otro d-none" placeholder="Escriba el color (p. ej. #7f1d1d)">
                <div class="invalid-feedback">Selecciona o escribe un color.</div>
              </div>
            </div>`;
        } else {
          observacionHtml = `
            <div class="col-full">
              <label class="gps-label">Observaciones</label>
              <input class="gps-input observacion" data-item-id="${it.id}" placeholder="Detalle...">
            </div>`;
        }

        itemDiv.innerHTML = `
          <div class="item-insp-nombre">${it.nombre}</div>
          <div class="item-insp-fields">
            ${estadoHtml}
            ${observacionHtml}
          </div>`;
        body.appendChild(itemDiv);
      });

    } else {
      // Categoría sin ítems �?' textarea de novedades
      body.innerHTML = `
        <label class="gps-label">Novedades / Observaciones</label>
        <textarea class="gps-input" id="novedades" rows="5"
          placeholder="Describa daños, particularidades, recomendaciones�?�"></textarea>`;
    }

    card.appendChild(body);
    cont.appendChild(card);
  });

  // Activa el comportamiento del select de color
  setupColorSelects();

  // �"?�"? Botones de acción �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?
  const acciones = document.createElement('div');
  acciones.className = 'btns-wrap';
  acciones.innerHTML = `
    <button id="btnGuardar" class="gps-btn-primary">
      <i class="bi bi-send-fill"></i>Guardar Inspección
    </button>
    <button id="btnLimpiar" class="gps-btn-secondary">
      <i class="bi bi-arrow-counterclockwise"></i>Limpiar
    </button>`;
  cont.appendChild(acciones);

  // Colorear select de estado al cambiar valor
  cont.querySelectorAll('select.gps-estado').forEach(sel => {
    sel.addEventListener('change', () => {
      sel.dataset.val = sel.value;
    });
  });

  document.getElementById('btnLimpiar').onclick = () => {
    cont.querySelectorAll('input:not([disabled]), select:not([disabled]), textarea').forEach(e => {
      if (e.type === 'hidden') return;
      if (e.tagName === 'SELECT') e.selectedIndex = 0;
      else e.value = '';
    });
    cont.querySelectorAll('select.gps-estado').forEach(s => { delete s.dataset.val; });
  };
  document.getElementById('btnGuardar').onclick = () => {
    const fecha     = (document.getElementById('fecha_hidden').value || '').trim();
    const tecnico   = (document.getElementById('tecnico_hidden').value || '').trim();
    const placa     = (document.getElementById('placa').value || '').trim().toUpperCase();

    const nombre_cliente   = (document.getElementById('nombre_cliente').value || '').trim();
    const email_cliente    = (document.getElementById('email_cliente').value || '').trim();
    const telefono_cliente = (document.getElementById('telefono_cliente').value || '').trim();

    const novedades = (document.getElementById('novedades')?.value || '').trim();

    // Arma detalle (si es Color, toma el select y/o el input "Otro")
    const detalle = [];
    document.querySelectorAll('select.estado').forEach(sel => {
      const itemId = Number(sel.dataset.itemId);
      const estado = sel.value;

      // Observación por defecto (input o select normal)
      let obsInput = document.querySelector(`.observacion[data-item-id="${itemId}"]`);
      let observaciones = obsInput ? String(obsInput.value || '').trim() : '';

      // Si es control Color, priorizar su valor
      const wrap = document.querySelector(`.color-select-wrap[data-item-id="${itemId}"]`);
      if (wrap) {
        const selColor = wrap.querySelector('.observacion-color-sel');
        const otro     = wrap.querySelector('.observacion-color-otro');
        const elegido  = (selColor?.value || '').trim();
        const typed    = (otro?.value || '').trim();
        observaciones  = (elegido === 'OTRO') ? typed : elegido;
      }

      detalle.push({ itemId, estado, observaciones });
    });

    // Validaciones simples
    if (!placa) { alert('La placa es requerida'); return; }
    const nombreEl = document.getElementById('nombre_cliente');
    if (!nombre_cliente) {
        nombreEl.classList.add('is-invalid');           // Bootstrap marca el campo en rojo
        nombreEl.focus();
        alert('El nombre del cliente es obligatorio');
        return;
    } else {
        nombreEl.classList.remove('is-invalid');
    }
    if (email_cliente && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email_cliente)) {
      alert('Email inválido'); return;
    }
    if (telefono_cliente.length > 30) {
      alert('El teléfono es demasiado largo (máx. 30)'); return;
    }
    if (!validateColorRequired()) {
        alert('Falta seleccionar el Color (o escribirlo si elegiste �?oOtro�?��?�).');
        return;
    }

    const payload = {
      fecha, tecnico, placa, novedades, detalle,
      nombre_cliente, email_cliente, telefono_cliente
    };    

    fetch('codigo/save_inspeccion.php', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    })
    .then(r => r.json())
    .then(res => {
      if (!res.success) throw new Error(res.message || 'Error al guardar');
      resetFormulario();
    })
    .catch(err => {
      console.error(err);
      alert('No se pudo guardar: ' + err.message);
    });
  };
}

function validateColorRequired() {
  let ok = true;
  let firstInvalid = null;

  document.querySelectorAll('.color-select-wrap').forEach(wrap => {
    const sel  = wrap.querySelector('.observacion-color-sel');
    const otro = wrap.querySelector('.observacion-color-otro');

    // Regla: debe escoger un color. Si elige "OTRO", debe escribir algo.
    const valSel  = (sel?.value || '').trim();
    const valOtro = (otro?.value || '').trim();

    // Limpia estados previos
    if (sel)  sel.classList.remove('is-invalid');
    if (otro) otro.classList.remove('is-invalid');

    let valido = true;
    if (valSel === '') {
      valido = false;
      if (sel) sel.classList.add('is-invalid');
      if (!firstInvalid) firstInvalid = sel;
    } else if (valSel === 'OTRO' && valOtro === '') {
      valido = false;
      if (otro) otro.classList.add('is-invalid');
      if (!firstInvalid) firstInvalid = otro;
    }

    ok = ok && valido;
  });

  if (!ok && firstInvalid) {
    firstInvalid.focus();
    // desplaza un poquito hacia arriba por si el header tapa el campo
    const y = firstInvalid.getBoundingClientRect().top + window.scrollY - 100;
    window.scrollTo({ top: y, behavior: 'smooth' });
  }

  return ok;
}

// --- Carga del schema ---
async function loadSchema() {
  const container = document.getElementById('form-container');
  container.innerHTML = '<div class="alert alert-info">Cargando formulario�?�</div>';
  try {
    const resp = await fetch(ENDPOINT_SCHEMA, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    });
    if (!resp.ok) {
      const errorText = await resp.text();
      throw new Error(`HTTP ${resp.status} - ${errorText}`);
    }
    const data = await resp.json();
    if (!data.success || !Array.isArray(data.categorias)) {
      throw new Error(data.message || 'Respuesta inválida');
    }
    renderFormulario(data);
  } catch (err) {
    console.error(err);
    container.innerHTML = `
      <div class="alert alert-danger">
        No fue posible cargar el formulario. ${err.message}
      </div>`;
  }
}

function resetFormulario(){
  // Campos de cabecera (dejamos fecha/técnico como están)
  ['placa','nombre_cliente','email_cliente','telefono_cliente'].forEach(id=>{
    const el = document.getElementById(id);
    if (el) el.value = '';
  });

  // Novedades
  const nov = document.getElementById('novedades');
  if (nov) nov.value = '';

  // Estados de cada ítem
  document.querySelectorAll('select.estado').forEach(sel => sel.value = '');

  // Observaciones genéricas (input/select)
  document.querySelectorAll('.observacion').forEach(el => {
    if (el.tagName === 'SELECT') el.selectedIndex = 0;
    else el.value = '';
  });

  // Ítem Color: select + "Otro"
  document.querySelectorAll('.color-select-wrap').forEach(wrap => {
    const sel  = wrap.querySelector('.observacion-color-sel');
    const otro = wrap.querySelector('.observacion-color-otro');
    if (sel)  sel.value = '';
    if (otro){ otro.value = ''; otro.classList.add('d-none'); }
  });

  // Opcional: subir al inicio
  window.scrollTo({ top: 0, behavior: 'smooth' });
}


document.addEventListener('DOMContentLoaded', loadSchema);
