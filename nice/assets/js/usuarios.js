'use strict';

// ──────────────────────────────────────────────
// usuarios.js — Gestión de usuarios (solo admin)
// ──────────────────────────────────────────────

const API_LISTAR     = '../codigo/apiListarUsuarios.php';
const API_PASSWORD   = '../codigo/apiCambiarPassword.php';
const API_DESACTIVAR = '../codigo/apiEliminarUsuarioLogico.php';

// ── Bootstrap modal instances ──────────────────
let modalPassword, modalDesactivar;

document.addEventListener('DOMContentLoaded', () => {
  modalPassword  = new bootstrap.Modal(document.getElementById('modalPassword'));
  modalDesactivar = new bootstrap.Modal(document.getElementById('modalDesactivar'));

  document.getElementById('btnGuardarPassword').addEventListener('click', guardarPassword);
  document.getElementById('btnConfirmarDesactivar').addEventListener('click', confirmarDesactivar);

  cargarUsuarios();
});

// ── Carga y renderiza la tabla ─────────────────
async function cargarUsuarios() {
  const tbody = document.getElementById('tbodyUsuarios');
  tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted py-4">Cargando...</td></tr>';

  try {
    const resp = await fetch(API_LISTAR);
    const json = await resp.json();
    if (!json.success) throw new Error(json.message || 'Error al obtener usuarios.');

    if (!json.data || json.data.length === 0) {
      tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted py-4">No hay usuarios activos.</td></tr>';
      return;
    }

    tbody.innerHTML = '';
    json.data.forEach(u => {
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>${escHtml(u.nombre)}</td>
        <td>${escHtml(u.username)}</td>
        <td>${escHtml(u.email ?? '')}</td>
        <td><span class="badge bg-secondary">${escHtml(u.rol_nombre ?? '—')}</span></td>
        <td>${escHtml(u.fechaRegistro ?? '')}</td>
        <td class="text-center">
          <button class="btn btn-sm btn-outline-primary me-1"
                  data-cred-id="${u.idusuarioCredenciales}"
                  data-username="${escHtml(u.username)}"
                  onclick="abrirModalPassword(this)">
            <i class="bi bi-key"></i> Contraseña
          </button>
          <button class="btn btn-sm btn-outline-danger"
                  data-cred-id="${u.idusuarioCredenciales}"
                  data-username="${escHtml(u.username)}"
                  onclick="abrirModalDesactivar(this)">
            <i class="bi bi-person-x"></i> Desactivar
          </button>
        </td>`;
      tbody.appendChild(tr);
    });
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="6" class="text-center text-danger py-4">${escHtml(err.message)}</td></tr>`;
  }
}

// ── Abre modal de cambio de contraseña ────────
function abrirModalPassword(btn) {
  const credId   = btn.dataset.credId;
  const username = btn.dataset.username;

  document.getElementById('modalCredId').value          = credId;
  document.getElementById('modalPasswordUsername').textContent = username;
  document.getElementById('inputNewPassword').value     = '';
  document.getElementById('inputConfirmPassword').value = '';
  ocultarErrorPassword();

  modalPassword.show();
}

// ── Guarda la nueva contraseña ─────────────────
async function guardarPassword() {
  ocultarErrorPassword();

  const credId   = parseInt(document.getElementById('modalCredId').value, 10);
  const pass1    = document.getElementById('inputNewPassword').value;
  const pass2    = document.getElementById('inputConfirmPassword').value;

  if (pass1.length < 8 || pass1.length > 72) {
    mostrarErrorPassword('La contraseña debe tener entre 8 y 72 caracteres.');
    return;
  }
  if (pass1 !== pass2) {
    mostrarErrorPassword('Las contraseñas no coinciden.');
    return;
  }

  const btn = document.getElementById('btnGuardarPassword');
  btn.disabled = true;
  btn.textContent = 'Guardando...';

  try {
    const resp = await fetch(API_PASSWORD, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ idusuarioCredenciales: credId, password: pass1 })
    });
    const json = await resp.json();

    if (!json.success) throw new Error(json.message || 'Error al cambiar contraseña.');

    modalPassword.hide();
    mostrarAlerta('success', json.message || 'Contraseña actualizada correctamente.');
  } catch (err) {
    mostrarErrorPassword(err.message);
  } finally {
    btn.disabled = false;
    btn.textContent = 'Guardar';
  }
}

// ── Abre modal de desactivación ───────────────
function abrirModalDesactivar(btn) {
  const credId   = btn.dataset.credId;
  const username = btn.dataset.username;

  document.getElementById('modalDesactivarCredId').value = credId;
  document.getElementById('modalDesactivarUsername').textContent = username;
  modalDesactivar.show();
}

// ── Confirma desactivación lógica ─────────────
async function confirmarDesactivar() {
  const credId = parseInt(document.getElementById('modalDesactivarCredId').value, 10);

  const btn = document.getElementById('btnConfirmarDesactivar');
  btn.disabled = true;
  btn.textContent = 'Desactivando...';

  try {
    const resp = await fetch(API_DESACTIVAR, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ idusuarioCredenciales: credId })
    });
    const json = await resp.json();
    if (!json.success) throw new Error(json.message || 'Error al desactivar usuario.');

    modalDesactivar.hide();
    mostrarAlerta('success', json.message || 'Usuario desactivado correctamente.');
    await cargarUsuarios();
  } catch (err) {
    modalDesactivar.hide();
    mostrarAlerta('danger', err.message);
  } finally {
    btn.disabled = false;
    btn.textContent = 'Desactivar';
  }
}

// ── Helpers ────────────────────────────────────
function mostrarAlerta(tipo, mensaje) {
  const box = document.getElementById('alertBox');
  box.className = `alert alert-${tipo}`;
  box.textContent = mensaje;
  box.classList.remove('d-none');
  setTimeout(() => box.classList.add('d-none'), 5000);
}

function mostrarErrorPassword(msg) {
  const el = document.getElementById('passwordError');
  el.textContent = msg;
  el.classList.remove('d-none');
}

function ocultarErrorPassword() {
  const el = document.getElementById('passwordError');
  el.textContent = '';
  el.classList.add('d-none');
}

function escHtml(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}
