# Mind Wars Backend Deployment - Quick Start 🚀

This guide will help you deploy the Mind Wars backend infrastructure on your server.

## What You'll Get

A complete backend system with:
- ✅ REST API server (authentication, lobbies, games, leaderboards)
- ✅ WebSocket server (real-time multiplayer)
- ✅ PostgreSQL database (data storage)
- ✅ Redis cache (sessions & real-time data)
- ✅ Nginx reverse proxy (API gateway at http://mwalpha.eskienterprises.com)
- ✅ Prometheus & Grafana (monitoring)

## Prerequisites

- Server with Docker installed
- Minimum: 4 CPU cores, 8GB RAM, 50GB SSD
- Domain: mwalpha.eskienterprises.com (pointing to your server)

## 5-Minute Setup

### 1. Clone Repository

```bash
git clone https://github.com/tescolopio/mind-wars.git
cd mind-wars
```

### 2. Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Generate strong passwords
openssl rand -base64 32  # For POSTGRES_PASSWORD
openssl rand -base64 32  # For REDIS_PASSWORD  
openssl rand -base64 64  # For JWT_SECRET
openssl rand -base64 32  # For GRAFANA_PASSWORD

# Edit .env file with generated passwords
nano .env
```

**Required variables in `.env`:**
- `POSTGRES_PASSWORD` - Database password
- `REDIS_PASSWORD` - Redis password
- `JWT_SECRET` - JWT signing secret
- `GRAFANA_PASSWORD` - Grafana admin password

### 3. Deploy

```bash
# Start all services
./deploy.sh start

# Check status
./deploy.sh status
```

That's it! Your backend is now running at:
- **API Gateway**: http://mwalpha.eskienterprises.com
- **Grafana Dashboard**: http://mwalpha.eskienterprises.com:3002

## Test Your Deployment

```bash
# Test API health
curl http://mwalpha.eskienterprises.com/api/health

# Test Socket.io health  
curl http://mwalpha.eskienterprises.com/socket.io/health

# Expected response: {"status":"healthy",...}
```

## Default Credentials

### Database Admin
- **Email**: admin@eskienterprises.com
- **Password**: admin123 (⚠️ **CHANGE IMMEDIATELY!**)

### Invitation Codes
- `BETA2025` - 100 uses
- `ALPHA001` - 50 uses

### Grafana
- **Username**: admin
- **Password**: (what you set in `.env`)

## Next Steps

1. **Change default admin password** - Log in and update immediately
2. **Configure SSL** - Set up HTTPS for production (see backend/README.md)
3. **Generate invitation codes** - Create codes for your beta testers
4. **Set up monitoring** - Configure Grafana dashboards and alerts
5. **Update Flutter app** - Point your mobile app to the new API gateway

## Common Commands

```bash
# View logs
./deploy.sh logs

# View specific service logs
./deploy.sh logs api-server

# Restart services
./deploy.sh restart

# Create database backup
./deploy.sh backup

# Check service status
./deploy.sh status
```

## API Endpoints

Your Flutter app should connect to:

```dart
// In your Flutter app configuration
final apiService = ApiService(
  baseUrl: 'http://mwalpha.eskienterprises.com/api',
);

final socketUrl = 'http://mwalpha.eskienterprises.com';
```

## Troubleshooting

### Services won't start
```bash
# Check Docker is running
sudo systemctl status docker

# View error logs
./deploy.sh logs
```

### Can't connect to API
```bash
# Check firewall
sudo ufw status
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 3002

# Check service health
./deploy.sh status
```

### Database connection errors
```bash
# Restart PostgreSQL
docker compose restart postgres

# View PostgreSQL logs
docker compose logs postgres
```

## Need More Help?

- **Full Documentation**: [backend/README.md](backend/README.md)
- **Architecture Details**: [BETA_TESTING_ARCHITECTURE.md](BETA_TESTING_ARCHITECTURE.md)
- **API Documentation**: Check backend/README.md for all endpoints
- **GitHub Issues**: Report bugs and request features

## Production Deployment

For production with SSL/TLS:

1. Get SSL certificate (Let's Encrypt):
   ```bash
   sudo certbot certonly --standalone -d mwalpha.eskienterprises.com
   ```

2. Copy certificates to nginx:
   ```bash
   sudo cp /etc/letsencrypt/live/mwalpha.eskienterprises.com/fullchain.pem backend/nginx/ssl/cert.pem
   sudo cp /etc/letsencrypt/live/mwalpha.eskienterprises.com/privkey.pem backend/nginx/ssl/key.pem
   ```

3. Update nginx config to enable HTTPS (uncomment HTTPS block in nginx.conf)

4. Restart nginx:
   ```bash
   docker compose restart nginx
   ```

## Support

Questions? Issues? Open a GitHub issue or check the documentation!

---

**Ready to test?** Your beta testers can now download the Mind Wars app and connect to your server! 🎮
