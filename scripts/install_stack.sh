#!/usr/bin/env bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log file
LOG_FILE="/tmp/install_poc.log"
: > "$LOG_FILE"  # Clear log file

log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${YELLOW}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log ""
log "=========================================="
log "  PoC Stack Installation Script"
log "=========================================="
log ""

# 1. Detect PoC type
WORKSPACE_NAME="poc1-secure-access"
POC_TYPE="PoC1"

if [[ "$PWD" == *"poc2-audit-access"* ]]; then
    WORKSPACE_NAME="poc2-audit-access"
    POC_TYPE="PoC2"
fi

log_info "Detected: $POC_TYPE ($WORKSPACE_NAME)"

# 2. Check dependencies
log_info "Checking dependencies..."

if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed. Please install Docker first."
    exit 1
fi
log_success "Docker found: $(docker --version)"

if ! docker compose version &> /dev/null; then
    log_error "Docker Compose is not available. Please install Docker Compose plugin."
    exit 1
fi
log_success "Docker Compose found: $(docker compose version)"

# 3. Load environment variables
if [ ! -f "config/.env" ]; then
    log_error ".env file not found. Run 'bash scripts/init_env.sh' first."
    exit 1
fi
log_success "Environment file found: config/.env"

# 4. Source the environment file
set -a
source config/.env
set +a

# 5. Install and configure based on PoC type
if [ "$POC_TYPE" == "PoC1" ]; then
    log_info "Installing PoC1 stack: Authentik + JumpServer + PostgreSQL + Redis"
    
    log_info "Stopping any existing containers..."
    docker compose down --remove-orphans 2>&1 | tee -a "$LOG_FILE" || true
    
    log_info "Pulling latest images..."
    docker compose pull 2>&1 | tee -a "$LOG_FILE"
    
    log_info "Starting services..."
    docker compose up -d 2>&1 | tee -a "$LOG_FILE"
    
    log_info "Waiting for services to be healthy..."
    sleep 10
    
    # Wait for PostgreSQL
    log_info "Waiting for PostgreSQL to be ready..."
    for i in {1..30}; do
        if docker compose exec -T postgres pg_isready -U authentik &> /dev/null; then
            log_success "PostgreSQL is ready"
            break
        fi
        if [ "$i" -eq 30 ]; then
            log_error "PostgreSQL failed to start"
            docker compose logs postgres | tail -20 | tee -a "$LOG_FILE"
            exit 1
        fi
        sleep 2
    done
    
    # Wait for Redis
    log_info "Waiting for Redis to be ready..."
    for i in {1..30}; do
        if docker compose exec -T redis redis-cli -a "$REDIS_PASSWORD" ping &> /dev/null; then
            log_success "Redis is ready"
            break
        fi
        if [ "$i" -eq 30 ]; then
            log_error "Redis failed to start"
            docker compose logs redis | tail -20 | tee -a "$LOG_FILE"
            exit 1
        fi
        sleep 2
    done
    
    # Wait for Authentik
    log_info "Waiting for Authentik to be ready (this may take a minute)..."
    for i in {1..60}; do
        if curl -sf http://localhost:9000/if/flow/initial-setup/ &> /dev/null; then
            log_success "Authentik is ready"
            break
        fi
        if [ "$i" -eq 60 ]; then
            log_error "Authentik failed to start properly"
            docker compose logs authentik | tail -30 | tee -a "$LOG_FILE"
            exit 1
        fi
        sleep 3
    done
    
    # Wait for JumpServer
    log_info "Waiting for JumpServer to be ready..."
    for i in {1..60}; do
        if curl -sf http://localhost:8080/ &> /dev/null; then
            log_success "JumpServer is ready"
            break
        fi
        if [ "$i" -eq 60 ]; then
            log_error "JumpServer failed to start properly"
            docker compose logs jumpserver | tail -30 | tee -a "$LOG_FILE"
            exit 1
        fi
        sleep 3
    done
    
elif [ "$POC_TYPE" == "PoC2" ]; then
    log_info "Installing PoC2 stack: Authentik + KasmWeb + OpenLDAP + PostgreSQL"
    log_error "PoC2 installation not implemented yet"
    exit 1
fi

# 6. Validate services
log ""
log_info "Validating service accessibility..."

SERVICES_OK=true

# Check Authentik
if curl -sf http://localhost:9000/if/flow/initial-setup/ &> /dev/null; then
    log_success "✓ Authentik is accessible at http://localhost:9000"
else
    log_error "✗ Authentik is not accessible at http://localhost:9000"
    SERVICES_OK=false
fi

# Check JumpServer (PoC1)
if [ "$POC_TYPE" == "PoC1" ]; then
    if curl -sf http://localhost:8080/ &> /dev/null; then
        log_success "✓ JumpServer is accessible at http://localhost:8080"
    else
        log_error "✗ JumpServer is not accessible at http://localhost:8080"
        SERVICES_OK=false
    fi
fi

# 7. Display container status
log ""
log_info "Container status:"
docker compose ps 2>&1 | tee -a "$LOG_FILE"

# 8. Final summary
log ""
log "=========================================="
if [ "$SERVICES_OK" = true ]; then
    log_success "Installation completed successfully!"
    log ""
    log "Access your services:"
    log "  - Authentik: http://localhost:9000"
    if [ "$POC_TYPE" == "PoC1" ]; then
        log "  - JumpServer: http://localhost:8080"
    fi
    log ""
    log "Credentials are stored in: config/.env"
    log "Installation logs: $LOG_FILE"
    exit 0
else
    log_error "Installation completed with errors. Check logs for details."
    log_error "Log file: $LOG_FILE"
    exit 1
fi
