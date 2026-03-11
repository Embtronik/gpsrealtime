'use strict';

//  Cache para evitar múltiples fetches de los mismos datos 
let _usersCache = null;
let _stadeCache = null;

//  Paginacion – estado por item de acordeon 
const _pagerState = new Map(); // collapseId -> { rows, page, pageSize, filtered }
const PAGE_SIZE = 10;

//  Toast helper 
function showToast(message, type = 'success') {
  const container = document.getElementById('toastContainer');
  if (!container) return;
  const id = 'toast-' + Date.now();
  const icons = { success: 'bi-check-circle-fill', danger: 'bi-x-circle-fill', warning: 'bi-exclamation-triangle-fill' };
  const icon = icons[type] || 'bi-info-circle-fill';
  container.insertAdjacentHTML('beforeend', `
    <div id="${id}" class="toast align-items-center text-bg-${type} border-0" role="alert" aria-live="assertive" aria-atomic="true">
      <div class="d-flex align-items-center">
        <div class="toast-body d-flex align-items-center gap-2">
          <i class="bi ${icon}"></i>
          <span>${message}</span>
        </div>
        <button type="button" class="btn-close btn-close-white me-2 ms-auto" data-bs-dismiss="toast" aria-label="Cerrar"></button>
      </div>
    </div>`);
  const el = document.getElementById(id);
  new bootstrap.Toast(el, { delay: 4000 }).show();
  el.addEventListener('hidden.bs.toast', () => el.remove());
}

//  Construir acordeón con los usuarios 
fetch('../codigo/apiusuarios.php', { method: 'POST' })
  .then(r => r.json())
  .then(async users => {
    const container = document.getElementById('accordionExample');
    const loader    = document.getElementById('acordeonLoader');
    if (loader) loader.remove();

    if (!Array.isArray(users) || users.length === 0) {
      container.innerHTML = '<p class="text-center text-muted py-4">No hay usuarios activos.</p>';
      return;
    }

    let html = '';
    let counter = 1;

    for (const row of users) {
      const username   = row.username;
      const iduser     = row.idusuario;
      const collapseId = `collapse${counter}`;
      const tab        = `table${counter}`;
      const isFirst    = counter === 1;

      const { rowsHTML, count } = await generateTableRows(iduser);

      html += `
        <div class="accordion-item">
          <h2 class="accordion-header" id="heading-${collapseId}">
            <button class="accordion-button${isFirst ? '' : ' collapsed'}" type="button"
                    data-bs-toggle="collapse" data-bs-target="#${collapseId}"
                    aria-expanded="${isFirst}" aria-controls="${collapseId}">
              <i class="bi bi-person-fill me-2 opacity-75" style="font-size:1rem;color:#4154f1;"></i>
              <span class="fw-semibold">${escHtml(username)}</span>
              <span class="badge rounded-pill badge-count ms-3"
                    data-total="${count}"
                    style="background:#4154f1;font-size:.7rem;padding:.3em .75em;margin-right:24px;">
                ${count} registro${count !== 1 ? 's' : ''}
              </span>
            </button>
          </h2>
          <div id="${collapseId}" class="accordion-collapse collapse${isFirst ? ' show' : ''}"
               aria-labelledby="heading-${collapseId}" data-bs-parent="#accordionExample">
            <div class="accordion-body p-0">
              <div class="table-acord-wrapper">
                <table id="${tab}" class="table table-hover table-bordered table-sm table-acord align-middle mb-0">
                  <thead>
                    <tr>
                      <th>Nombre</th>
                      <th>Fecha</th>
                      <th>Servicio</th>
                      <th>Asignado</th>
                      <th>Estado</th>
                      <th>Operador</th>
                      <th>IMEI</th>
                      <th>Línea</th>
                      <th>Renovación</th>
                      <th>Fecha Renovación</th>
                      <th>Recarga</th>
                      <th>Fecha Recarga</th>
                      <th>Instalador</th>
                      <th>Instalación</th>
                      <th>Valor Instalación</th>
                      <th>Pago Instalación</th>
                      <th>Valor Venta</th>
                      <th>Método Pago</th>
                      <th>Realizar Factura</th>
                      <th>Manejo</th>
                      <th>Ingreso Pago</th>
                      <th>Remisión</th>
                      <th>Factura N°</th>
                      <th>Actualización</th>
                      <th>Placa</th>
                      <th>Marca</th>
                      <th>Referencia</th>
                      <th>Modelo</th>
                      <th>Cilindraje</th>
                      <th>Tipo Ident.</th>
                      <th>N° Identificación</th>
                      <th>Teléfono</th>
                      <th>Email</th>
                      <th>Dirección</th>
                      <th>¿Cómo se enteró?</th>
                      <th>Guardar</th>
                    </tr>
                  </thead>
                  <tbody>
                    ${rowsHTML}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>`;
      counter++;
    }

    container.innerHTML = html;
    initAllPaginators();
  })
  .catch(err => {
    const container = document.getElementById('accordionExample');
    container.innerHTML = `<p class="text-center text-danger py-4">
      <i class="bi bi-exclamation-circle me-2"></i>Error al cargar datos: ${escHtml(err.message)}
    </p>`;
  });

//  Genera filas de tabla para un usuario 
async function generateTableRows(iduser) {
  let rowsHTML = '';
  let count = 0;

  try {
    const [dataRes, selectOptions, selectStade] = await Promise.all([
      fetch('../codigo/apilead_por_usuarios.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ parametro: iduser })
      }).then(r => r.json()),
      generateSelect(iduser),
      generateStade()
    ]);

    (dataRes.data || []).forEach(row => {
      count++;
      const fechaInicio = (row.FechaInicio     || '').split(' ')[0];
      const fechaRen    = (row.FechaRenovacion  || '').split(' ')[0];
      const fechaRec    = (row.FechaRecarga     || '').split(' ')[0];

      rowsHTML += `
        <tr>
          <th style="display:none" scope="row">${count}</th>
          <td style="display:none">${row.idUsuario}</td>
          <td class="fw-semibold text-nowrap">${escHtml(row.Nombre)}</td>
          <td style="display:none">${row.idServicio}</td>
          <td class="text-center text-nowrap">${fechaInicio}</td>
          <td class="text-nowrap">${escHtml(row.Servicio)}</td>
          <td style="display:none">${row.idDatosServicio}</td>
          <td>
            <select class="form-select form-select-sm" style="min-width:130px;">
              ${selectOptions.replace('value="' + row.idAuxiliar + '"', 'value="' + row.idAuxiliar + '" selected')}
            </select>
          </td>
          <td><select class="form-select form-select-sm" style="min-width:130px;">${selectStade}</select></td>
          <td><input type="text"  class="form-control form-control-sm" value="${escHtml(row.Operador)}"          style="min-width:100px;"></td>
          <td><input type="text"  class="form-control form-control-sm" placeholder="IMEI"   value="${escHtml(row.IMEI)}"            style="min-width:140px;"></td>
          <td><input type="text"  class="form-control form-control-sm" placeholder="Línea"  value="${escHtml(row.Linea)}"           style="min-width:110px;"></td>
          <td><input type="text"  class="form-control form-control-sm" value="${escHtml(row.Renovacion)}"        style="min-width:90px;"></td>
          <td><input type="date"  class="form-control form-control-sm" value="${fechaRen}"                        style="min-width:130px;"></td>
          <td><input type="text"  class="form-control form-control-sm" value="${escHtml(row.Recarga)}"           style="min-width:90px;"></td>
          <td><input type="date"  class="form-control form-control-sm" value="${fechaRec}"                        style="min-width:130px;"></td>
          <td><input type="text"  class="form-control form-control-sm" value="${escHtml(row.Instalacion)}"       style="min-width:90px;"></td>
          <td><input type="text"  class="form-control form-control-sm" value="${escHtml(row.Instalador)}"        style="min-width:110px;"></td>
          <td><input type="text"  class="form-control form-control-sm" value="${escHtml(row.ValorInstalacion)}"  style="min-width:90px;"></td>
          <td><input type="text"  class="form-control form-control-sm" value="${escHtml(row.PagoInstalacion)}"   style="min-width:90px;"></td>
          <td><input type="text"  class="form-control form-control-sm" value="${escHtml(row.ValorVenta)}"        style="min-width:90px;"></td>
          <td><input type="text"  class="form-control form-control-sm" value="${escHtml(row.MetodoPago)}"        style="min-width:110px;"></td>
          <td><input type="text"  class="form-control form-control-sm" value="${escHtml(row.RealizarFactura)}"   style="min-width:90px;"></td>
          <td><input type="text"  class="form-control form-control-sm" value="${escHtml(row.Manejo)}"            style="min-width:90px;"></td>
          <td><input type="text"  class="form-control form-control-sm" value="${escHtml(row.IngresoPago)}"       style="min-width:90px;"></td>
          <td><input type="text"  class="form-control form-control-sm" value="${escHtml(row.Remision)}"          style="min-width:90px;"></td>
          <td><input type="text"  class="form-control form-control-sm" value="${escHtml(row.FacturaNumero)}"     style="min-width:90px;"></td>
          <td><input type="text"  class="form-control form-control-sm" value="${escHtml(row.Actualizacion)}"     style="min-width:90px;"></td>
          <td style="display:none">${row.idVehiculo}</td>
          <td class="text-nowrap">${escHtml(row.Placa)}</td>
          <td class="text-nowrap">${escHtml(row.Marca)}</td>
          <td class="text-nowrap">${escHtml(row.Referencia)}</td>
          <td class="text-nowrap">${escHtml(row.Modelo)}</td>
          <td>${escHtml(row.Cilindraje)}</td>
          <td class="text-nowrap">${escHtml(row.TipoIdentificacion)}</td>
          <td>${escHtml(row.NumeroIdentificacion)}</td>
          <td>${escHtml(row.Telefono)}</td>
          <td>${escHtml(row.Email)}</td>
          <td>${escHtml(row.Direccion)}</td>
          <td>${escHtml(row.ComoSeEntero)}</td>
          <td style="display:none">${row.idAuxiliar}</td>
          <td class="text-center">
            <button type="button" class="btn btn-primary btn-sm btn-guardar px-3" onclick="Guardar(this)">
              <i class="bi bi-floppy me-1"></i>Guardar
            </button>
          </td>
        </tr>`;
    });
  } catch (err) {
    console.error('Error generando filas para usuario', iduser, err);
  }

  return { rowsHTML, count };
}

//  Guardar cambios de una fila 
function Guardar(button) {
  const row      = button.closest('tr');
  const valimei  = row.cells[10].querySelector('input').value.trim();
  const vallinea = row.cells[11].querySelector('input').value.trim();

  if (!valimei || !vallinea) {
    showToast('El IMEI y la Línea no deben estar vacíos.', 'warning');
    return;
  }

  button.disabled = true;
  button.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>Guardando';

  const dataToSend = {
    idServicio:       row.cells[3].textContent.trim(),
    FechaInicio:      row.cells[4].textContent.trim(),
    idDatosServicio:  row.cells[6].textContent.trim(),
    Asignado:         row.cells[7].querySelector('select').value,
    Estado:           row.cells[8].querySelector('select').value,
    Operador:         row.cells[9].querySelector('input').value,
    IMEI:             row.cells[10].querySelector('input').value,
    Linea:            row.cells[11].querySelector('input').value,
    Renovacion:       row.cells[12].querySelector('input').value,
    FechaRenovacion:  row.cells[13].querySelector('input').value,
    Recarga:          row.cells[14].querySelector('input').value,
    FechaRecarga:     row.cells[15].querySelector('input').value,
    Instalacion:      row.cells[16].querySelector('input').value,
    Instalador:       row.cells[17].querySelector('input').value,
    ValorInstalacion: row.cells[18].querySelector('input').value,
    PagoInstalacion:  row.cells[19].querySelector('input').value,
    ValorVenta:       row.cells[20].querySelector('input').value,
    MetodoPago:       row.cells[21].querySelector('input').value,
    RealizarFactura:  row.cells[22].querySelector('input').value,
    Manejo:           row.cells[23].querySelector('input').value,
    IngresoPago:      row.cells[24].querySelector('input').value,
    Remision:         row.cells[25].querySelector('input').value,
    FacturaNumero:    row.cells[26].querySelector('input').value,
    Actualizacion:    row.cells[27].querySelector('input').value,
  };

  fetch('../codigo/apiGuardarDetalleServicio.php', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(dataToSend),
  })
    .then(r => r.json())
    .then(() => {
      button.innerHTML = '<i class="bi bi-check-lg me-1"></i>Guardado';
      button.classList.replace('btn-primary', 'btn-success');
      showToast('Datos guardados correctamente.', 'success');
      setTimeout(() => {
        button.disabled = false;
        button.innerHTML = '<i class="bi bi-floppy me-1"></i>Guardar';
        button.classList.replace('btn-success', 'btn-primary');
      }, 3000);
    })
    .catch(() => {
      button.disabled = false;
      button.innerHTML = '<i class="bi bi-floppy me-1"></i>Guardar';
      showToast('Error al guardar los datos. Intente de nuevo.', 'danger');
    });
}

//  Select de usuarios (con caché) 
function generateSelect(iddato) {
  const build = users => users.map(u => {
    const sel = Number(u.idusuario) === Number(iddato) ? ' selected' : '';
    return `<option value="${u.idusuario}"${sel}>${escHtml(u.username)}</option>`;
  }).join('');

  if (_usersCache) return Promise.resolve(build(_usersCache));
  return fetch('../codigo/apiusuarios.php', { method: 'POST' })
    .then(r => r.json())
    .then(data => { _usersCache = data; return build(data); })
    .catch(err => { console.error(err); return ''; });
}

//  Select de estados (con caché) 
function generateStade() {
  const build = data => data.map(s =>
    `<option value="${s.idp_estadoServicio}">${escHtml(s.descripcion)}</option>`
  ).join('');

  if (_stadeCache) return Promise.resolve(build(_stadeCache));
  return fetch('../codigo/apiEstadoServicio.php', { method: 'POST' })
    .then(r => r.json())
    .then(data => { _stadeCache = data; return build(data); })
    .catch(err => { console.error(err); return ''; });
}

//  Escape HTML
function escHtml(str) {
  return String(str ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

// ── Inicializar paginacion en todos los items ─────────────────────
function initAllPaginators() {
  document.querySelectorAll('.accordion-item').forEach(function(item) {
    const collapse = item.querySelector('.accordion-collapse');
    if (!collapse) return;
    const id   = collapse.id;
    const rows = Array.from(item.querySelectorAll('tbody tr'));
    _pagerState.set(id, { rows: rows, page: 1, pageSize: PAGE_SIZE, filtered: null });
    // Inyectar barra de paginacion
    const body = item.querySelector('.accordion-body');
    if (body) {
      const bar = document.createElement('div');
      bar.className = 'acord-pager d-flex align-items-center justify-content-between flex-wrap gap-2 px-3 py-2 border-top';
      bar.innerHTML = '<span class="acord-pager-info text-muted small"></span><ul class="pagination pagination-sm mb-0 ms-auto acord-pager-pages"></ul>';
      body.appendChild(bar);
    }
    renderPage(id);
  });
}

// ── Renderizar pagina actual ──────────────────────────────────────
function renderPage(id) {
  const state = _pagerState.get(id);
  if (!state) return;
  const rows  = state.filtered !== null ? state.filtered : state.rows;
  const total = rows.length;
  const pages = Math.max(1, Math.ceil(total / state.pageSize));
  state.page  = Math.max(1, Math.min(state.page, pages));
  const start = (state.page - 1) * state.pageSize;
  const end   = start + state.pageSize;

  state.rows.forEach(function(r) { r.style.display = 'none'; });
  rows.slice(start, end).forEach(function(r) { r.style.display = ''; });

  const el = document.getElementById(id);
  const item = el ? el.closest('.accordion-item') : null;
  if (!item) return;

  const info = item.querySelector('.acord-pager-info');
  const ul   = item.querySelector('.acord-pager-pages');
  if (info) {
    if (total === 0) {
      info.textContent = 'Sin registros';
    } else {
      info.textContent = 'Mostrando ' + (start + 1) + ' - ' + Math.min(end, total) + ' de ' + total + ' registro' + (total !== 1 ? 's' : '');
    }
  }
  if (ul) ul.innerHTML = buildPageButtons(id, state.page, pages);
}

// ── Construir botones de pagina ───────────────────────────────────
function buildPageButtons(id, page, pages) {
  if (pages <= 1) return '';
  var safe = id.replace(/\\/g, '\\\\').replace(/'/g, "\\'");

  function btn(p, label, disabled, active) {
    if (disabled) return '<li class="page-item disabled"><span class="page-link">' + label + '</span></li>';
    if (active)   return '<li class="page-item active"><span class="page-link">' + label + '</span></li>';
    return '<li class="page-item"><button type="button" class="page-link" onclick="goToPage(\'' + safe + '\',' + p + ')">' + label + '</button></li>';
  }

  var html = '';
  html += btn(1,        '&laquo;', page === 1, false);
  html += btn(page - 1, '&lsaquo;', page === 1, false);

  var range = pageRange(page, pages);
  var prev = null;
  for (var i = 0; i < range.length; i++) {
    var p = range[i];
    if (prev !== null && p - prev > 1) {
      html += '<li class="page-item disabled"><span class="page-link">&#8230;</span></li>';
    }
    html += btn(p, p, false, p === page);
    prev = p;
  }

  html += btn(page + 1, '&rsaquo;', page === pages, false);
  html += btn(pages,    '&raquo;', page === pages, false);
  return html;
}

// ── Rango de paginas a mostrar (con ventana centrada) ─────────────
function pageRange(page, pages) {
  var set = {};
  set[1] = true;
  set[pages] = true;
  for (var i = Math.max(1, page - 1); i <= Math.min(pages, page + 1); i++) set[i] = true;
  return Object.keys(set).map(Number).sort(function(a, b) { return a - b; });
}

// ── Cambiar pagina (global, llamado por onclick) ──────────────────
function changePage(id, delta) {
  var state = _pagerState.get(id);
  if (!state) return;
  state.page += delta;
  renderPage(id);
}

function goToPage(id, p) {
  var state = _pagerState.get(id);
  if (!state) return;
  state.page = Number(p);
  renderPage(id);
}

// ── Filtro global (llamado por coincidencia.js) ───────────────────
function applyFilter(term) {
  document.querySelectorAll('.accordion-item').forEach(function(item) {
    var collapse = item.querySelector('.accordion-collapse');
    if (!collapse) return;
    var id       = collapse.id;
    var state    = _pagerState.get(id);
    var badge    = item.querySelector('.badge-count');
    var total    = badge ? Number(badge.dataset.total) : 0;
    var pagerBar = item.querySelector('.acord-pager');
    if (!state) return;

    if (term) {
      var matched = state.rows.filter(function(r) {
        return r.textContent.toLowerCase().includes(term);
      });
      state.filtered = matched;
      state.rows.forEach(function(r) { r.style.display = 'none'; });
      matched.forEach(function(r)    { r.style.display = ''; });
      if (badge) {
        badge.textContent = matched.length + ' resultado' + (matched.length !== 1 ? 's' : '');
        badge.style.background = matched.length > 0 ? '#198754' : '#dc3545';
      }
      item.style.display = matched.length > 0 ? '' : 'none';
      if (pagerBar) pagerBar.style.display = 'none';
    } else {
      state.filtered = null;
      state.page = 1;
      if (pagerBar) pagerBar.style.display = '';
      renderPage(id);
      if (badge) {
        badge.textContent = total + ' registro' + (total !== 1 ? 's' : '');
        badge.style.background = '#4154f1';
      }
      item.style.display = '';
    }
  });
}