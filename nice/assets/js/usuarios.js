'use strict';

// ──────────────────────────────────────────────
// usuarios.js — Gestión de usuarios (solo admin)
// ──────────────────────────────────────────────

const API_LISTAR     = '../codigo/apiListarUsuarios.php';
const API_ACTUALIZAR = '../codigo/apiActualizarUsuario.php';
const API_DESACTIVAR = '../codigo/apiEliminarUsuarioLogico.php';
const API_ROLES      = '../codigo/apirol.php';

let modalEditar, modalDesactivar;
let rolesMap = {};                    // { "3": "Auxiliar", ... } — excluye rol 2
const usuariosCache = new Map();      // idusuarioCredenciales → objeto usuario

document.addEventListener('DOMContentLoaded', async () => {
  modalEditar     = new bootstrap.Modal(document.getElementById('modalEditar'));
  modalDesactivar = new bootstrap.Modal(document.getElementById('modalDesactivar'));

  document.getElementById('btnGuardarEdicion').addEventListener('click', guardarEdicion);
  document.getElementById('btnConfirmarDesactivar').addEventListener('click', confirmarDesactivar);

  await cargarRoles();
  await cargarUsuarios();
});

// ── Carga roles disponibles (excluye Cliente = 2) ──────────
async function cargarRoles() {
  try {
    const resp = await fetch(API_ROLES);
    const json = await resp.json();
    rolesMap = {};
    Object.entries(json).forEach(([id, nombre]) => {
      if (parseInt(id, 10) !== 2) rolesMap[id] = nombre;
    });
  } catch { /* silencioso */ }
}

// ── Carga y renderiza la tabla de usuarios ─────────────────
async function cargarUsuarios() {
  const tbody = document.getElementById('tbodyUsuarios');
  tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted py-4">Cargando...</td></tr>';
  usuariosCache.clear();

  try {
    const resp = await fetch(API_LISTAR);
    const json = await resp.json();
    if (!json.success) throw new Error(json.message || 'Error al obtener usuarios.');

    // Filtro defensivo en cliente: excluir rol 2 (ya filtrado en el SP)
    const lista = (json.data || []).filter(u => parseInt(u.id_rol, 10) !== 2);

    if (lista.length === 0) {
      tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted py-4">No hay usuarios activos.</td></tr>';
      return;
    }

    tbody.innerHTML = '';
    lista.forEach(u => {
      usuariosCache.set(u.idusuarioCredenciales, u);

      const esAdmin = parseInt(u.id_rol, 10) === 1;
      const acciones = esAdmin
        ? '<span class="text-muted small fst-italic">Protegido</span>'
        : `<button class="btn btn-sm btn-outline-primary me-1"
                   onclick="abrirModalEditar(${u.idusuarioCredenciales})">
             <i class="bi bi-pencil"></i> Editar
           </button>
           <button class="btn btn-sm btn-outline-danger"
                   onclick="abrirModalDesactivar(${u.idusuarioCredenciales})">
             <i class="bi bi-person-x"></i> Desactivar
           </button>`;

      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>${escHtml(u.nombre)}</td>
        <td>${escHtml(u.username)}</td>
        <td>${escHtml(u.email ?? '')}</td>
        <td><span class="badge bg-secondary">${escHtml(u.rol_nombre ?? '—')}</span></td>
        <td>${escHtml(u.fechaRegistro ?? '')}</td>
        <td class="text-center">${acciones}</td>`;
      tbody.appendChild(tr);
    });
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="6" class="text-center text-danger py-4">${escHtml(err.message)}</td></tr>`;
  }
}

// ── Abre modal de edición completa ─────────────────────────
function abrirModalEditar(credId) {
  const u = usuariosCache.get(credId);
  if (!u) return;

  document.getElementById('editarIdUsuario').value        = u.idusuario;
  document.getElementById('editarIdCredencial').value     = u.idusuarioCredenciales;
  document.getElementById('editarNombre').value           = u.nombre;
  document.getElementById('editarEmail').value            = u.email ?? '';
  document.getElementById('editarUsernameLabel').textContent = u.username;
  document.getElementById('editarNuevaPassword').value    = '';
  document.getElementById('editarConfirmPassword').value  = '';
  ocultarErrorEditar();

  // Rellenar select de roles (excluye Cliente = 2)
  const sel = document.getElementById('editarRolSelect');
  sel.innerHTML = '';
  Object.entries(rolesMap).forEach(([id, nombre]) => {
    const opt = document.createElement('option');
    opt.value = id;
    opt.textContent = nombre;
    if (String(id) === String(u.id_rol)) opt.selected = true;
    sel.appendChild(opt);
  });

  modalEditar.show();
}

// ── Guarda la edición del usuario ─────────────────────────
async function guardarEdicion() {
  ocultarErrorEditar();

  const idusuario             = parseInt(document.getElementById('editarIdUsuario').value, 10);
  const idusuarioCredenciales = parseInt(document.getElementById('editarIdCredencial').value, 10);
  const nombre                = document.getElementById('editarNombre').value.trim();
  const email                 = document.getElementById('editarEmail').value.trim();
  const id_rol                = parseInt(document.getElementById('editarRolSelect').value, 10);
  const pass1                 = document.getElementById('editarNuevaPassword').value;
  const pass2                 = document.getElementById('editarConfirmPassword').value;

  if (!nombre) {
    mostrarErrorEditar('El nombre no puede estar vacío.');
    return;
  }
  if (pass1 !== '' && (pass1.length < 8 || pass1.length > 72)) {
    mostrarErrorEditar('La contraseña debe tener entre 8 y 72 caracteres.');
    return;
  }
  if (pass1 !== pass2) {
    mostrarErrorEditar('Las contraseñas no coinciden.');
    return;
  }

  const payload = { idusuario, idusuarioCredenciales, nombre, email, id_rol };
  if (pass1 !== '') payload.password = pass1;

  const btn = document.getElementById('btnGuardarEdicion');
  btn.disabled = true;
  btn.textContent = 'Guardando...';

  try {
    const resp = await fetch(API_ACTUALIZAR, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    const json = await resp.json();
    if (!json.success) throw new Error(json.message || 'Error al actualizar usuario.');

    modalEditar.hide();
    mostrarAlerta('success', json.message || 'Usuario actualizado correctamente.');
    await cargarUsuarios();
  } catch (err) {
    mostrarErrorEditar(err.message);
  } finally {
    btn.disabled = false;
    btn.textContent = 'Guardar';
  }
}

// ── Abre modal de desactivación ────────────────────────────
function abrirModalDesactivar(credId) {
  const u = usuariosCache.get(credId);
  if (!u) return;

  document.getElementById('modalDesactivarCredId').value         = credId;
  document.getElementById('modalDesactivarUsername').textContent = u.username;
  modalDesactivar.show();
}

// ── Confirma desactivación lógica ─────────────────────────
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

// ── Helpers ────────────────────────────────────────────────
function mostrarAlerta(tipo, mensaje) {
  const box = document.getElementById('alertBox');
  box.className = `alert alert-${tipo}`;
  box.textContent = mensaje;
  box.classList.remove('d-none');
  setTimeout(() => box.classList.add('d-none'), 5000);
}

function mostrarErrorEditar(msg) {
  const el = document.getElementById('editarError');
  el.textContent = msg;
  el.classList.remove('d-none');
}

function ocultarErrorEditar() {
  const el = document.getElementById('editarError');
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
