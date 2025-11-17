# Mind Wars Alpha Deployment - Session Plan & Status

## Current Session Overview
**Date:** November 16-17, 2025
**Objective:** Deploy Mind Wars multiplayer cognitive games platform to Android devices with backend authentication
**Status:** v1.0.1 built and installed; Docker connectivity issue encountered

---

## Architecture Summary

### Infrastructure Stack
- **Frontend:** Flutter iOS/Android app (alpha flavor)
- **Backend:** Node.js Express API (port 3010 internally, 4000 externally)
- **Multiplayer:** Socket.io server (port 3001)
- **Database:** PostgreSQL 15 (port 5432)
- **Cache:** Redis 7 (port 6379)
- **Gateway:** Nginx (port 4000 via Windows port proxy)
- **Container Orchestration:** Docker Compose with EskiEnterprises branding

### Network Flow
```
Android Device (172.16.0.X:5555)
    ↓
Windows Port Proxy (0.0.0.0:4000 → 172.28.48.1:4000)
    ↓
WSL Docker Host (172.28.48.1:4000)
    ↓
Nginx Gateway Container (mindwars-gateway:4000)
    ↓
Backend Services Network (backend_eskienterprises-mindwars-network)
    ├─ API Server (eskienterprises-mindwars-api:3010)
    ├─ Multiplayer Server (eskienterprises-mindwars-multiplayer:3001)
    ├─ PostgreSQL (eskienterprises-postgres:5432)
    └─ Redis (eskienterprises-redis:6379)
```

---

## Completed Work

### 1. ✅ Infrastructure Consolidation
- Renamed all containers under EskiEnterprises branding
- Created unified network: `backend_eskienterprises-mindwars-network`
- Set up `.env` configuration with proper credentials
- Fixed PostgreSQL port mapping (5432 internal, host external)

### 2. ✅ Gateway Configuration
- Created standalone Nginx container for port 4000 gateway
- Configured path-based routing:
  - `/api/*` → `eskienterprises-mindwars-api:3010`
  - `/socket.io*` → `eskienterprises-mindwars-multiplayer:3001`
  - `/health` → `eskienterprises-mindwars-api:3010`
- Set up Windows port proxy: `0.0.0.0:4000 → 172.28.48.1:4000`

### 3. ✅ Flutter App Configuration
- Updated API base URL: `http://war.e-mothership.com:4000/api`
- Updated WebSocket URL: `http://war.e-mothership.com:4000`
- Disabled alpha mode: `kAlphaMode = false` (uses backend auth instead of local)
- Fixed Dart compilation errors (VoteToSkip type, CardTheme, null-safety)

### 4. ✅ Backend API Fixes
- Fixed Express `trust proxy` setting for X-Forwarded-For headers from nginx
- Updated PATCH `/users/:id` to accept emoji avatars
- Verified registration endpoint works: tested with curl

### 5. ✅ Comprehensive Logging
Added print statements to:
- `lib/screens/registration_screen.dart` - logs registration flow and errors
- `lib/services/auth_service.dart` - logs validation, API calls, token storage
- `lib/services/api_service.dart` - logs HTTP requests, responses, status codes

### 6. ✅ APK Build & Deployment
- Built v1.0.1 APK (51-52 MB)
- Installed on both Android devices:
  - Device 1: 172.16.0.26:5555
  - Device 2: 172.16.0.6:5555
- Verified both devices launch successfully

### 7. ✅ Version Control
- Bumped version to 1.0.1 in pubspec.yaml
- Committed with detailed message to GitHub
- Pushed to main branch: commit 7992c92

---

## Current Issue

### Problem
Registration attempts from Android app result in "An Error Occurred Please Try Again" message, but:
- **No registration requests appear in API logs**
- App was installed and launched successfully
- API is healthy when tested directly with curl

### Possible Root Causes
1. **Network Connectivity:** App cannot reach gateway at `war.e-mothership.com:4000`
2. **Nginx Gateway Hung:** Container may have crashed or hung during build
3. **App Configuration:** BuildConfig.dart or main.dart URL mismatch
4. **Docker Daemon Issue:** Docker appears unresponsive during troubleshooting

### Symptoms
- Docker commands hanging (docker ps, docker logs timing out)
- Terminal becoming unresponsive when running docker commands
- No API logs of registration attempts since app installed

---

## Debugging Progress

### ✅ What We've Verified
- Backend API endpoint works directly: `curl http://localhost:4000/api/auth/register` returns 200
- User registration successful from curl: `testdevice2@example.com` created in database
- API logs show successful registrations from curl tests
- Android devices connected and app running

### ❌ What We Need to Verify
- Gateway container status and logs
- Network connectivity from Android device to gateway
- App actually making HTTP requests (verify with tcpdump or similar)
- Correct URL in app (verify BuildConfig values at runtime)

---

## Logging Information for Debugging

### App Logs - View with:
```bash
adb -s 172.16.0.26:5555 logcat | grep -E "Registration|AuthService|API"
```

Expected output during failed registration:
```
[Registration] Starting registration for: test@example.com
[Registration] Username: testuser
[AuthService] Starting registration for: test@example.com
[AuthService] Validation passed, calling API register method
[API] Attempting registration for: test@example.com at http://war.e-mothership.com:4000/api/auth/register
[API] Registration response status: XXX
[API] Registration response body: {error or success}
```

### Backend Logs - View with:
```bash
docker logs -f eskienterprises-mindwars-api
docker logs -f mindwars-gateway
```

---

## Next Steps (In Order)

### Phase 1: Restore Docker/Gateway
1. Check Docker daemon status: `systemctl status docker`
2. If hung, restart Docker: `sudo systemctl restart docker`
3. Verify containers running: `docker ps`
4. Check gateway health: `docker logs mindwars-gateway`
5. Test gateway: `curl http://localhost:4000/health`

### Phase 2: Debug App Connectivity
1. View app logs during registration attempt (capture above)
2. Check if "Registration response status" appears in logs
3. If not reaching API, verify URL in app:
   - Check `BuildConfig.wsBaseUrl` returns correct value
   - Check `ApiService.baseUrl` initialization
4. Verify port 4000 still forwarded from Windows:
   ```powershell
   netsh interface portproxy show all | grep 4000
   ```

### Phase 3: Network Diagnostics
1. From device, attempt connection:
   ```bash
   adb -s 172.16.0.26:5555 shell curl http://war.e-mothership.com:4000/health
   ```
2. If fails, try with IP:
   ```bash
   adb -s 172.16.0.26:5555 shell curl http://172.28.48.1:4000/health
   ```
3. Monitor gateway during request:
   ```bash
   docker logs -f mindwars-gateway
   ```

### Phase 4: API Response Analysis
1. If requests reach API but fail, check response:
   - Is response a 200 or error code?
   - What's the error message?
   - Check validation errors in API logs
2. Verify database connectivity:
   ```bash
   docker exec eskienterprises-postgres psql -U mindwars -d mindwars -c "SELECT COUNT(*) FROM users;"
   ```

### Phase 5: Multiplayer Testing
Once registration works:
1. Device 1: Register → Create Lobby
2. Device 2: Register → Join Lobby with code
3. Start game and verify Socket.io real-time sync
4. Test game move validation through server

---

## Version Management Strategy

### Current Version: 1.0.1
- Logging infrastructure added
- API trust proxy fixed
- Backend auth enabled (alpha mode off)

### Future Versions
For each minor version bump:

1. **Update pubspec.yaml:**
   ```yaml
   version: X.Y.Z+N
   ```

2. **Commit with semantic message:**
   ```bash
   git add -A
   git commit -m "vX.Y.Z: [Brief description]

   Changes:
   - Change 1
   - Change 2
   
   [Optional: Detailed explanation]"
   ```

3. **Push to GitHub:**
   ```bash
   git push origin main
   ```

4. **Build & Deploy:**
   ```bash
   flutter build apk --flavor alpha --release
   adb -s 172.16.0.26:5555 install build/app/outputs/flutter-apk/app-alpha-release.apk
   adb -s 172.16.0.6:5555 install build/app/outputs/flutter-apk/app-alpha-release.apk
   ```

---

## Key Files & Locations

### Frontend
- `lib/main.dart` - App entry, service initialization, gateway URL (line 63)
- `lib/utils/build_config.dart` - WebSocket URL config (line 62)
- `lib/services/auth_service.dart` - Authentication logic
- `lib/services/api_service.dart` - REST client with logging
- `lib/screens/registration_screen.dart` - Registration UI with error handling
- `pubspec.yaml` - App version config

### Backend
- `backend/api-server/src/index.js` - Express app setup, trust proxy (line 27)
- `backend/api-server/src/routes/auth.js` - Registration endpoint
- `backend/nginx.conf` - Nginx gateway config
- `backend/docker-compose.yml` - Container orchestration
- `.env` - Environment variables (API_PORT=3010)

### Infrastructure
- Windows Port Proxy: `0.0.0.0:4000 → 172.28.48.1:4000`
- Docker Gateway Container: `mindwars-gateway` (nginx:alpine on port 4000)
- Backend Network: `backend_eskienterprises-mindwars-network`

---

## Critical Configuration Values

| Item | Value | Notes |
|------|-------|-------|
| App API Base URL | `http://war.e-mothership.com:4000/api` | Set in main.dart line 63 |
| App WebSocket URL | `http://war.e-mothership.com:4000` | Set in build_config.dart line 62 |
| Backend API Port (Internal) | 3010 | Container internal port |
| Backend API Port (External) | 4000 | Nginx gateway + Windows proxy |
| Multiplayer Port (Internal) | 3001 | Container internal port |
| Alpha Mode | `false` | Uses backend auth, not local |
| Trust Proxy | Enabled | Express middleware setting |
| Database | PostgreSQL 15 | Port 5432 |
| Cache | Redis 7 | Port 6379 |

---

## Testing Checklist

- [ ] Docker daemon responsive and containers running
- [ ] Gateway container healthy and responding to requests
- [ ] App displays no errors on startup
- [ ] App can register new user (both devices)
- [ ] Registration creates user in PostgreSQL
- [ ] Auth tokens generated and stored locally
- [ ] Login works with registered credentials
- [ ] Profile setup completes successfully
- [ ] Can create/view lobbies
- [ ] Can join lobby with code
- [ ] Socket.io multiplayer events working
- [ ] Game moves synchronized in real-time
- [ ] Server validates all moves (thin client)
- [ ] Leaderboard updates correctly
- [ ] Offline sync works (if connectivity lost)

---

## Known Limitations & TODOs

### Current Limitations
- No SSL/TLS (HTTP only, for alpha testing)
- Rate limiting configured but may be strict
- No analytics or crash reporting
- Verbose logging in production build (should disable for release)

### Future Improvements
- Add SSL certificate for HTTPS
- Implement automatic APK versioning script
- Add CI/CD pipeline for automatic builds
- Implement proper error tracking (Sentry, Firebase)
- Remove verbose logging from release builds
- Add performance monitoring
- Implement analytics

---

## Emergency Procedures

### If Docker is hung:
```bash
sudo systemctl restart docker
docker ps  # Verify
```

### If gateway container is down:
```bash
docker restart mindwars-gateway
docker logs mindwars-gateway  # Check status
```

### If API is unhealthy:
```bash
docker restart eskienterprises-mindwars-api
curl http://localhost:3010/health  # Test directly
```

### If all containers crashed:
```bash
cd /mnt/d/mind-wars/backend
docker-compose down
docker-compose up -d
```

---

## Session Timeline

| Time | Task | Status |
|------|------|--------|
| Start | Infrastructure consolidation | ✅ Complete |
| Early | Gateway setup (nginx on 4000) | ✅ Complete |
| Mid | Flutter app routing config | ✅ Complete |
| Mid | Backend API fixes (trust proxy) | ✅ Complete |
| Mid | Add comprehensive logging | ✅ Complete |
| Late | v1.0.1 build and deploy | ✅ Complete |
| Late | Git commit and push | ✅ Complete |
| Now | Registration testing | ⚠️ In progress - Docker issue |
| Next | Docker recovery & debugging | ⏳ Pending |

---

## Success Criteria

**This session is successful when:**
1. ✅ Registration works on at least one device
2. ✅ User can log in with credentials
3. ✅ Both devices can connect to backend through gateway
4. ✅ Multiplayer lobby creation/joining works
5. ✅ Game moves synchronized in real-time
6. ⏳ API validates all game logic (thin client confirmed)

**Minimum acceptable:**
- App can register and authenticate through backend API
- At least basic game flow works on both devices

---

## Questions & Decisions Needed

1. Should we enable SSL/TLS for the gateway? (Requires certificate setup)
2. Should we add automatic versioning to build script?
3. Should verbose logging be disabled in release builds?
4. What's the plan for production database backups?
5. Should we set up CI/CD for automated builds?
