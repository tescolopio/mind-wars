# Mind Wars - Technical Architecture

**Purpose**: System design and infrastructure overview  
**Author**: Engineering Team  
**Last Updated**: 2025-11-09  
**Status**: Active  

---

## Architecture Overview

### Client-Server Model
- **Thin Client**: Flutter mobile app (iOS/Android)
- **Authoritative Server**: Node.js backend with Socket.io
- **Database**: Firebase + PostgreSQL
- **Storage**: Firebase Cloud Storage + SQLite (offline)

### Tech Stack

**Frontend**:
- Flutter 3.0+ (Dart)
- Provider (state management)
- SQLite (offline storage)
- Socket.io client (real-time)

**Backend**:
- Node.js + Express
- Socket.io (multiplayer)
- Firebase (auth, database, hosting)
- PostgreSQL (relational data)

**Infrastructure**:
- GitHub Actions (CI/CD)
- Firebase Hosting
- Sentry (error tracking)
- Analytics (Firebase + custom)

---

**For detailed architecture, see [ARCHITECTURE.md](../../ARCHITECTURE.md)**
