# Mind Wars - Copilot Instructions

## Project Overview

**Mind Wars** is an async multiplayer cognitive games platform (Flutter + Node.js backend) for iOS 14+/Android 8+. The system emphasizes **Mobile-First**, **Offline-First**, **API-First**, and **Security-First** principles.

Key characteristics:
- **2-10 async players** per lobby with Socket.io real-time events
- **12+ games** across 5 cognitive categories (Memory, Logic, Attention, Spatial, Language)
- **All games playable offline** with SQLite local storage and automatic sync
- **Server-side game validation** to prevent cheating (thin client architecture)

---

## Architecture & Key Principles

### 1. Mobile-First Design
- UI designed for 5" touch screens (48dp minimum touch targets)
- Material Design 3 with responsive layouts that scale up
- All buttons/cards have `minimumSize: Size(120, 48)` or larger
- **Key file**: `lib/main.dart` (theme configuration)

### 2. Offline-First System
- **SQLite database** (`lib/services/offline_service.dart`):
  - `offline_games`, `user_progress`, `sync_queue`, `game_cache` tables
  - All games playable locally without backend connectivity
- **Automatic sync** with conflict resolution: server wins for scoring
- **Sync queue** with retry logic (max 5 retries, exponential backoff)
- Must maintain optimistic updates on client with server confirmation

### 3. API-First (Server Authoritative)
- RESTful API at `backend/api-server/` (Express.js, port 3000)
- Socket.io multiplayer server at `backend/multiplayer-server/` (port 3001)
- **Security-First**: All game logic validated server-side
- Client is thin client—rendering and local caching only
- `lib/services/api_service.dart` abstracts all REST calls

### 4. Alpha Mode
- Default mode uses **local authentication** (no backend required for testing)
- `kAlphaMode = true` in `lib/main.dart` enables `LocalAuthService`
- User data stored locally in SQLite via `local_auth_service.dart`
- Splash screen shows "ALPHA VERSION" badge when enabled
- Set `kAlphaMode = false` to switch to backend authentication

### 5. Service-Oriented Architecture
All core logic lives in services (dependency injection via Provider):
- `auth_service.dart` — Auth state & session management
- `api_service.dart` — RESTful client (all backend calls)
- `multiplayer_service.dart` — Socket.io lobby/turn management
- `offline_service.dart` — SQLite storage & sync queue
- `progression_service.dart` — Leaderboards, badges, streaks
- `game_state_service.dart` — Current game state
- `turn_management_service.dart` — Turn-based game flow
- `scoring_service.dart` — Unified scoring across all games
- `voting_service.dart` — Game voting & vote-to-skip
- `hint_and_challenge_system.dart` — Daily challenges & hints

---

## Critical Developer Workflows

### Build & Run

**Debug (alpha mode):**
```bash
flutter run --flavor alpha --dart-define=FLAVOR=alpha
```

**Build alpha APK:**
```bash
./build-alpha.sh android
# or
flutter build apk --flavor alpha --release --dart-define=FLAVOR=alpha
```

**Production build:**
```bash
flutter build apk --flavor production --release
```

### Local Backend Setup
```bash
cd backend
cp .env.example .env
# Edit .env with your settings
docker-compose up -d
# Starts PostgreSQL (5432), Redis (6379), API (3000), Socket.io (3001)
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/auth_service_test.dart

# With coverage
flutter test --coverage
```

**Key test patterns** (see `test/auth_service_test.dart`):
- Use `@GenerateMocks()` for service dependencies
- Mocking example: `MockApiService` with `mockito`
- Always test error cases (invalid email, weak password, network failures)

---

## Project-Specific Conventions

### File Organization
```
lib/
  main.dart                 # App entry, service initialization, theme
  models/models.dart        # All DTOs: User, GameLobby, Turn, ChatMessage, etc.
  services/                 # All business logic (auth, api, multiplayer, etc.)
  screens/                  # UI screens (authentication, lobbies, gameplay)
  games/                    # Game implementations (game_catalog.dart + game logic)
  widgets/                  # Reusable UI components
  utils/                    # Utilities (validators, formatters, helpers)
test/                       # Tests with *_test.dart naming
backend/
  api-server/               # REST API (Node.js + Express)
  multiplayer-server/       # Socket.io multiplayer (Node.js)
  database/                 # SQL schemas
  docker/                   # Docker configs
```

### Naming Conventions
- **Services**: `*_service.dart` (e.g., `auth_service.dart`)
- **Models/DTOs**: `models.dart` (centralized)
- **Screens**: `*_screen.dart` (e.g., `login_screen.dart`)
- **Widgets**: `*_widget.dart` (e.g., `game_card_widget.dart`)
- **Tests**: `*_test.dart` with matching service name

### Model Pattern (Dart)
All models must implement:
- `toJson()` — Serialization for API/SQLite
- `fromJson()` factory — Deserialization from JSON
- `copyWith()` — Immutable updates (for state management)

Example from `models.dart`:
```dart
class User {
  final String id, username, email;
  
  Map<String, dynamic> toJson() => {'id': id, 'username': username, ...};
  factory User.fromJson(Map<String, dynamic> json) => User(...);
  User copyWith({String? username, ...}) => User(...);
}
```

### Service Pattern
- All services take dependencies in constructor (dependency injection)
- Services are singletons provided via Provider (see `main.dart`)
- Async operations return `Future<T>` or emit via listeners
- Handle errors gracefully with try-catch, return `AuthResult` or similar result types

Example from `auth_service.dart`:
```dart
class AuthService {
  final ApiService _apiService;
  final LocalAuthService? _localAuthService;
  
  AuthService({required ApiService apiService, LocalAuthService? localAuthService});
  
  Future<AuthResult> register({required String username, ...}) async {
    // Validation + API/local auth call
  }
}
```

### State Management
- **Provider** for service injection and notifiers
- No Redux/BLoC—keep it simple with Provider + ValueNotifier if needed
- Services manage state; UI reads from context providers

---

## Code Development & Documentation Standards

**ALL code development or alterations MUST include verbose comments with date and category tags.** This applies to:
- New functions or methods
- Modified existing code
- Logic changes or refactoring
- Bug fixes
- Performance optimizations
- Integration changes

### Comment Format

Use the following format for all code changes:

```dart
/// [YYYY-MM-DD Category] Description of change
/// 
/// Detailed explanation of what this code does, why it was changed,
/// or any important implementation notes for future maintainers.
///
/// Example:
/// [2025-11-15 Copilot Instructions] Added verbose comment tagging to all new code.
/// This change improves code traceability and helps AI agents understand change history.
```

### Category Tags
Use one of these category tags:
- `Feature` — New feature or capability
- `Bugfix` — Fixes a bug or issue
- `Refactor` — Code restructuring (no logic change)
- `Performance` — Optimization or efficiency improvement
- `Security` — Security-related change
- `Testing` — New test or test modification
- `Documentation` — Documentation-only change
- `Copilot Instructions` — Changes made per Copilot instructions
- `Integration` — Cross-service or API integration change
- `Maintenance` — Dependency updates, cleanup, etc.

### Examples

**Dart/Flutter Example:**
```dart
/// [2025-11-15 Feature] Enhanced offline sync with conflict resolution
/// 
/// Implements automatic retry logic for sync failures with exponential backoff.
/// Server wins on conflict for scoring data; client preserves user input.
Future<SyncResult> processSyncQueue() async {
  // Implementation...
}

/// [2025-11-15 Bugfix] Fixed authentication token expiration handling
///
/// Previously, expired tokens were not properly refreshed on subsequent requests.
/// Now checks token expiration before each API call.
Future<bool> isTokenValid() {
  // Implementation...
}
```

**JavaScript/Backend Example:**
```javascript
// [2025-11-15 Security] Validate game moves server-side
//
// Prevents cheating by ensuring all game logic is verified on the server.
// Client provides move data, server validates against game state.
app.post('/api/games/:gameId/validate-move', (req, res) => {
  // Implementation...
});

// [2025-11-15 Performance] Cache leaderboards in Redis
//
// Reduces database load by caching frequently-accessed leaderboard data.
// Cache invalidates on new scores or weekly reset.
const cachedLeaderboard = await redis.get('leaderboard:weekly');
```

### Inline Comments for Complex Logic

For complex implementations within functions, use inline comments:

```dart
// [2025-11-15 Integration] Process offline sync queue
Future<void> syncWithServer() async {
  // [2025-11-15 Logic] Check connectivity before attempting sync
  if (!await _isConnected()) {
    return;
  }
  
  // [2025-11-15 Logic] Fetch all unsynced moves from local database
  final queuedMoves = await _database.query('sync_queue');
  
  // [2025-11-15 Bugfix] Implement retry logic with exponential backoff
  for (int retry = 0; retry < 5; retry++) {
    try {
      await _apiService.sync(queuedMoves);
      break; // Success, exit retry loop
    } catch (e) {
      await Future.delayed(Duration(seconds: pow(2, retry).toInt()));
    }
  }
}
```

---

## Integration Points & External Dependencies

### Frontend Dependencies (pubspec.yaml)
- `provider: ^6.0` — Dependency injection & service access
- `socket_io_client: ^2.0` — Real-time multiplayer events
- `http: ^1.1` — REST API calls
- `sqflite: ^2.3` — Local SQLite database
- `shared_preferences: ^2.2` — Simple key-value storage (auth tokens, settings)
- `uuid: ^3.0` — Unique identifiers for games/turns

### Backend Stack
- **REST API**: Express.js + Node.js 18+
- **Multiplayer**: Socket.io + Node.js
- **Database**: PostgreSQL 15+
- **Cache**: Redis 7+ (session mgmt, leaderboard caching)
- **Containerization**: Docker + Docker Compose

### Server-Client Communication

**REST Endpoints** (`api_service.dart`):
- `POST /api/auth/register` — Create account
- `POST /api/auth/login` — Authenticate
- `GET /api/lobbies` — List lobbies
- `POST /api/games/{id}/validate-move` — Server-side move validation
- `GET /api/leaderboard` — Fetch rankings
- `POST /api/sync` — Offline sync (batch upload local changes)

**Socket.io Events** (`multiplayer_service.dart`):
- `create-lobby` → `lobby-created`
- `join-lobby` → `player-joined`, `player-left`
- `make-turn` → `turn-made` (broadcast to all players)
- `chat-message` → `message-received` (real-time messaging)
- `vote-skip` → `skip-voted` (threshold voting)

**Offline Sync Flow**:
1. Game move made locally → stored in `sync_queue` table (SQLite)
2. When online, `processSyncQueue()` uploads all queued moves
3. Server validates and updates game state
4. Server returns confirmed scores
5. Client updates local `user_progress` table

---

## Common Patterns & Examples

### Adding a New Game
1. Create game model in `models.dart` (e.g., `class SudokuPuzzle`)
2. Add to `GameCatalog._games` in `games/game_catalog.dart`
3. Create game screen in `screens/` (e.g., `sudoku_game_screen.dart`)
4. Implement game logic service in `services/` (e.g., `sudoku_service.dart`)
5. Call server validation: `apiService.validateMove(gameId, moveData)`
6. Update local progress: `offlineService.updateGameProgress(...)`

### Handling Offline/Online Transitions
```dart
// In a screen, listen to connectivity:
// When online detected → call offlineService.processSyncQueue()
// When offline detected → show "offline mode" indicator
// Use optimistic updates: update UI immediately, validate later
```

### Adding a New Service
1. Create `services/my_service.dart`
2. Add to `main.dart` service initialization
3. Provide via `Provider<MyService>.value(value: _myService)` in `MultiProvider`
4. Access in widgets via `Provider.of<MyService>(context)` or `context.read<MyService>()`

### Writing Tests
```dart
@GenerateMocks([ApiService])  // Generate mock
import 'my_test.mocks.dart';

void main() {
  late MyService service;
  late MockApiService mockApi;
  
  setUp(() {
    mockApi = MockApiService();
    service = MyService(apiService: mockApi);
  });
  
  test('does something', () async {
    when(mockApi.someCall(any)).thenAnswer((_) async => {...});
    final result = await service.someMethod();
    expect(result, equals(expected));
  });
}
```

---

## Debugging & Troubleshooting

**Alpha mode issues**: Check `kAlphaMode` in `main.dart`. When true, `LocalAuthService` is used; when false, `ApiService` is required.

**Offline sync failures**: Check `sync_queue` table in SQLite. Run `offlineService.processSyncQueue()` manually to debug.

**Socket.io connection errors**: Check `multiplayer_service.dart` connection setup. Verify backend multiplayer server (port 3001) is running.

**Server validation errors**: Review backend game route (`backend/api-server/src/routes/games.js`). All moves must be validated server-side.

**Database schema issues**: Ensure SQLite tables exist (`offline_games`, `user_progress`, `sync_queue`, `game_cache`). Use `offlineService._initDatabase()` to reset.

---

## Key Files to Review First

When onboarding to this codebase:
1. **Architecture**: `ARCHITECTURE.md`, `README.md`
2. **Entry point**: `lib/main.dart` (service setup + theme)
3. **Models**: `lib/models/models.dart` (all DTOs)
4. **Core services**: `lib/services/{auth,api,offline,multiplayer}_service.dart`
5. **Backend setup**: `backend/README.md` + `backend/docker-compose.yml`
6. **Testing example**: `test/auth_service_test.dart`
7. **Game catalog**: `lib/games/game_catalog.dart`

---

## Quick Commands

```bash
# Install dependencies
flutter pub get && cd backend && npm install

# Start backend locally
cd backend && docker-compose up -d

# Run app in alpha mode
flutter run --flavor alpha --dart-define=FLAVOR=alpha

# Run tests
flutter test

# Build release APK
./build-alpha.sh android

# Check API health
curl http://localhost:3000/health
```
