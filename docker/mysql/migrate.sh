#!/bin/sh
# =============================================================
# migrate.sh – Aplica todos los scripts SQL de migración
# Se ejecuta en cada "docker compose up" mediante el servicio
# "migrate". Omite 01_restore.sql (volcado inicial completo).
# Todos los demás scripts deben ser idempotentes:
#   DROP PROCEDURE IF EXISTS / INSERT IGNORE / etc.
# =============================================================
set -e

MIGRATIONS_DIR="/migrations"
DB_HOST="db"

echo ""
echo "=== Migraciones SQL ==="

# Ordenar y aplicar todos los .sql excepto 01_restore.sql
for FILE in $(ls "$MIGRATIONS_DIR"/*.sql 2>/dev/null | sort); do
  BASENAME=$(basename "$FILE")
  case "$BASENAME" in
    01_*) echo "  [SKIP] $BASENAME (volcado inicial, solo en volumen vacío)" ; continue ;;
  esac

  echo "  Aplicando: $BASENAME ..."
  mysql -h "$DB_HOST" \
        -u root \
        -p"${MYSQL_ROOT_PASSWORD}" \
        "${DB_NAME:-mydb}" < "$FILE"
  echo "  ✓ $BASENAME"
done

echo "=== Migraciones completadas ==="
echo ""

# ── Verificación: todos los SPs esperados deben existir ──────────
echo "=== Verificando Stored Procedures ==="

EXPECTED_SPS="sp_validar_credenciales
insertar_usuario
SP_ListarUsuariosAcceso
SP_CambiarPasswordUsuario
SP_EliminarUsuarioLogico
sp_insert_p_comercial
sp_read_p_comercial
sp_update_p_comercial
sp_insert_p_comoseentero
sp_read_p_comoseentero
sp_update_p_comoseentero
sp_insert_p_metodopago
sp_read_p_metodopago
sp_update_p_metodopago
sp_insert_p_servicios
sp_read_p_servicios
sp_update_p_servicios
SP_consultarTipoServicio
obtener_estadoServicio
obtener_usuarios_empresa
obtener_clientes_Por_Usuario
consulta_buscarClientes
SP_consultarClienteEditar
insertar_actualizar_datosDelServicio
sp_ActualizarServicio
sp_ActualizarVehiculo
sp_ActualizarUsuario
SP_ActualizarDatosProceso
SP_InsertarTareaCliente
SP_BuscarTareasPorClienteYServicio
SP_ActualizarTareaCliente
SP_EliminarTareaCliente
sp_InsertarTercero
sp_ActualizarTercero
sp_DesactivarTercero
sp_BuscarTerceroPorIDs
sp_delete_servicioparausuario"

MISSING=0
for SP in $EXPECTED_SPS; do
  EXISTS=$(mysql -h "$DB_HOST" -u root -p"${MYSQL_ROOT_PASSWORD}" \
    "${DB_NAME:-mydb}" --skip-column-names -e \
    "SELECT COUNT(*) FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA='${DB_NAME:-mydb}' AND ROUTINE_NAME='$SP';" 2>/dev/null)
  if [ "$EXISTS" = "1" ]; then
    echo "  ✓ $SP"
  else
    echo "  ✗ FALTA: $SP"
    MISSING=$((MISSING + 1))
  fi
done

echo ""
if [ "$MISSING" -eq 0 ]; then
  echo "=== Todos los SPs verificados correctamente (37/37) ==="
else
  echo "=== ADVERTENCIA: $MISSING SP(s) no se crearon correctamente ==="
  exit 1
fi
echo ""
