/**
 * inspecciones.js
 * Panel supervisor: lista y detalle de inspecciones realizadas por técnicos.
 */

document.addEventListener('DOMContentLoaded', function () {

  const form      = document.getElementById('formBuscarInspeccion');
  const btnLimpiar = document.getElementById('btnLimpiar');

  form.addEventListener('submit', (e) => {
    e.preventDefault();
    buscarInspecciones();
  });

  btnLimpiar.addEventListener('click', () => {
    form.reset();
    document.getElementById('bodyInspecciones').innerHTML =
      '<tr><td colspan="8" class="text-center text-muted">Use los filtros para buscar inspecciones.</td></tr>';
  });
});

// ─── Buscar inspecciones ──────────────────────────────────────────────────────
async function buscarInspecciones() {
  const placa   = document.getElementById('filtroPlaca').value.trim();
  const tecnico = document.getElementById('filtroTecnico').value.trim();
  const nombre  = document.getElementById('filtroNombre').value.trim();
  const desde   = document.getElementById('filtroDesde').value;
  const hasta   = document.getElementById('filtroHasta').value;

  const tbody = document.getElementById('bodyInspecciones');
  tbody.innerHTML = '<tr><td colspan="8" class="text-center"><div class="spinner-border spinner-border-sm text-primary me-2"></div> Cargando...</td></tr>';

  try {
    const resp = await fetch('../codigo/apiGetInspecciones.php', {
      method: 'POST',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ placa, tecnico, nombre, desde, hasta }),
    });

    if (!resp.ok) {
      if (resp.status === 401) { window.location.href = '../index.html'; return; }
      throw new Error('Error del servidor (' + resp.status + ')');
    }

    const data = await resp.json();
    if (!data.success) throw new Error(data.message || 'Error desconocido');

    renderInspecciones(data.data);
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="8" class="text-danger text-center">${escHtml(err.message)}</td></tr>`;
  }
}

// ─── Renderizar tabla ─────────────────────────────────────────────────────────
function renderInspecciones(rows) {
  const tbody = document.getElementById('bodyInspecciones');

  if (!rows || rows.length === 0) {
    tbody.innerHTML = '<tr><td colspan="8" class="text-center text-muted">Sin resultados para los filtros aplicados.</td></tr>';
    return;
  }

  tbody.innerHTML = '';
  rows.forEach((row, idx) => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>${idx + 1}</td>
      <td>${escHtml(row.fecha)}</td>
      <td>${escHtml(row.tecnico || '-')}</td>
      <td><strong>${escHtml(row.placa)}</strong></td>
      <td>${escHtml(row.nombre_cliente || '-')}</td>
      <td>${escHtml(row.telefono_cliente || '-')}</td>
      <td><span class="badge bg-secondary">${row.total_items}</span></td>
      <td>
        <button class="btn btn-sm btn-primary" onclick="verDetalle(${Number(row.id)})">
          <i class="bi bi-eye-fill me-1"></i>Ver
        </button>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

// ─── Ver detalle de una inspección ───────────────────────────────────────────
async function verDetalle(id) {
  const modalBody  = document.getElementById('modalDetalleBody');
  const modalLabel = document.getElementById('modalDetalleLabel');

  modalBody.innerHTML  = '<div class="text-center py-4"><div class="spinner-border text-primary" role="status"></div></div>';
  modalLabel.textContent = 'Cargando inspección…';

  const modal = new bootstrap.Modal(document.getElementById('modalDetalle'));
  modal.show();

  try {
    const resp = await fetch('../codigo/apiGetInspeccionDetalle.php', {
      method: 'POST',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id }),
    });

    if (!resp.ok) throw new Error('Error del servidor (' + resp.status + ')');
    const data = await resp.json();
    if (!data.success) throw new Error(data.message || 'Error desconocido');

    renderDetalle(data, modalLabel, modalBody);
  } catch (err) {
    modalBody.innerHTML = `<div class="alert alert-danger">${escHtml(err.message)}</div>`;
  }
}

// ─── Renderizar detalle en el modal ──────────────────────────────────────────
function renderDetalle(data, labelEl, bodyEl) {
  const h = data.header;
  labelEl.textContent = `Inspección #${h.id}  ·  Placa: ${h.placa}`;

  // Agrupar ítems por categoría
  const categorias = {};
  data.items.forEach(it => {
    const cat = it.categoria_nombre || 'General';
    if (!categorias[cat]) categorias[cat] = [];
    categorias[cat].push(it);
  });

  let html = `
    <div class="row g-2 mb-3 border-bottom pb-3">
      <div class="col-md-4"><i class="bi bi-calendar3 me-1 text-primary"></i><strong>Fecha:</strong> ${escHtml(h.fecha)}</div>
      <div class="col-md-4"><i class="bi bi-person-badge me-1 text-primary"></i><strong>Técnico:</strong> ${escHtml(h.tecnico || '-')}</div>
      <div class="col-md-4"><i class="bi bi-car-front me-1 text-primary"></i><strong>Placa:</strong> <strong class="text-primary">${escHtml(h.placa)}</strong></div>
      <div class="col-md-4"><i class="bi bi-person me-1 text-secondary"></i><strong>Cliente:</strong> ${escHtml(h.nombre_cliente || '-')}</div>
      <div class="col-md-4"><i class="bi bi-telephone me-1 text-secondary"></i><strong>Teléfono:</strong> ${escHtml(h.telefono_cliente || '-')}</div>
      <div class="col-md-4"><i class="bi bi-envelope me-1 text-secondary"></i><strong>Email:</strong> ${escHtml(h.email_cliente || '-')}</div>
      ${h.novedades ? `<div class="col-12"><i class="bi bi-info-circle me-1 text-warning"></i><strong>Novedades:</strong> ${escHtml(h.novedades)}</div>` : ''}
    </div>
  `;

  if (data.items.length === 0) {
    html += '<p class="text-muted text-center py-3"><i class="bi bi-inbox fs-4 d-block mb-2"></i>Sin ítems registrados en esta inspección.</p>';
  } else {
    Object.entries(categorias).forEach(([catNombre, items]) => {
      html += `
        <h6 class="fw-bold text-primary mt-3 border-start border-primary border-3 ps-2">${escHtml(catNombre)}</h6>
        <table class="table table-sm table-bordered mb-3">
          <thead class="table-light">
            <tr>
              <th style="width:45%">Ítem</th>
              <th style="width:15%">Estado</th>
              <th>Observaciones</th>
            </tr>
          </thead>
          <tbody>
      `;
      items.forEach(it => {
        html += `
          <tr>
            <td>${escHtml(it.item_nombre)}</td>
            <td><span class="badge badge-${escHtml(it.estado)} px-2 py-1">${escHtml(it.estado)}</span></td>
            <td class="text-muted small">${escHtml(it.observaciones || '')}</td>
          </tr>
        `;
      });
      html += '</tbody></table>';
    });
  }

  bodyEl.innerHTML = html;
}

// ─── Helper: escape HTML para evitar XSS al insertar datos del servidor ──────
function escHtml(str) {
  if (str == null) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}
