#!/usr/bin/env bash
set -e
echo "[INIT] Generando archivo .env automático..."
mkdir -p config
cat > config/.env <<EOF
AUTHENTIK_ADMIN_EMAIL=admin@local
AUTHENTIK_ADMIN_PASSWORD=$(openssl rand -base64 12)
POSTGRES_PASSWORD=$(openssl rand -base64 12)
COMPOSE_PROJECT_NAME=auto_poc
EOF
echo "[INIT] .env generado:"
cat config/.env
