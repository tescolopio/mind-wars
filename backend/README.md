# Mind Wars Backend - Docker Deployment Guide

This directory contains the Docker Compose setup for deploying the Mind Wars backend infrastructure for beta testing.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                  Mind Wars Backend Stack                     │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Mobile Clients (iOS/Android)                                │
│         ↓                                                     │
│    Nginx (Load Balancer + Reverse Proxy)                     │
│         ↓                                                     │
│  ┌──────────────────┬──────────────────┐                     │
│  │  API Server      │  Socket.io       │                     │
│  │  (REST)          │  (WebSocket)     │                     │
│  │  Port: 3000      │  Port: 3001      │                     │
│  └──────────────────┴──────────────────┘                     │
│         ↓                                                     │
│  ┌──────────────────┬──────────────────┐                     │
│  │  PostgreSQL      │     Redis        │                     │
│  │  (Database)      │    (Cache)       │                     │
│  └──────────────────┴──────────────────┘                     │
│         ↓                                                     │
│  ┌──────────────────┬──────────────────┐                     │
│  │  Prometheus      │    Grafana       │                     │
│  │  (Metrics)       │  (Dashboards)    │                     │
│  └──────────────────┴──────────────────┘                     │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Services

### 1. API Server (Node.js + Express)
- **Port**: 3000 (internal)
- **Purpose**: REST API endpoints for authentication, lobbies, games, leaderboards, sync
- **Technology**: Node.js 18, Express, PostgreSQL, Redis
- **Health Check**: `/health`
- **Metrics**: `/metrics`

### 2. Socket.io Server (Node.js + Socket.io)
- **Port**: 3001 (internal)
- **Purpose**: Real-time multiplayer communication via WebSockets
- **Events**: lobby management, game turns, chat, voting
- **Technology**: Node.js 18, Socket.io, PostgreSQL, Redis
- **Health Check**: `/health`
- **Metrics**: `/metrics`

### 3. PostgreSQL Database
- **Port**: 5432 (internal only)
- **Version**: 15-alpine
- **Purpose**: Primary data store for users, lobbies, games, leaderboards
- **Initialization**: `backend/database/init.sql`

### 4. Redis Cache
- **Port**: 6379 (internal only)
- **Version**: 7-alpine
- **Purpose**: Session storage, rate limiting, real-time data caching

### 5. Nginx Load Balancer
- **Ports**: 80 (HTTP), 443 (HTTPS)
- **Purpose**: Reverse proxy, SSL termination, rate limiting
- **Configuration**: `backend/nginx/nginx.conf`
- **API Gateway**: http://mwalpha.eskienterprises.com

### 6. Prometheus
- **Port**: 9090 (internal)
- **Purpose**: Metrics collection and monitoring
- **Scrape Targets**: API server, Socket.io server

### 7. Grafana
- **Port**: 3002 (exposed for admin access)
- **Purpose**: Metrics visualization and dashboards
- **Default Credentials**: admin / (set in .env)

## Quick Start

### Prerequisites

- Docker 24.0+ installed
- Docker Compose v2 installed
- Server with minimum 4 CPU, 8GB RAM, 50GB SSD
- Domain configured: mwalpha.eskienterprises.com

### 1. Clone Repository

```bash
git clone https://github.com/tescolopio/mind-wars.git
cd mind-wars
```

### 2. Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit environment variables
nano .env
```

**Required environment variables:**

```bash
# Database
POSTGRES_PASSWORD=<strong-password>

# Redis
REDIS_PASSWORD=<strong-password>

# JWT
JWT_SECRET=<random-secret-key>

# Grafana
GRAFANA_PASSWORD=<admin-password>

# Domain
DOMAIN=mwalpha.eskienterprises.com
```

**Generate strong passwords:**

```bash
# Generate random password
openssl rand -base64 32

# Generate JWT secret
openssl rand -base64 64
```

### 3. Start Services

```bash
# Start all containers
docker compose up -d

# Check service health
docker compose ps

# View logs
docker compose logs -f
```

### 4. Verify Deployment

```bash
# Test API endpoint
curl http://mwalpha.eskienterprises.com/api/health

# Test Socket.io health
curl http://mwalpha.eskienterprises.com/socket.io/health

# Access Grafana (admin only)
open http://mwalpha.eskienterprises.com:3002
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/logout` - Logout user
- `POST /api/auth/refresh` - Refresh access token

### Lobbies
- `GET /api/lobbies` - List lobbies
- `POST /api/lobbies` - Create lobby
- `GET /api/lobbies/:id` - Get lobby details
- `POST /api/lobbies/:id/join` - Join lobby
- `POST /api/lobbies/:id/leave` - Leave lobby

### Games
- `POST /api/games/:id/submit` - Submit game result
- `POST /api/games/:id/validate-move` - Validate move
- `GET /api/games/:id/state` - Get game state

### Leaderboards
- `GET /api/leaderboard/weekly` - Weekly leaderboard
- `GET /api/leaderboard/all-time` - All-time leaderboard

### Sync (Offline Mode)
- `POST /api/sync/game` - Sync offline game
- `POST /api/sync/batch` - Batch sync multiple games

### Analytics
- `POST /api/analytics/track` - Track event
- `GET /api/analytics/events` - Get events (admin only)

### Users
- `GET /api/users/:id` - Get user profile
- `GET /api/users/:id/progress` - Get user progress

## Socket.io Events

### Lobby Events
- `create-lobby` - Create new lobby
- `join-lobby` - Join existing lobby
- `leave-lobby` - Leave lobby
- `start-game` - Host starts game

### Game Events
- `make-turn` - Submit turn
- `game-ended` - Game completed

### Chat Events
- `chat-message` - Send chat message
- `emoji-reaction` - Send emoji reaction

### Voting Events
- `start-voting` - Start game voting
- `vote-game` - Cast vote for game
- `vote-skip` - Vote to skip inactive player

## Database Schema

The database is automatically initialized with the following tables:

- `users` - User accounts and profiles
- `invitation_codes` - Beta invitation codes
- `sessions` - JWT refresh tokens
- `lobbies` - Game lobbies
- `lobby_players` - Lobby membership
- `games` - Game instances
- `game_turns` - Individual turns
- `game_scores` - Aggregated scores
- `voting_sessions` - Game voting sessions
- `votes` - Individual votes
- `leaderboards` - Rankings
- `badges` - Achievements
- `analytics_events` - Telemetry
- `audit_log` - Admin actions
- `chat_messages` - In-game chat

**Default Admin User:**
- Email: `admin@eskienterprises.com`
- Password: `admin123` (⚠️ **CHANGE IMMEDIATELY IN PRODUCTION!**)

**Default Invitation Codes:**
- `BETA2025` - 100 uses
- `ALPHA001` - 50 uses

## Monitoring & Management

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f api-server
docker compose logs -f socket-server
docker compose logs -f postgres
```

### Check Container Health

```bash
# All containers
docker compose ps

# Restart specific service
docker compose restart api-server

# Stop all services
docker compose down

# Stop and remove volumes (⚠️ deletes data)
docker compose down -v
```

### Database Access

```bash
# Connect to PostgreSQL
docker compose exec postgres psql -U mindwars -d mindwars_beta

# View tables
\dt

# Query users
SELECT id, email, username, role, created_at FROM users;

# Exit
\q
```

### Redis Access

```bash
# Connect to Redis
docker compose exec redis redis-cli -a <REDIS_PASSWORD>

# Check active sessions
KEYS session:*

# Exit
exit
```

### Grafana Dashboards

Access Grafana at: `http://mwalpha.eskienterprises.com:3002`

**Default Login:**
- Username: `admin`
- Password: (set in `.env` file)

**Available Dashboards:**
- System Overview
- API Performance
- Socket.io Connections
- Database Metrics

## Backup & Recovery

### Database Backup

```bash
# Create backup
docker compose exec postgres pg_dump -U mindwars mindwars_beta > backup-$(date +%Y%m%d).sql

# Compress backup
gzip backup-*.sql

# Copy to safe location
cp backup-*.sql.gz /path/to/backup/storage/
```

### Database Restore

```bash
# Stop services (keep database running)
docker compose stop api-server socket-server

# Restore from backup
gunzip -c backup-20251114.sql.gz | docker compose exec -T postgres psql -U mindwars mindwars_beta

# Restart services
docker compose start api-server socket-server
```

## Security Checklist

- [ ] Strong passwords configured in `.env`
- [ ] Changed default admin password
- [ ] Firewall configured (only ports 80, 443, 3002 open)
- [ ] PostgreSQL and Redis not exposed to internet
- [ ] SSL/TLS certificates configured for production
- [ ] Regular security updates applied
- [ ] Backup strategy implemented
- [ ] Monitoring and alerting configured

## Troubleshooting

### Containers won't start

```bash
# Check Docker status
sudo systemctl status docker

# Check logs
docker compose logs

# Restart Docker
sudo systemctl restart docker
```

### Database connection errors

```bash
# Check PostgreSQL status
docker compose ps postgres

# View PostgreSQL logs
docker compose logs postgres

# Restart PostgreSQL
docker compose restart postgres
```

### High memory usage

```bash
# Check resource usage
docker stats

# Restart specific service
docker compose restart api-server
```

### Port already in use

```bash
# Find process using port
sudo lsof -i :80
sudo lsof -i :443
sudo lsof -i :3002

# Kill process or change port in docker-compose.yml
```

## Production Deployment

For production deployment with SSL/TLS:

1. **Obtain SSL Certificates** (Let's Encrypt):
   ```bash
   # Install certbot
   sudo apt-get install certbot

   # Generate certificates
   sudo certbot certonly --standalone -d mwalpha.eskienterprises.com

   # Copy certificates to nginx directory
   sudo cp /etc/letsencrypt/live/mwalpha.eskienterprises.com/fullchain.pem backend/nginx/ssl/cert.pem
   sudo cp /etc/letsencrypt/live/mwalpha.eskienterprises.com/privkey.pem backend/nginx/ssl/key.pem
   ```

2. **Update Nginx Configuration**:
   - Uncomment HTTPS server block in `backend/nginx/nginx.conf`
   - Configure SSL certificate paths

3. **Restart Nginx**:
   ```bash
   docker compose restart nginx
   ```

4. **Set up auto-renewal**:
   ```bash
   # Add to crontab
   0 0 1 * * certbot renew --quiet && docker compose restart nginx
   ```

## Support

For issues, questions, or contributions:
- **GitHub Issues**: https://github.com/tescolopio/mind-wars/issues
- **Documentation**: See `BETA_TESTING_ARCHITECTURE.md`
- **Architecture**: See `ARCHITECTURE.md`

## License

MIT
