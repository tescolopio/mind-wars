#!/bin/bash

# Mind Wars Backend Deployment Script
# Usage: ./deploy.sh [start|stop|restart|logs|status|backup|clean]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check Docker Compose
    if ! docker compose version &> /dev/null; then
        log_error "Docker Compose v2 is not installed. Please install Docker Compose v2."
        exit 1
    fi
    
    # Check .env file
    if [ ! -f "$PROJECT_DIR/.env" ]; then
        log_warn ".env file not found. Creating from .env.example..."
        cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
        log_warn "Please edit .env file and set required environment variables."
        exit 1
    fi
    
    log_info "Prerequisites check passed!"
}

start_services() {
    log_info "Starting Mind Wars backend services..."
    cd "$PROJECT_DIR"
    
    docker compose up -d
    
    log_info "Waiting for services to be healthy..."
    sleep 10
    
    docker compose ps
    
    log_info ""
    log_info "Services started successfully!"
    log_info "API Gateway: http://mwalpha.eskienterprises.com"
    log_info "Grafana: http://mwalpha.eskienterprises.com:3002"
}

stop_services() {
    log_info "Stopping Mind Wars backend services..."
    cd "$PROJECT_DIR"
    
    docker compose down
    
    log_info "Services stopped successfully!"
}

restart_services() {
    log_info "Restarting Mind Wars backend services..."
    stop_services
    sleep 2
    start_services
}

show_logs() {
    cd "$PROJECT_DIR"
    
    if [ -z "$2" ]; then
        log_info "Showing logs for all services..."
        docker compose logs -f
    else
        log_info "Showing logs for $2..."
        docker compose logs -f "$2"
    fi
}

show_status() {
    cd "$PROJECT_DIR"
    
    log_info "Service Status:"
    docker compose ps
    
    log_info ""
    log_info "Health Checks:"
    
    # Check API health
    if curl -s http://localhost/api/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} API Server is healthy"
    else
        echo -e "${RED}✗${NC} API Server is unhealthy"
    fi
    
    # Check Socket.io health
    if curl -s http://localhost/socket.io/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Socket.io Server is healthy"
    else
        echo -e "${RED}✗${NC} Socket.io Server is unhealthy"
    fi
}

backup_database() {
    cd "$PROJECT_DIR"
    
    BACKUP_DIR="$PROJECT_DIR/backups"
    mkdir -p "$BACKUP_DIR"
    
    BACKUP_FILE="$BACKUP_DIR/mindwars-backup-$(date +%Y%m%d-%H%M%S).sql"
    
    log_info "Creating database backup..."
    docker compose exec -T postgres pg_dump -U mindwars mindwars_beta > "$BACKUP_FILE"
    
    log_info "Compressing backup..."
    gzip "$BACKUP_FILE"
    
    log_info "Backup created: ${BACKUP_FILE}.gz"
    
    # Keep only last 7 backups
    log_info "Cleaning old backups..."
    cd "$BACKUP_DIR"
    ls -t mindwars-backup-*.sql.gz | tail -n +8 | xargs -r rm --
    
    log_info "Backup completed successfully!"
}

clean_all() {
    log_warn "This will remove all containers, volumes, and data!"
    read -p "Are you sure? (yes/no): " -r
    
    if [ "$REPLY" = "yes" ]; then
        cd "$PROJECT_DIR"
        
        log_info "Stopping and removing all containers and volumes..."
        docker compose down -v
        
        log_info "Cleanup completed!"
    else
        log_info "Cleanup cancelled."
    fi
}

show_help() {
    cat << EOF
Mind Wars Backend Deployment Script

Usage: $0 [COMMAND]

Commands:
  start         Start all backend services
  stop          Stop all backend services
  restart       Restart all backend services
  logs [service] Show logs (optionally for specific service)
  status        Show service status and health
  backup        Create database backup
  clean         Remove all containers and volumes (⚠️  destructive)
  help          Show this help message

Examples:
  $0 start                # Start all services
  $0 logs                 # Show all logs
  $0 logs api-server      # Show API server logs only
  $0 backup               # Create database backup
  $0 status               # Check service health

EOF
}

# Main script
case "${1:-}" in
    start)
        check_prerequisites
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        check_prerequisites
        restart_services
        ;;
    logs)
        show_logs "$@"
        ;;
    status)
        show_status
        ;;
    backup)
        backup_database
        ;;
    clean)
        clean_all
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        log_error "Unknown command: ${1:-}"
        echo ""
        show_help
        exit 1
        ;;
esac
