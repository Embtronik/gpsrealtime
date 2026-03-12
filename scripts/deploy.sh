#!/usr/bin/env bash
# =============================================================
# deploy.sh  –  Actualiza el servidor y reinicia los servicios
# =============================================================
# Uso (desde /opt/gpsrealtime):
#   chmod +x scripts/deploy.sh
#   ./scripts/deploy.sh               # prod (caddy HTTPS)
#   ./scripts/deploy.sh --dev         # dev  (HTTP directo)
#
# Las migraciones SQL se aplican automáticamente mediante el
# servicio "migrate" definido en docker-compose.yml.
# =============================================================
set -euo pipefail

MODE="${1:-}"

# ── 1. Actualizar código ──────────────────────────────────────
echo ""
echo "=== [1/2] git pull ==="
git pull

# ── 2. Reconstruir y levantar contenedores ────────────────────
echo ""
echo "=== [2/2] docker compose up --build ==="
if [ "$MODE" = "--dev" ]; then
  docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build
else
  docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
fi

echo ""
echo "=================================================="
echo "Despliegue completado."
echo "El servicio 'migrate' aplicará los scripts SQL."
echo "Ver progreso: docker logs -f gpsrealtime_migrate"
echo "=================================================="
