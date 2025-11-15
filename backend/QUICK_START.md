# Mind Wars Backend - Quick Start Guide

Get your Mind Wars backend up and running in 5 minutes!

## Prerequisites

- **Docker Desktop** (for Windows/Mac) or **Docker + Docker Compose** (for Linux)
- **Git** (to clone the repository)

## Step 1: Navigate to Backend Directory

```bash
cd backend
```

## Step 2: Deploy Backend

```bash
# Make the deploy script executable
chmod +x scripts/deploy.sh

# Run deployment
./scripts/deploy.sh
```

This script will:
1. ✅ Check Docker installation
2. ✅ Create `.env` file if needed
3. ✅ Pull Docker images
4. ✅ Build services
5. ✅ Start all containers
6. ✅ Run health checks

## Step 3: Test the Backend

```bash
# Make the test script executable
chmod +x scripts/test-connection.sh

# Run connection tests
./scripts/test-connection.sh
```

## Step 4: Connect Mobile App

### For Local Development (Emulator)

Edit your Flutter app configuration:

**lib/services/api_service.dart:**
```dart
final apiService = ApiService(
  baseUrl: 'http://localhost:3000/api',
);
```

**lib/services/multiplayer_service.dart:**
```dart
await multiplayerService.connect(
  'http://localhost:3001',
  playerId,
);
```

### For Physical Device Testing

1. **Find your server IP:**
   ```bash
   # On Linux/Mac
   ip addr show | grep "inet " | grep -v 127.0.0.1

   # On Windows WSL
   ipconfig.exe | findstr /C:"IPv4"
   ```

2. **Update Flutter app:**
   ```dart
   // Replace localhost with your server IP
   baseUrl: 'http://192.168.1.100:3000/api',  // Example IP
   ```

3. **Allow firewall access** (Windows):
   - Open Windows Defender Firewall
   - Allow inbound connections on ports 3000 and 3001

## Step 5: Test Login

### Using Postman/Insomnia

**Login Request:**
```
POST http://localhost:3000/api/auth/login
Content-Type: application/json

{
  "email": "alice@example.com",
  "password": "password123"
}
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "...",
      "email": "alice@example.com",
      "displayName": "Alice",
      ...
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "..."
  }
}
```

### Using cURL

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"alice@example.com","password":"password123"}'
```

## Test Users

The database is pre-seeded with test users:

| Email | Password | Display Name | Level | Score |
|-------|----------|--------------|-------|-------|
| alice@example.com | password123 | Alice | 5 | 2500 |
| bob@example.com | password123 | Bob | 3 | 1200 |
| charlie@example.com | password123 | Charlie | 7 | 4800 |
| diana@example.com | password123 | Diana | 2 | 800 |

## Common Commands

```bash
# View logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f api-server
docker-compose logs -f multiplayer-server

# Restart services
docker-compose restart

# Stop services
docker-compose down

# Stop and remove volumes (reset database)
docker-compose down -v

# Check service status
docker-compose ps
```

## Verify Services

### API Server
```bash
curl http://localhost:3000/health
```

### Database
```bash
docker-compose exec postgres psql -U mindwars -d mindwars -c "SELECT COUNT(*) FROM users;"
```

### Redis
```bash
docker-compose exec redis redis-cli ping
```

## Troubleshooting

### Services won't start
```bash
# Check if ports are in use
sudo lsof -i :3000
sudo lsof -i :3001
sudo lsof -i :5432
sudo lsof -i :6379

# View detailed logs
docker-compose logs
```

### Can't connect from mobile app
1. Check firewall settings
2. Verify server IP address
3. Ensure CORS is configured correctly in `.env`
4. Check mobile device is on same network

### Database errors
```bash
# Reset database
docker-compose down -v
docker-compose up -d

# View database logs
docker-compose logs postgres
```

## Next Steps

1. **Test the mobile app** with the backend
2. **Review API documentation** in README.md
3. **Configure production settings** before deployment
4. **Set up monitoring** for production

## Production Deployment

Before deploying to production:

1. ✅ Change all default passwords in `.env`
2. ✅ Generate strong JWT secret
3. ✅ Configure proper CORS origins
4. ✅ Enable SSL/TLS certificates
5. ✅ Set up database backups
6. ✅ Configure monitoring and alerting

See README.md for detailed production deployment guide.

## Support

- **Issues**: https://github.com/tescolopio/mind-wars/issues
- **Documentation**: See backend/README.md
- **API Docs**: See backend/README.md#api-endpoints

---

**🎉 You're all set! Happy coding!**
