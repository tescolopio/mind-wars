# Mind Wars Backend - Pre-Deployment Checklist ✅

Use this checklist before deploying to your production or beta testing server.

## Server Requirements

- [ ] Server has minimum 4 CPU cores
- [ ] Server has minimum 8GB RAM
- [ ] Server has minimum 50GB SSD storage
- [ ] Docker 24.0+ is installed
- [ ] Docker Compose v2 is installed
- [ ] Ports 80, 443, and 3002 are available
- [ ] Firewall configured to allow ports 80, 443, 3002

## DNS Configuration

- [ ] Domain `mwalpha.eskienterprises.com` points to server IP
- [ ] DNS propagation complete (test with `dig` or `nslookup`)
- [ ] A record configured correctly
- [ ] (Optional) AAAA record for IPv6 configured

## Repository Setup

- [ ] Repository cloned to server: `git clone https://github.com/tescolopio/mind-wars.git`
- [ ] In the correct directory: `cd mind-wars`
- [ ] Latest changes pulled: `git pull origin main`
- [ ] Correct branch checked out (if applicable)

## Environment Configuration

- [ ] Copied environment template: `cp .env.example .env`
- [ ] Generated strong `POSTGRES_PASSWORD` (32+ chars)
- [ ] Generated strong `REDIS_PASSWORD` (32+ chars)
- [ ] Generated strong `JWT_SECRET` (64+ chars)
- [ ] Generated strong `GRAFANA_PASSWORD` (32+ chars)
- [ ] Set `DOMAIN=mwalpha.eskienterprises.com`
- [ ] Configured `EMAIL_SERVICE` and `EMAIL_API_KEY` (if using email)
- [ ] Set `NODE_ENV=production`
- [ ] Verified all required variables are set

**Generate passwords:**
```bash
openssl rand -base64 32  # For passwords
openssl rand -base64 64  # For JWT secret
```

## Pre-Deployment Validation

- [ ] Run validation script: `./validate-setup.sh`
- [ ] All validation tests pass
- [ ] No missing files or directories
- [ ] Docker Compose syntax valid
- [ ] Deploy script is executable: `ls -l deploy.sh` (should show `x` permission)

## SSL/HTTPS Configuration (Production Only)

For production deployment with HTTPS:

- [ ] SSL certificates obtained (Let's Encrypt or other)
- [ ] Certificates copied to `backend/nginx/ssl/`
  - [ ] `cert.pem` (certificate chain)
  - [ ] `key.pem` (private key)
- [ ] Certificate files have correct permissions (644 for cert, 600 for key)
- [ ] Nginx HTTPS configuration uncommented in `backend/nginx/nginx.conf`
- [ ] HTTP to HTTPS redirect configured

**Generate Let's Encrypt certificates:**
```bash
sudo certbot certonly --standalone -d mwalpha.eskienterprises.com
sudo cp /etc/letsencrypt/live/mwalpha.eskienterprises.com/fullchain.pem backend/nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/mwalpha.eskienterprises.com/privkey.pem backend/nginx/ssl/key.pem
chmod 644 backend/nginx/ssl/cert.pem
chmod 600 backend/nginx/ssl/key.pem
```

## Initial Deployment

- [ ] Deploy all services: `./deploy.sh start`
- [ ] Wait for services to start (10-30 seconds)
- [ ] Check service status: `./deploy.sh status`
- [ ] All containers are running and healthy
- [ ] No error logs: `./deploy.sh logs | grep -i error`

## Health Check Verification

- [ ] API health endpoint responds: `curl http://mwalpha.eskienterprises.com/api/health`
  - Expected: `{"status":"healthy",...}`
- [ ] Socket.io health endpoint responds: `curl http://mwalpha.eskienterprises.com/socket.io/health`
  - Expected: `{"status":"healthy",...}`
- [ ] Database is accessible (check logs)
- [ ] Redis is connected (check logs)

## Database Verification

- [ ] Connect to database: `docker compose exec postgres psql -U mindwars -d mindwars_beta`
- [ ] List tables: `\dt`
- [ ] Verify 15+ tables exist
- [ ] Check default admin user exists: `SELECT email, role FROM users WHERE role='admin';`
- [ ] Verify invitation codes: `SELECT code, max_uses FROM invitation_codes;`
- [ ] Exit: `\q`

## Security Configuration

- [ ] Changed default admin password from `admin123`
- [ ] Verified password hashing is enabled (bcrypt)
- [ ] Tested rate limiting (make 100+ requests quickly)
- [ ] Verified JWT tokens expire correctly
- [ ] CORS configured for mobile app origins
- [ ] Firewall rules applied
- [ ] SSH access secured (disable root login, use keys)
- [ ] Server OS updated: `sudo apt update && sudo apt upgrade`

## Monitoring Setup

- [ ] Access Grafana: `http://mwalpha.eskienterprises.com:3002`
- [ ] Login with admin credentials (from `.env`)
- [ ] Verify Prometheus datasource connected
- [ ] Check metrics are being collected
- [ ] Create or import dashboards
- [ ] Configure alert rules (optional but recommended)
- [ ] Set up notification channels (email, Slack, etc.)

## Backup Strategy

- [ ] Test database backup: `./deploy.sh backup`
- [ ] Verify backup file created in `backups/` directory
- [ ] Test database restore process
- [ ] Set up automated backups (cron job)
- [ ] Configure backup retention policy
- [ ] Test backup to external storage (S3, etc.)

**Automated daily backup (crontab):**
```bash
sudo crontab -e
# Add: 0 2 * * * cd /path/to/mind-wars && ./deploy.sh backup
```

## Functional Testing

### Authentication
- [ ] Register new test user with invitation code
- [ ] Login with test user
- [ ] Verify JWT tokens received
- [ ] Test token refresh
- [ ] Test logout

### Lobbies
- [ ] Create lobby as test user
- [ ] Verify lobby code generated
- [ ] Register second test user
- [ ] Join lobby with second user
- [ ] Verify both users see each other
- [ ] Leave lobby
- [ ] Verify lobby updated

### Real-Time (Socket.io)
- [ ] Connect to Socket.io from test app/client
- [ ] Send chat message
- [ ] Send emoji reaction
- [ ] Verify real-time updates
- [ ] Test reconnection after disconnect

### Games
- [ ] Start game in lobby
- [ ] Submit turn
- [ ] Verify turn validated
- [ ] Check scores updated
- [ ] Complete game
- [ ] Verify leaderboard updated

### API Performance
- [ ] Check API response times (<500ms)
- [ ] Monitor error rates (<1%)
- [ ] Verify rate limiting works
- [ ] Check concurrent connections

## Mobile App Integration

- [ ] Update Flutter app configuration:
  ```dart
  baseUrl: 'http://mwalpha.eskienterprises.com/api'
  socketUrl: 'http://mwalpha.eskienterprises.com'
  ```
- [ ] Build and test mobile app
- [ ] Register from mobile app
- [ ] Create lobby from mobile app
- [ ] Test full game flow from mobile
- [ ] Verify offline sync works
- [ ] Test on both iOS and Android

## Beta Tester Onboarding

- [ ] Generate invitation codes for testers
- [ ] Document registration process
- [ ] Prepare welcome email/message
- [ ] Set up support channels (Discord, Slack, email)
- [ ] Create feedback collection process
- [ ] Prepare bug reporting workflow

## Documentation Review

- [ ] Read [DEPLOYMENT.md](DEPLOYMENT.md)
- [ ] Read [backend/README.md](backend/README.md)
- [ ] Understand [BETA_TESTING_ARCHITECTURE.md](BETA_TESTING_ARCHITECTURE.md)
- [ ] Review API endpoints documentation
- [ ] Understand monitoring and troubleshooting

## Post-Deployment

- [ ] Monitor logs for first 24 hours
- [ ] Check metrics in Grafana
- [ ] Verify no memory leaks
- [ ] Monitor disk usage
- [ ] Review error logs
- [ ] Test backup restoration
- [ ] Invite first batch of beta testers
- [ ] Collect and respond to feedback

## Maintenance Schedule

- [ ] Daily: Check service health and logs
- [ ] Daily: Review Grafana dashboards
- [ ] Weekly: Review analytics and metrics
- [ ] Weekly: Update server packages
- [ ] Monthly: Review and clean old backups
- [ ] Monthly: Security audit
- [ ] Monthly: Performance optimization review

## Troubleshooting Resources

If you encounter issues, check:

1. **Logs**: `./deploy.sh logs` or `./deploy.sh logs [service]`
2. **Status**: `./deploy.sh status`
3. **Documentation**: `backend/README.md` Common Issues section
4. **GitHub Issues**: Report bugs and get help
5. **Container Inspection**: `docker compose ps` and `docker inspect`

## Emergency Rollback

If deployment fails critically:

```bash
# Stop all services
./deploy.sh stop

# Restore from backup
gunzip -c backups/backup-YYYYMMDD.sql.gz | \
  docker compose exec -T postgres psql -U mindwars mindwars_beta

# Restart services
./deploy.sh start
```

## Success Criteria

Before marking deployment complete:

- [ ] All services running and healthy
- [ ] All API endpoints responding correctly
- [ ] WebSocket connections working
- [ ] Database queries performing well (<200ms)
- [ ] Monitoring dashboards showing data
- [ ] Test users can register and play
- [ ] Mobile app connects successfully
- [ ] Backups working and tested
- [ ] SSL/HTTPS configured (production)
- [ ] Documentation reviewed and understood

---

## 🎉 Deployment Complete!

Once all items are checked, your Mind Wars backend is **live and ready** for beta testing!

**API Gateway**: http://mwalpha.eskienterprises.com

**Next**: Invite beta testers and start collecting feedback! 🚀
