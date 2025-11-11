#!/usr/bin/env bash
set -e

echo "=================================="
echo "PoC1 - Environment Initialization"
echo "=================================="

# Detect workspace (PoC1 or PoC2)
WORKSPACE_NAME="poc1-secure-access"
if [[ "$PWD" == *"poc2-audit-access"* ]]; then
    WORKSPACE_NAME="poc2-audit-access"
fi
echo "[INIT] Detected workspace: $WORKSPACE_NAME"

# Create config directory if it doesn't exist
mkdir -p config

# Detect HOST_IP
HOST_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "127.0.0.1")
echo "[INIT] Detected HOST_IP: $HOST_IP"

# Generate secure random passwords
echo "[INIT] Generating secure random passwords..."
AUTHENTIK_SECRET_KEY=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-50)
AUTHENTIK_ADMIN_PASSWORD=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-20)
POSTGRES_PASSWORD=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-20)
AUTH_CLIENT_SECRET=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-40)
REDIS_PASSWORD=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-20)
LDAP_BIND_PW=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-20)
JUMPSERVER_SECRET_KEY=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-50)

# Generate AUTH_CLIENT_ID with timestamp
TIMESTAMP=$(date +%s)
AUTH_CLIENT_ID="${WORKSPACE_NAME}_${TIMESTAMP}"

echo "[INIT] Creating .env file..."
cat > config/.env <<EOF
# PoC1 - Authentik + JumpServer Configuration
# Auto-generated on $(date)

# Project Configuration
COMPOSE_PROJECT_NAME=poc1_secure_access
HOST_IP=${HOST_IP}

# Authentication Service (Authentik)
AUTHENTIK_SECRET_KEY=${AUTHENTIK_SECRET_KEY}
AUTHENTIK_ADMIN_EMAIL=admin@local
AUTHENTIK_ADMIN_PASSWORD=${AUTHENTIK_ADMIN_PASSWORD}
AUTHENTIK_POSTGRESQL__HOST=postgres
AUTHENTIK_POSTGRESQL__USER=authentik
AUTHENTIK_POSTGRESQL__NAME=authentik
AUTHENTIK_POSTGRESQL__PASSWORD=${POSTGRES_PASSWORD}

# OAuth/OIDC Configuration
AUTH_CLIENT_ID=${AUTH_CLIENT_ID}
AUTH_CLIENT_SECRET=${AUTH_CLIENT_SECRET}

# JumpServer Configuration
JUMPSERVER_DB_PASSWORD=${POSTGRES_PASSWORD}
JUMPSERVER_BOOTSTRAP_USER=admin
JUMPSERVER_BOOTSTRAP_PASSWORD=${AUTHENTIK_ADMIN_PASSWORD}
JUMPSERVER_SECRET_KEY=${JUMPSERVER_SECRET_KEY}

# Database Configuration
POSTGRES_DB=authentik
POSTGRES_USER=authentik
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}

# Redis Configuration
REDIS_PASSWORD=${REDIS_PASSWORD}

# LDAP Configuration
LDAP_BIND_DN=cn=admin,dc=example,dc=org
LDAP_BIND_PW=${LDAP_BIND_PW}
EOF

echo "[INIT] ✓ .env file generated successfully at config/.env"
echo "[INIT] Generated credentials:"
echo "  - AUTH_CLIENT_ID: ${AUTH_CLIENT_ID}"
echo "  - Passwords: [GENERATED - See config/.env]"
echo "  - HOST_IP: ${HOST_IP}"
echo ""
echo "[INIT] Complete! Environment file is ready."
