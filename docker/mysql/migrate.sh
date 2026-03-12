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
