#!/usr/bin/env bash
# =============================================================
# deploy.sh  –  Actualiza el servidor y aplica migraciones SQL
# =============================================================
# Uso (desde /opt/gpsrealtime):
#   chmod +x scripts/deploy.sh
#   ./scripts/deploy.sh               # prod (caddy HTTPS)
#   ./scripts/deploy.sh --dev         # dev  (HTTP directo)
# =============================================================
set -euo pipefail

MODE="${1:-}"
CONTAINER_DB="gpsrealtime_db"
CONTAINER_APP="gpsrealtime_app"

# ── Cargar variables del .env ─────────────────────────────────
if [ -f .env ]; then
  export $(grep -v '^#' .env | grep -v '^$' | xargs)
fi

MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-}"
DB_NAME="${DB_NAME:-mydb}"

# ── 1. Actualizar código ──────────────────────────────────────
echo ""
echo "=== [1/4] git pull ==="
git pull

# ── 2. Reconstruir y levantar contenedores ────────────────────
echo ""
echo "=== [2/4] docker compose up --build ==="
if [ "$MODE" = "--dev" ]; then
  docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build
else
  docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
fi

# ── 3. Esperar a que MySQL esté listo ─────────────────────────
echo ""
echo "=== [3/4] Esperando MySQL... ==="
RETRIES=30
until docker exec "$CONTAINER_DB" mysqladmin ping -u root -p"$MYSQL_ROOT_PASSWORD" --silent 2>/dev/null; do
  RETRIES=$((RETRIES - 1))
  if [ "$RETRIES" -le 0 ]; then
    echo "Error: MySQL no respondió a tiempo."
    exit 1
  fi
  echo "  ... esperando ($RETRIES intentos restantes)"
  sleep 2
done
echo "MySQL listo."

# ── 4. Aplicar migraciones SQL ────────────────────────────────
echo ""
echo "=== [4/4] Aplicando migraciones SQL ==="

# Lista ordenada de scripts a aplicar en cada deploy.
# Deben ser idempotentes (DROP IF EXISTS / CREATE OR REPLACE / INSERT IGNORE).
MIGRATION_FILES=(
  "docker/mysql/initdb/02_supervisor_role.sql"
  "docker/mysql/initdb/03_security_migration.sql"
  "docker/mysql/initdb/04_stored_procedures.sql"
)

for FILE in "${MIGRATION_FILES[@]}"; do
  if [ -f "$FILE" ]; then
    echo "  Aplicando: $FILE"
    docker exec -i "$CONTAINER_DB" \
      mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$DB_NAME" < "$FILE"
    echo "  ✓ $FILE"
  else
    echo "  [SKIP] No encontrado: $FILE"
  fi
done

echo ""
echo "==================================================="
echo "Despliegue completado exitosamente."
echo "  App:  $CONTAINER_APP"
echo "  Base: $DB_NAME en $CONTAINER_DB"
echo "==================================================="
