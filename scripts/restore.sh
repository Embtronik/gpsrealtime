#!/usr/bin/env bash
# =============================================================
# restore.sh  –  Carga un backup .sql en el contenedor MySQL
# =============================================================
# Uso:
#   chmod +x scripts/restore.sh
#
#   # Opción A – carga en caliente (contenedor ya corriendo):
#   ./scripts/restore.sh ruta/al/backup.sql
#
#   # Opción B – carga inicial (primer arranque con volumen limpio):
#   ./scripts/restore.sh ruta/al/backup.sql --fresh
# =============================================================
set -euo pipefail

BACKUP_FILE="${1:-}"
MODE="${2:-}"
CONTAINER="gpsrealtime_db"

# ── Cargar variables del .env ─────────────────────────────────────
if [ -f .env ]; then
  export $(grep -v '^#' .env | grep -v '^$' | xargs)
fi

DB_USER="${DB_USER:-gps}"
DB_PASSWORD="${DB_PASSWORD:-}"
DB_NAME="${DB_NAME:-mydb}"

# ── Validaciones ──────────────────────────────────────────────────
if [ -z "$BACKUP_FILE" ]; then
  echo "Error: debes indicar la ruta del archivo .sql"
  echo "Uso: $0 ruta/backup.sql [--fresh]"
  exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
  echo "Error: no se encuentra el archivo '$BACKUP_FILE'"
  exit 1
fi

echo "Backup: $BACKUP_FILE ($(du -h "$BACKUP_FILE" | cut -f1))"

# ── Modo --fresh: volumen limpio + arranque automático ────────────
if [ "$MODE" = "--fresh" ]; then
  echo ""
  echo "[FRESH] Se eliminará el volumen mysql_data y se reconstruirá."
  read -rp "¿Confirmar? (s/N): " confirm
  if [[ "$confirm" != "s" && "$confirm" != "S" ]]; then
    echo "Cancelado."
    exit 0
  fi

  echo "Copiando backup a docker/mysql/initdb/01_restore.sql..."
  cp "$BACKUP_FILE" docker/mysql/initdb/01_restore.sql

  echo "Bajando contenedores y eliminando volumen..."
  docker compose -f docker-compose.yml down -v

  echo "Reconstruyendo y levantando (puede tardar unos minutos)..."
  docker compose -f docker-compose.yml up -d --build

  echo ""
  echo "Listo. La base está siendo restaurada dentro del contenedor."
  echo "Sigue el progreso con: docker logs -f $CONTAINER"
  exit 0
fi

# ── Modo en caliente: importar directamente al contenedor ─────────
if ! docker inspect "$CONTAINER" > /dev/null 2>&1; then
  echo "Error: el contenedor '$CONTAINER' no está en ejecución."
  echo "Levanta los servicios primero: docker compose up -d"
  exit 1
fi

echo ""
echo "Importando backup en el contenedor en ejecución..."
echo "(esto puede tardar dependiendo del tamaño del backup)"
echo ""

docker exec -i "$CONTAINER" \
  mysql -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$BACKUP_FILE"

echo ""
echo "Restauración completada exitosamente."
echo "Base de datos: $DB_NAME  |  Usuario: $DB_USER"
