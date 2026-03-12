'use strict';

const PAGE_SIZE = 50;
let _filters = {};
let _currentPage = 1;

// ─── Inicialización ───────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', function () {
  document.getElementById('formBuscarCliente').addEventListener('submit', (e) => {
    e.preventDefault();
    _filters = leerFiltros();
    _currentPage = 1;
    fetchPage(1);
  });
});

function leerFiltros() {
  return {
    name:            document.getElementById('inputName').value,
    correo:          document.getElementById('inputEmail').value,
    ident:           document.getElementById('inputIdentificacion').value,
    fechaInicio:     document.getElementById('fechaDesde').value,
    fechaFin:        document.getElementById('fechaHasta').value,
    matricula:       document.getElementById('placa').value,
    imei:            document.getElementById('imei').value,
    linea:           document.getElementById('linea').value,
    extraParam:      document.getElementById('extraParams').value,
    extraParamValue: document.getElementById('extraParamValue').value,
  };
}

// ─── Fetch de una página ──────────────────────────────────────────────────────
async function fetchPage(page) {
  _currentPage = page;
  const tbody = document.querySelector('#tableClientes tbody');
  tbody.innerHTML = '<tr><td colspan="46" class="text-center py-3"><div class="spinner-border spinner-border-sm"></div> Buscando...</td></tr>';

  const btn = document.getElementById('btnBuscar');
  if (btn) { btn.disabled = true; btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status"></span>Buscando...'; }

  try {
    const resp = await fetch('../codigo/apiBuscarClientes.php', {
      method: 'POST',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ..._filters, page, pageSize: PAGE_SIZE }),
    });
    if (!resp.ok) throw new Error('Error HTTP ' + resp.status);
    const json = await resp.json();
    if (!json.success) throw new Error(json.message || 'Error en la consulta');
    renderTabla(json.data, page);
    renderPaginacion(json.total, page, PAGE_SIZE);
  } catch (e) {
    console.error(e);
    document.querySelector('#tableClientes tbody').innerHTML =
      `<tr><td colspan="46" class="text-center text-danger">${escHtml(e.message)}</td></tr>`;
  } finally {
    if (btn) { btn.disabled = false; btn.innerHTML = 'Buscar'; }
  }
}

// ─── Renderizar filas de la tabla ─────────────────────────────────────────────
function renderTabla(rows, page) {
  const tbody = document.querySelector('#tableClientes tbody');
  tbody.innerHTML = '';

  if (!rows || rows.length === 0) {
    tbody.innerHTML = '<tr><td colspan="46" class="text-center text-muted py-3">Sin resultados</td></tr>';
    return;
  }

  let counter = (page - 1) * PAGE_SIZE + 1;
  rows.forEach(row => {
    const fechaInicio = (row.FechaInicio || '').split(' ')[0];
    const fechaRen    = (row.FechaRenovacion || '').split(' ')[0];
    const fechaRec    = (row.FechaRecarga || '').split(' ')[0];

    const partes      = fechaRen.split('-');
    const fechaRenObj = new Date(parseInt(partes[0]), parseInt(partes[1]) - 1, parseInt(partes[2]));
    const diferenciaDias = Math.floor((fechaRenObj - new Date()) / (1000 * 60 * 60 * 24));

    const newRow = document.createElement('tr');
    newRow.dataset.servicio = row.idServicio;
    newRow.dataset.vehiculo = row.idVehiculo;
    newRow.innerHTML = `
      <th scope="row">${counter}</th>
      <td>${escHtml(row.Nombre)}</td>
      <td>${fechaInicio}</td>
      <td>${escHtml(row.Servicio)}</td>
      <td>${escHtml(row.Auxiliar)}</td>
      <td>${escHtml(row.Estado)}</td>
      <td>${escHtml(row.Operador)}</td>
      <td>${escHtml(row.IMEI)}</td>
      <td>${escHtml(row.Linea)}</td>
      <td style="background-color:${getColor(diferenciaDias)};color:white">${diferenciaDias}</td>
      <td>${fechaRen}</td>
      <td>${escHtml(row.Recarga)}</td>
      <td>${fechaRec}</td>
      <td>${escHtml(row.Instalacion)}</td>
      <td>${escHtml(row.Instalador)}</td>
      <td>${escHtml(row.ValorInstalacion)}</td>
      <td>${escHtml(row.PagoInstalacion)}</td>
      <td>${escHtml(row.ValorVenta)}</td>
      <td>${escHtml(row.MetodoPago)}</td>
      <td>${escHtml(row.RealizarFactura)}</td>
      <td>${escHtml(row.Manejo)}</td>
      <td>${escHtml(row.IngresoPago)}</td>
      <td>${escHtml(row.Remision)}</td>
      <td>${escHtml(row.FacturaNumero)}</td>
      <td>${escHtml(row.Actualizacion)}</td>
      <td>${escHtml(row.Placa)}</td>
      <td>${escHtml(row.Marca)}</td>
      <td>${escHtml(row.Referencia)}</td>
      <td>${escHtml(row.Modelo)}</td>
      <td>${escHtml(row.Cilindraje)}</td>
      <td>${escHtml(row.TipoIdentificacion)}</td>
      <td>${escHtml(row.NumeroIdentificacion)}</td>
      <td>${escHtml(row.Telefono)}</td>
      <td>${escHtml(row.Email)}</td>
      <td>${escHtml(row.Direccion)}</td>
      <td>${escHtml(row.ComoSeEntero)}</td>
      <td>${escHtml(row.Comercial)}</td>
      <td>${escHtml(row.nombreTercero)}</td>
      <td>${escHtml(row.identificacionTercero)}</td>
      <td>${escHtml(row.emailTercero)}</td>
      <td>${escHtml(row.telefonoTercero)}</td>
      <td>
        <button type="button" class="btn btn-primary btn-sm" onclick="Editar(this)">Editar</button>
      </td>
      <td>
        <button type="button" class="btn btn-success btn-sm" onclick="Seguimiento(this)">Cliente</button>
      </td>
      <td>
        <button type="button" class="btn btn-warning btn-sm" onclick="Eliminar(this)">Eliminar</button>
      </td>
    `;
    tbody.appendChild(newRow);
    counter++;
  });
}

// ─── Paginación ───────────────────────────────────────────────────────────────
function renderPaginacion(total, page, pageSize) {
  const div        = document.getElementById('paginacion');
  const totalPages = Math.ceil(total / pageSize);
  const desde      = total === 0 ? 0 : (page - 1) * pageSize + 1;
  const hasta      = Math.min(page * pageSize, total);

  let html = `<div class="d-flex justify-content-between align-items-center flex-wrap gap-2 py-2">
    <small class="text-muted">Mostrando <strong>${desde}–${hasta}</strong> de <strong>${total}</strong> registros</small>`;

  if (totalPages > 1) {
    html += '<nav><ul class="pagination pagination-sm mb-0">';
    html += `<li class="page-item ${page === 1 ? 'disabled' : ''}">
      <a class="page-link" href="#" onclick="fetchPage(${page - 1});return false;">&#8249;</a></li>`;
    const pages = buildPageNumbers(page, totalPages);
    let prev = null;
    for (const p of pages) {
      if (prev !== null && p - prev > 1) html += '<li class="page-item disabled"><span class="page-link">&hellip;</span></li>';
      html += `<li class="page-item ${p === page ? 'active' : ''}">
        <a class="page-link" href="#" onclick="fetchPage(${p});return false;">${p}</a></li>`;
      prev = p;
    }
    html += `<li class="page-item ${page === totalPages ? 'disabled' : ''}">
      <a class="page-link" href="#" onclick="fetchPage(${page + 1});return false;">&#8250;</a></li>`;
    html += '</ul></nav>';
  }

  html += '</div>';
  div.innerHTML = html;
}

function buildPageNumbers(current, total) {
  const range = new Set([1, total]);
  for (let i = Math.max(2, current - 2); i <= Math.min(total - 1, current + 2); i++) range.add(i);
  return [...range].sort((a, b) => a - b);
}

// ─── Acciones por fila ────────────────────────────────────────────────────────
function Editar(button) {
  const row      = button.closest('tr');
  const servicio = row.dataset.servicio;
  const vehiculo = row.dataset.vehiculo;
  window.location.href = `editar.html?servicio=${encodeURIComponent(servicio)}&vehiculo=${encodeURIComponent(vehiculo)}`;
}

async function Eliminar(button) {
  const row      = button.closest('tr');
  const servicio = row.dataset.servicio;
  if (!confirm('¿Desea Eliminar este Registro?')) return;
  try {
    const resp = await fetch('../codigo/apiEliminarServicioVehiculo.php', {
      method: 'POST',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ servicio: parseInt(servicio) }),
    });
    if (!resp.ok) throw new Error('Error en la respuesta del servidor');
    row.parentNode.removeChild(row);
  } catch (e) {
    console.error(e);
  }
}

function Seguimiento(button) {
  const row      = button.closest('tr');
  const servicio = row.dataset.servicio;
  const vehiculo = row.dataset.vehiculo;
  window.location.href = `seguimiento.html?servicio=${encodeURIComponent(servicio)}&vehiculo=${encodeURIComponent(vehiculo)}`;
}

// ─── Generar archivo Excel (re-fetch completo desde servidor) ─────────────────
async function generarFile() {
  if (!Object.keys(_filters).length) {
    alert('Primero realice una búsqueda antes de generar el archivo.');
    return;
  }
  const btn = document.querySelector('[onclick="generarFile()"]');
  if (btn) { btn.disabled = true; btn.textContent = 'Descargando…'; }
  try {
    const resp = await fetch('../codigo/apiBuscarClientes.php', {
      method: 'POST',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ..._filters, exportAll: true }),
    });
    if (!resp.ok) throw new Error('Error HTTP ' + resp.status);
    const json = await resp.json();
    if (!json.success) throw new Error(json.message || 'Error al exportar');
    exportarExcel(json.data);
  } catch (e) {
    alert('Error al generar archivo: ' + e.message);
  } finally {
    if (btn) { btn.disabled = false; btn.textContent = 'Generar Archivo'; }
  }
}

function exportarExcel(rows) {
  const headers = [
    '#','Nombre','Fecha Inicio','Servicio','Asignado','Estado','Operador','IMEI','Línea',
    'Días Ren.','Fecha Renovación','Recarga','Fecha Recarga','Instalación','Instalador',
    'Valor Instalación','Pago Instalación','Valor Venta','Método Pago','Realizar Factura',
    'Manejo','Ingreso Pago','Remisión','Factura Nro.','Actualización','Placa','Marca',
    'Referencia','Modelo','Cilindraje','Tipo Identificación','Nro. Identificación',
    'Teléfono','Email','Dirección','Cómo se enteró','Comercial',
    'Nombre Tercero','Ident. Tercero','Email Tercero','Tel. Tercero',
  ];
  const data = [headers];
  rows.forEach((row, i) => {
    const fechaRen = (row.FechaRenovacion || '').split(' ')[0];
    const partes   = fechaRen.split('-');
    const diasRen  = Math.floor(
      (new Date(parseInt(partes[0]), parseInt(partes[1]) - 1, parseInt(partes[2])) - new Date()) / 86400000
    );
    data.push([
      i + 1, row.Nombre, (row.FechaInicio || '').split(' ')[0], row.Servicio, row.Auxiliar,
      row.Estado, row.Operador, row.IMEI, row.Linea, diasRen, fechaRen,
      row.Recarga, (row.FechaRecarga || '').split(' ')[0], row.Instalacion, row.Instalador,
      row.ValorInstalacion, row.PagoInstalacion, row.ValorVenta, row.MetodoPago,
      row.RealizarFactura, row.Manejo, row.IngresoPago, row.Remision, row.FacturaNumero,
      row.Actualizacion, row.Placa, row.Marca, row.Referencia, row.Modelo, row.Cilindraje,
      row.TipoIdentificacion, row.NumeroIdentificacion, row.Telefono, row.Email,
      row.Direccion, row.ComoSeEntero, row.Comercial, row.nombreTercero,
      row.identificacionTercero, row.emailTercero, row.telefonoTercero,
    ]);
  });
  const ws  = XLSX.utils.aoa_to_sheet(data);
  const wb  = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, 'Clientes');
  const fecha = new Date().toLocaleDateString('es-CO').replace(/\//g, '-');
  XLSX.writeFile(wb, `clientes_${fecha}.xlsx`);
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
function getColor(diferenciaDias) {
  if (diferenciaDias <= 30) return 'red';
  if (diferenciaDias <= 90) return 'yellow';
  return 'green';
}

function escHtml(v) {
  if (v == null) return '';
  return String(v).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

