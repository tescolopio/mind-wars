# Mind Wars - API Documentation

**Purpose**: Backend API reference  
**Author**: Engineering Team  
**Last Updated**: 2025-11-09  
**Status**: Active  

---

## Base URL
```
Production: https://api.mindwars.app
Staging: https://staging-api.mindwars.app
Development: http://localhost:3000
```

## Authentication
All API requests require JWT token in Authorization header:
```
Authorization: Bearer <token>
```

## Core Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user
- `POST /auth/logout` - Logout user

### Game Management
- `GET /games` - List available games
- `POST /games/:id/start` - Start new game
- `POST /games/:id/submit` - Submit game result
- `POST /games/:id/validate` - Validate move

### Lobby Management
- `GET /lobbies` - List lobbies
- `POST /lobbies` - Create lobby
- `GET /lobbies/:id` - Get lobby details
- `POST /lobbies/:id/join` - Join lobby
- `DELETE /lobbies/:id/leave` - Leave lobby

### Progression
- `GET /leaderboard/weekly` - Weekly leaderboard
- `GET /users/:id/progress` - User progress
- `GET /users/:id/badges` - User badges

---

**Detailed specs coming soon. See [ARCHITECTURE.md](../../ARCHITECTURE.md) for overview.**
