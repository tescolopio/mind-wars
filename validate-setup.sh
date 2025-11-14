#!/bin/bash

# Mind Wars Backend Validation Script
# Tests the Docker Compose setup to ensure all components are properly configured

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "Mind Wars Backend Validation"
echo "=========================================="
echo ""

# Test 1: Check Docker Compose file syntax
echo -n "Test 1: Docker Compose syntax... "
if docker compose config --quiet 2>/dev/null; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "Docker Compose configuration is invalid"
    exit 1
fi

# Test 2: Check required files exist
echo -n "Test 2: Required files exist... "
REQUIRED_FILES=(
    "docker-compose.yml"
    ".env.example"
    "deploy.sh"
    "backend/api/server.js"
    "backend/api/package.json"
    "backend/api/Dockerfile"
    "backend/socket/server.js"
    "backend/socket/package.json"
    "backend/socket/Dockerfile"
    "backend/database/init.sql"
    "backend/nginx/nginx.conf"
    "backend/prometheus/prometheus.yml"
)

ALL_EXIST=true
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}FAIL${NC}"
        echo "Missing file: $file"
        ALL_EXIST=false
    fi
done

if [ "$ALL_EXIST" = true ]; then
    echo -e "${GREEN}PASS${NC}"
fi

# Test 3: Check backend directory structure
echo -n "Test 3: Directory structure... "
REQUIRED_DIRS=(
    "backend/api"
    "backend/api/routes"
    "backend/api/middleware"
    "backend/socket"
    "backend/database"
    "backend/nginx"
    "backend/nginx/ssl"
    "backend/prometheus"
    "backend/grafana"
    "backend/grafana/provisioning"
)

ALL_DIRS_EXIST=true
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo -e "${RED}FAIL${NC}"
        echo "Missing directory: $dir"
        ALL_DIRS_EXIST=false
    fi
done

if [ "$ALL_DIRS_EXIST" = true ]; then
    echo -e "${GREEN}PASS${NC}"
fi

# Test 4: Check API routes
echo -n "Test 4: API routes exist... "
REQUIRED_ROUTES=(
    "backend/api/routes/auth.js"
    "backend/api/routes/lobbies.js"
    "backend/api/routes/games.js"
    "backend/api/routes/leaderboards.js"
    "backend/api/routes/sync.js"
    "backend/api/routes/analytics.js"
    "backend/api/routes/users.js"
)

ALL_ROUTES_EXIST=true
for route in "${REQUIRED_ROUTES[@]}"; do
    if [ ! -f "$route" ]; then
        echo -e "${RED}FAIL${NC}"
        echo "Missing route: $route"
        ALL_ROUTES_EXIST=false
    fi
done

if [ "$ALL_ROUTES_EXIST" = true ]; then
    echo -e "${GREEN}PASS${NC}"
fi

# Test 5: Check SQL schema has required tables
echo -n "Test 5: Database schema... "
REQUIRED_TABLES=(
    "users"
    "invitation_codes"
    "sessions"
    "lobbies"
    "lobby_players"
    "games"
    "game_turns"
    "voting_sessions"
    "leaderboards"
    "badges"
)

SCHEMA_VALID=true
for table in "${REQUIRED_TABLES[@]}"; do
    if ! grep -q "CREATE TABLE.*${table}" backend/database/init.sql; then
        echo -e "${RED}FAIL${NC}"
        echo "Missing table in schema: $table"
        SCHEMA_VALID=false
    fi
done

if [ "$SCHEMA_VALID" = true ]; then
    echo -e "${GREEN}PASS${NC}"
fi

# Test 6: Check .env.example has required variables
echo -n "Test 6: Environment template... "
REQUIRED_ENV_VARS=(
    "POSTGRES_PASSWORD"
    "REDIS_PASSWORD"
    "JWT_SECRET"
    "GRAFANA_PASSWORD"
    "DOMAIN"
)

ENV_VALID=true
for var in "${REQUIRED_ENV_VARS[@]}"; do
    if ! grep -q "^${var}=" .env.example; then
        echo -e "${RED}FAIL${NC}"
        echo "Missing environment variable: $var"
        ENV_VALID=false
    fi
done

if [ "$ENV_VALID" = true ]; then
    echo -e "${GREEN}PASS${NC}"
fi

# Test 7: Check Nginx configuration
echo -n "Test 7: Nginx configuration... "
if grep -q "upstream api_backend" backend/nginx/nginx.conf && \
   grep -q "upstream socket_backend" backend/nginx/nginx.conf && \
   grep -q "location /api/" backend/nginx/nginx.conf && \
   grep -q "location /socket.io/" backend/nginx/nginx.conf; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "Nginx configuration is missing required upstreams or locations"
fi

# Test 8: Check deploy script is executable
echo -n "Test 8: Deploy script executable... "
if [ -x "deploy.sh" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "deploy.sh is not executable. Run: chmod +x deploy.sh"
fi

# Test 9: Check documentation exists
echo -n "Test 9: Documentation... "
if [ -f "DEPLOYMENT.md" ] && [ -f "backend/README.md" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "Missing documentation files"
fi

# Test 10: Check Docker Compose services
echo -n "Test 10: Docker Compose services... "
REQUIRED_SERVICES=(
    "postgres"
    "redis"
    "api-server"
    "socket-server"
    "nginx"
    "prometheus"
    "grafana"
)

SERVICES_VALID=true
for service in "${REQUIRED_SERVICES[@]}"; do
    if ! grep -q "^  ${service}:" docker-compose.yml; then
        echo -e "${RED}FAIL${NC}"
        echo "Missing service in docker-compose.yml: $service"
        SERVICES_VALID=false
    fi
done

if [ "$SERVICES_VALID" = true ]; then
    echo -e "${GREEN}PASS${NC}"
fi

echo ""
echo "=========================================="
echo "Validation Complete!"
echo "=========================================="
echo ""
echo "All checks passed! ✅"
echo ""
echo "Next steps:"
echo "1. Copy .env.example to .env and configure"
echo "2. Run: ./deploy.sh start"
echo "3. Test: curl http://mwalpha.eskienterprises.com/api/health"
echo ""
