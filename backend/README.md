# Mind Wars Backend

Production-ready backend infrastructure for Mind Wars mobile application.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│         Mobile Clients (iOS/Android)        │
└────────────────┬────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────┐
│          Load Balancer (Nginx)              │
│         Rate Limiting & SSL/TLS             │
└─────────────┬──────────────┬────────────────┘
              │              │
      ┌───────┘              └────────┐
      ↓                               ↓
┌─────────────┐              ┌────────────────┐
│ REST API    │              │ Socket.io      │
│ Server      │              │ Multiplayer    │
│ (Port 3000) │              │ (Port 3001)    │
└─────┬───────┘              └────────┬───────┘
      │                               │
      └──────────┬────────────────────┘
                 │
      ┌──────────┴─────────────┐
      ↓                        ↓
┌─────────────┐          ┌──────────┐
│ PostgreSQL  │          │  Redis   │
│ Database    │          │  Cache   │
│ (Port 5432) │          │(Port 6379)│
└─────────────┘          └──────────┘
```

## 📦 Components

### 1. REST API Server (`api-server/`)
- **Technology**: Node.js + Express.js
- **Port**: 3000
- **Features**:
  - JWT-based authentication
  - User management
  - Game results & scoring
  - Leaderboards (weekly & all-time)
  - Offline sync endpoints
  - Rate limiting
  - Request logging

### 2. Socket.io Multiplayer Server (`multiplayer-server/`)
- **Technology**: Node.js + Socket.io
- **Port**: 3001
- **Features**:
  - Real-time lobby management
  - Turn-based gameplay
  - In-game chat
  - Game voting system
  - Player presence tracking
  - Emoji reactions

### 3. PostgreSQL Database
- **Version**: 15+
- **Port**: 5432
- **Features**:
  - User accounts & profiles
  - Lobby & game session management
  - Game results & scoring
  - Leaderboards & badges
  - Voting system

### 4. Redis Cache
- **Version**: 7+
- **Port**: 6379
- **Features**:
  - Session management
  - Leaderboard caching
  - Rate limiting data

## 🚀 Quick Start

### Prerequisites

- **Docker**: 24.0+ and Docker Compose 2.0+
- **Node.js**: 18+ (for local development)
- **Git**: Latest version

### 1. Clone and Setup

```bash
# Navigate to backend directory
cd backend

# Copy environment file
cp .env.example .env

# Edit .env file with your settings
nano .env
```

### 2. Deploy with Docker Compose

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Check service health
docker-compose ps
```

### 3. Initialize Database

```bash
# Database is automatically initialized on first startup
# To manually run migrations:
docker-compose exec postgres psql -U mindwars -d mindwars -f /docker-entrypoint-initdb.d/01-schema.sql
```

### 4. Verify Deployment

```bash
# Check API Server
curl http://localhost:3000/health

# Expected response:
# {"status":"healthy","service":"mind-wars-api","timestamp":"..."}

# Check services are running
docker-compose ps
```

## 🔧 Configuration

### Environment Variables

Edit the `.env` file to configure the backend:

```bash
# Server Configuration
NODE_ENV=development          # development, production
API_PORT=3000                 # REST API port
MULTIPLAYER_PORT=3001         # Socket.io port

# Database
POSTGRES_HOST=postgres        # Database host
POSTGRES_DB=mindwars          # Database name
POSTGRES_USER=mindwars        # Database user
POSTGRES_PASSWORD=<strong-password>  # CHANGE THIS!

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# Security
JWT_SECRET=<random-string-64-chars>  # CHANGE THIS!
BCRYPT_ROUNDS=12

# CORS (comma-separated origins)
CORS_ORIGIN=http://localhost:8080,https://yourdomain.com
```

### Production Configuration

For production deployment:

1. **Change all default passwords**:
   - `POSTGRES_PASSWORD`
   - `JWT_SECRET`
   - `SESSION_SECRET`

2. **Configure CORS**:
   ```bash
   CORS_ORIGIN=https://yourdomain.com
   ```

3. **Enable SSL** (see Nginx configuration)

4. **Set up proper logging**:
   ```bash
   LOG_LEVEL=error
   ```

## 📱 Connecting the Mobile App

### Update Flutter App Configuration

Edit `lib/services/api_service.dart` and `lib/services/multiplayer_service.dart`:

```dart
// API Service - lib/services/api_service.dart
final apiService = ApiService(
  baseUrl: 'http://YOUR_SERVER_IP:3000/api',  // Your server IP
);

// Multiplayer Service - lib/services/multiplayer_service.dart
await multiplayerService.connect(
  'http://YOUR_SERVER_IP:3001',  // Your server IP
  playerId,
);
```

### For WSL Deployment

If running on Windows WSL:

1. Find your WSL IP:
   ```bash
   ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
   ```

2. Use this IP in your Flutter app configuration

3. Ensure Windows Firewall allows ports 3000 and 3001

## 🔍 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/refresh` - Refresh access token
- `POST /api/auth/logout` - Logout user
- `GET /api/auth/me` - Get current user

### Lobbies
- `GET /api/lobbies` - List public lobbies
- `GET /api/lobbies/:id` - Get lobby details

### Games
- `GET /api/games` - Get available games
- `POST /api/games/:id/submit` - Submit game result
- `POST /api/games/:id/validate-move` - Validate game move

### Users
- `GET /api/users/:id` - Get user profile
- `GET /api/users/:id/progress` - Get user progress
- `PATCH /api/users/:id` - Update user profile

### Leaderboards
- `GET /api/leaderboard/weekly` - Get weekly leaderboard
- `GET /api/leaderboard/all-time` - Get all-time leaderboard

### Sync (Offline Support)
- `POST /api/sync/game` - Sync offline game
- `POST /api/sync/progress` - Sync user progress
- `POST /api/sync/batch` - Batch sync multiple games

## 🎮 Socket.io Events

### Lobby Management
- `create-lobby` - Create new lobby
- `join-lobby` - Join lobby by ID
- `join-lobby-by-code` - Join lobby by code
- `leave-lobby` - Leave lobby
- `kick-player` - Kick player (host only)
- `transfer-host` - Transfer host role
- `close-lobby` - Close lobby
- `list-lobbies` - List available lobbies

### Game Events
- `start-game` - Start game (host only)
- `make-turn` - Submit turn
- `submit-game-result` - Submit game result

### Chat Events
- `chat-message` - Send chat message
- `emoji-reaction` - Send emoji reaction

### Voting Events
- `start-voting` - Start game voting
- `vote-game` - Vote for a game
- `remove-vote` - Remove vote
- `end-voting` - End voting session
- `vote-skip` - Vote to skip inactive player

## 🛠️ Development

### Local Development (without Docker)

```bash
# Install dependencies
cd api-server && npm install
cd ../multiplayer-server && npm install

# Start PostgreSQL and Redis (with Docker)
docker-compose up -d postgres redis

# Run database migration
cd database && node migrate.js

# Start API server
cd api-server && npm run dev

# Start multiplayer server (in another terminal)
cd multiplayer-server && npm run dev
```

### Running Tests

```bash
# Run all tests
npm test

# Run API server tests
cd api-server && npm test

# Run multiplayer server tests
cd multiplayer-server && npm test
```

### Database Management

```bash
# Connect to database
docker-compose exec postgres psql -U mindwars -d mindwars

# View logs
docker-compose logs postgres

# Backup database
docker-compose exec postgres pg_dump -U mindwars mindwars > backup.sql

# Restore database
docker-compose exec -T postgres psql -U mindwars -d mindwars < backup.sql
```

## 📊 Monitoring

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f api-server
docker-compose logs -f multiplayer-server
docker-compose logs -f postgres
docker-compose logs -f redis
```

### Health Checks

```bash
# API Server
curl http://localhost:3000/health

# Check all containers
docker-compose ps
```

## 🔒 Security

### Production Security Checklist

- [ ] Change all default passwords
- [ ] Generate strong JWT secret (64+ characters)
- [ ] Configure proper CORS origins
- [ ] Enable SSL/TLS certificates
- [ ] Set up firewall rules
- [ ] Enable rate limiting
- [ ] Set up monitoring and alerting
- [ ] Regular database backups
- [ ] Keep dependencies updated
- [ ] Review and audit logs regularly

### Recommended Settings

```bash
# Production .env
NODE_ENV=production
JWT_SECRET=<64-character-random-string>
POSTGRES_PASSWORD=<strong-password>
CORS_ORIGIN=https://yourdomain.com
LOG_LEVEL=error
BCRYPT_ROUNDS=12
```

## 🐛 Troubleshooting

### Services Won't Start

```bash
# Check Docker is running
docker ps

# View logs for errors
docker-compose logs

# Restart services
docker-compose restart
```

### Database Connection Errors

```bash
# Check PostgreSQL is running
docker-compose ps postgres

# Test connection
docker-compose exec postgres psql -U mindwars -d mindwars -c "SELECT 1"

# Reset database
docker-compose down -v
docker-compose up -d
```

### Port Conflicts

If ports 3000, 3001, 5432, or 6379 are already in use:

```bash
# Change ports in .env file
API_PORT=4000
MULTIPLAYER_PORT=4001
POSTGRES_PORT=5433
REDIS_PORT=6380

# Restart services
docker-compose down
docker-compose up -d
```

## 📈 Performance Tuning

### PostgreSQL Optimization

```bash
# Edit postgresql.conf (inside container)
docker-compose exec postgres nano /var/lib/postgresql/data/postgresql.conf

# Recommended settings:
# shared_buffers = 256MB
# effective_cache_size = 1GB
# work_mem = 16MB
# maintenance_work_mem = 128MB
```

### Redis Optimization

```bash
# Monitor Redis
docker-compose exec redis redis-cli MONITOR

# Check memory usage
docker-compose exec redis redis-cli INFO memory
```

## 📝 License

MIT License - See LICENSE file for details

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write tests
5. Submit a pull request

## 📞 Support

For issues and questions:
- GitHub Issues: https://github.com/tescolopio/mind-wars/issues
- Documentation: See `/docs` directory

---

**Built with ❤️ for Mind Wars**
