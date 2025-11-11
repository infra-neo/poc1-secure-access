#!/usr/bin/env bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load environment variables if available
if [ -f "config/.env" ]; then
    set -a
    source config/.env
    set +a
fi

echo "=========================================="
echo "  PoC Environment Validation"
echo "=========================================="
echo ""

# Track overall status
ALL_CHECKS_PASSED=true

# 1. Check Docker is running
echo -e "${BLUE}[CHECK]${NC} Docker daemon status..."
if docker info &> /dev/null; then
    echo -e "${GREEN}[PASS]${NC} Docker daemon is running"
else
    echo -e "${RED}[FAIL]${NC} Docker daemon is not running"
    ALL_CHECKS_PASSED=false
fi

# 2. Check all containers are running
echo ""
echo -e "${BLUE}[CHECK]${NC} Container status..."
EXPECTED_CONTAINERS=("postgres" "redis" "authentik" "authentik_worker" "jumpserver")

for container in "${EXPECTED_CONTAINERS[@]}"; do
    if docker ps --format '{{.Names}}' | grep -q "poc1_${container}"; then
        STATUS=$(docker inspect --format='{{.State.Status}}' "poc1_${container}" 2>/dev/null)
        if [ "$STATUS" == "running" ]; then
            echo -e "${GREEN}[PASS]${NC} Container poc1_${container} is running"
        else
            echo -e "${RED}[FAIL]${NC} Container poc1_${container} exists but is not running (status: $STATUS)"
            ALL_CHECKS_PASSED=false
        fi
    else
        echo -e "${RED}[FAIL]${NC} Container poc1_${container} not found"
        ALL_CHECKS_PASSED=false
    fi
done

# 3. Check Authentik health endpoint
echo ""
echo -e "${BLUE}[CHECK]${NC} Authentik health endpoint..."
if curl -sf http://localhost:9000/if/flow/initial-setup/ > /dev/null 2>&1; then
    echo -e "${GREEN}[PASS]${NC} Authentik health check successful"
    echo -e "       URL: http://localhost:9000/if/flow/initial-setup/"
else
    echo -e "${RED}[FAIL]${NC} Authentik health check failed"
    echo -e "       Trying alternative health check..."
    if curl -sf -I http://localhost:9000/ > /dev/null 2>&1; then
        echo -e "${YELLOW}[WARN]${NC} Authentik responds but health endpoint not ready"
    else
        echo -e "${RED}[FAIL]${NC} Authentik is not accessible at all"
        ALL_CHECKS_PASSED=false
    fi
fi

# 4. Check JumpServer accessibility
echo ""
echo -e "${BLUE}[CHECK]${NC} JumpServer accessibility..."
if curl -sf -I http://localhost:8080/ > /dev/null 2>&1; then
    echo -e "${GREEN}[PASS]${NC} JumpServer is accessible"
    echo -e "       URL: http://localhost:8080/"
else
    echo -e "${RED}[FAIL]${NC} JumpServer is not accessible at http://localhost:8080"
    ALL_CHECKS_PASSED=false
fi

# 5. Validate ports are open
echo ""
echo -e "${BLUE}[CHECK]${NC} Port availability..."
PORTS=(9000 9443 8080 2222)
PORT_NAMES=("Authentik HTTP" "Authentik HTTPS" "JumpServer HTTP" "JumpServer SSH")

for i in "${!PORTS[@]}"; do
    PORT="${PORTS[$i]}"
    NAME="${PORT_NAMES[$i]}"
    
    if nc -z localhost "$PORT" 2>/dev/null || timeout 1 bash -c "cat < /dev/null > /dev/tcp/localhost/$PORT" 2>/dev/null; then
        echo -e "${GREEN}[PASS]${NC} Port $PORT is open ($NAME)"
    else
        echo -e "${RED}[FAIL]${NC} Port $PORT is not accessible ($NAME)"
        ALL_CHECKS_PASSED=false
    fi
done

# 6. Check PostgreSQL connectivity
echo ""
echo -e "${BLUE}[CHECK]${NC} PostgreSQL database connectivity..."
if docker compose exec -T postgres pg_isready -U authentik &> /dev/null; then
    echo -e "${GREEN}[PASS]${NC} PostgreSQL is accepting connections"
else
    echo -e "${RED}[FAIL]${NC} PostgreSQL is not accepting connections"
    ALL_CHECKS_PASSED=false
fi

# 7. Check Redis connectivity
echo ""
echo -e "${BLUE}[CHECK]${NC} Redis connectivity..."
if [ -n "$REDIS_PASSWORD" ]; then
    if docker compose exec -T redis redis-cli -a "$REDIS_PASSWORD" ping 2>/dev/null | grep -q PONG; then
        echo -e "${GREEN}[PASS]${NC} Redis is responding"
    else
        echo -e "${RED}[FAIL]${NC} Redis is not responding"
        ALL_CHECKS_PASSED=false
    fi
else
    echo -e "${YELLOW}[WARN]${NC} Cannot test Redis - REDIS_PASSWORD not set"
fi

# 8. Display resource usage
echo ""
echo -e "${BLUE}[INFO]${NC} Container resource usage:"
# shellcheck disable=SC2046
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" $(docker ps -q --filter "name=poc1_") 2>/dev/null || echo "No containers running"

# 9. Final summary
echo ""
echo "=========================================="
if [ "$ALL_CHECKS_PASSED" = true ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "Services are ready:"
    echo "  → Authentik:   http://localhost:9000"
    echo "  → JumpServer:  http://localhost:8080"
    exit 0
else
    echo -e "${RED}✗ Some checks failed${NC}"
    echo ""
    echo "Run 'docker compose logs' to see detailed logs"
    exit 1
fi

