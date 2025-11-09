# Mind Wars 🧠⚔️

**Mind Wars** is an async multiplayer cognitive games platform supporting 2-10 players per lobby with cross-platform support for iOS 14+ and Android 8+.

## Development Philosophy

### Mobile-First 📱
Designed for 5" touch screens, then scales up. All UI elements are touch-optimized with minimum 48dp touch targets.

### Offline-First 📴
All games playable without connectivity. SQLite-based local storage with automatic sync queue and retry logic.

### API-First 🌐
RESTful design enables potential web version. Clean separation between client and server.

### Security-First 🔒
Server-side validation for all game logic. Client is thin client; server is authoritative source of truth.

### Data-Driven 📊
Instrumented analytics for A/B testing. Event-driven architecture for scalability.

### Progressive Enhancement 🚀
Core features first, polish iteratively. Optimistic updates with server confirmation.

## Features

### 🎮 Async Multiplayer
- **2-10 players** per lobby
- Turn-based gameplay system
- Real-time lobby management via Socket.io
- Automatic reconnection support
- Player status tracking (active/idle/disconnected)
- Async-first design: players can take turns hours apart

### 📱 Cross-Platform Support
- **iOS 14+** support
- **Android 8+** support
- Feature parity across platforms
- **Flutter** architecture for native performance

### 🎯 Game Variety
**12+ games across 5 cognitive categories:**

#### 🧠 Memory Games
- Memory Match - Match pairs of cards
- Sequence Recall - Remember and reproduce sequences
- Pattern Memory - Recreate visual patterns

#### 🧩 Logic Games
- Sudoku Duel - Competitive Sudoku solving
- Logic Grid - Deductive reasoning puzzles
- Code Breaker - Logical code-breaking challenges

#### 👁️ Attention Games
- Spot the Difference - Find differences quickly
- Color Rush - Match colors under pressure
- Focus Finder - Locate items in cluttered scenes

#### 🗺️ Spatial Games
- Puzzle Race - Complete jigsaw puzzles
- Rotation Master - Identify rotated shapes
- Path Finder - Navigate mazes efficiently

#### 📚 Language Games
- Word Builder - Create words from letters
- Anagram Attack - Solve anagrams quickly
- Vocabulary Showdown - Test vocabulary knowledge

### 💬 Social Features
- **In-game chat** with real-time messaging
- **Emoji reactions** (👍 ❤️ 😂 🎉 🔥 👏 😮 🤔)
- **Vote-to-skip mechanics** for game progression
- **Game voting system** - Players vote on which games to play
  - Configurable points per player
  - Vote across multiple rounds
  - Democratic game selection
- Player presence indicators

### 🏆 Progression System
- **Weekly leaderboards** with rankings
- **15+ badges** to unlock:
  - First Victory 🏆
  - Streak badges (3, 7, 30 days) 🔥
  - Games played milestones
  - Category mastery badges
  - Social achievements
- **Streak tracking** with multipliers (up to 2.0x)
- **Unified scoring system** across all games
- Level progression based on total score

### 📴 Offline Mode
- **All games playable offline** (Offline-First)
- Local puzzle solving with SQLite storage
- **Automatic sync** on reconnect with retry logic
- Sync queue for failed API calls
- Conflict resolution: Server wins for scoring, client preserves user input
- Progress tracking while offline

## Architecture

### Client-Server Model
- **Thin Client**: UI rendering, local game logic validation, offline caching
- **Authoritative Server**: Source of truth for game state, scoring, player matching
- **Rationale**: Prevents cheating; enables cross-device sync

### Offline Resilience
- Games stored locally in SQLite with sync queue
- Automatic retry logic for failed API calls (max 5 retries)
- Conflict resolution: Server wins for scoring validation
- Optimistic updates with server confirmation

### Microservices-Lite via Cloud Functions
- Modular functions for:
  - Authentication
  - Game logic validation
  - Notifications
  - Scoring & leaderboards
- Independent deployment and scaling
- Event-driven architecture
- Future-proof for containerized services

## Tech Stack

- **Flutter 3.0+** - Cross-platform mobile framework
- **Dart** - Type-safe development
- **Socket.io** - Real-time multiplayer communication
- **SQLite** - Local data persistence (Offline-First)
- **HTTP** - RESTful API communication
- **Provider** - State management

## Documentation

### 🎯 Getting Started (READ FIRST)
- **[GAMES_EVALUATION_AND_ROADMAP.md](GAMES_EVALUATION_AND_ROADMAP.md)** - ⭐ NEW: Game prioritization and implementation roadmap
- **[BACKLOG_GUIDE.md](BACKLOG_GUIDE.md)** - Quick reference guide to navigate all documentation
- **[docs/README.md](docs/README.md)** - ⭐ NEW: Complete documentation hub and navigation

### 📋 Planning & Strategy
- **[PRODUCT_BACKLOG.md](PRODUCT_BACKLOG.md)** - Prioritized backlog with Epics, Features, and Tasks (P0-P3)
- **[ROADMAP.md](ROADMAP.md)** - Visual 6-month roadmap with milestones and success metrics
- **[SPRINT_TEMPLATES.md](SPRINT_TEMPLATES.md)** - Sprint planning, standup, review, and retrospective templates

### 📚 Product Documentation
- **[USER_PERSONAS.md](USER_PERSONAS.md)** - 8 detailed user personas (Family, Friends, Office/Colleagues)
- **[USER_STORIES.md](USER_STORIES.md)** - Comprehensive user stories with acceptance criteria
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical architecture and implementation analysis
- **[VALIDATION.md](VALIDATION.md)** - Implementation validation checklist
- **[VOTING_SYSTEM.md](VOTING_SYSTEM.md)** - Game voting system documentation

### 🎯 Epic Implementation Summaries (NEW)
- **[EPIC_1_SUMMARY.md](EPIC_1_SUMMARY.md)** - Authentication & Onboarding implementation
- **[EPIC_2_SUMMARY.md](EPIC_2_SUMMARY.md)** - Lobby Management & Multiplayer implementation
- **[EPIC_3_IMPLEMENTATION.md](EPIC_3_IMPLEMENTATION.md)** - Core Gameplay Experience implementation
- **[EPIC_4_IMPLEMENTATION.md](EPIC_4_IMPLEMENTATION.md)** - ⭐ NEW: Cross-Platform & Reliability implementation

### 🗂️ Organized Documentation (NEW)
Comprehensive documentation is now organized in the `docs/` directory:
- **[docs/business/](docs/business/)** - Business strategy, market analysis, monetization
- **[docs/project/](docs/project/)** - Project management, technical specs, onboarding
- **[docs/social/](docs/social/)** - Social media, community, marketing strategy
- **[docs/games/](docs/games/)** - Game design documents and templates
- **[docs/research/](docs/research/)** - Research archives and analysis

Key documents:
- [Business Strategy Overview](docs/business/STRATEGY_OVERVIEW.md)
- [Market Analysis](docs/business/MARKET_ANALYSIS.md)
- [Developer Onboarding](docs/project/DEVELOPER_ONBOARDING.md)
- [Social Media Strategy](docs/social/SOCIAL_MEDIA_STRATEGY.md)
- [Game Design Template](docs/games/GAME_DESIGN_TEMPLATE.md)

### 🔬 Research Archives
Extensive research on game design and cognitive training:
- [Competitive Async MPG Research](docs/research/COMPETITIVE-ASYNC-MPG.md) - 25+ competitive games
- [Brain Training Games Research](docs/research/BRAIN_TRAINING_GAMES.md) - 18 cognitive games
- Original files also available in root: [COMPETITIVE-ASYNC-MPG.md](COMPETITIVE-ASYNC-MPG.md), [brain-training-games-research.md](brain-training-games-research.md)

## Project Structure

```
mind-wars/
├── lib/
│   ├── models/              # Data models
│   │   └── models.dart      # All app models
│   ├── services/            # Business logic services
│   │   ├── api_service.dart          # RESTful API client
│   │   ├── multiplayer_service.dart  # Multiplayer functionality
│   │   ├── offline_service.dart      # Offline mode & sync with SQLite
│   │   ├── progression_service.dart  # Leaderboards & badges
│   │   └── voting_service.dart       # Game voting system
│   ├── games/               # Game implementations
│   │   └── game_catalog.dart         # Game catalog (12+ games)
│   ├── screens/             # Screen widgets
│   ├── widgets/             # Reusable UI widgets
│   └── main.dart            # Main app entry point
├── test/                    # Test files
├── pubspec.yaml             # Dependencies
├── USER_PERSONAS.md         # User personas documentation
├── USER_STORIES.md          # User stories (Epics/Features/Tasks)
└── README.md
```

## Installation

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Xcode 14+ (for iOS development)
- Android Studio (for Android development)

### Setup

```bash
# Install Flutter dependencies
flutter pub get

# Run on iOS simulator (macOS only)
flutter run -d ios

# Run on Android emulator
flutter run -d android

# Build for production
flutter build apk          # Android
flutter build ios          # iOS
```

## Development

```bash
# Run the app
flutter run

# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
flutter format lib/
```

## API Requirements

The app expects the following backend endpoints:

### Multiplayer Server (Socket.io)
- WebSocket connection support
- Events: `create-lobby`, `join-lobby`, `leave-lobby`, `start-game`, `make-turn`
- Chat events: `chat-message`, `emoji-reaction`
- Vote events: `vote-skip`
- Voting events: `start-voting`, `vote-game`, `remove-vote`, `end-voting`
- Voting notifications: `voting-started`, `vote-cast`, `voting-update`, `voting-ended`

### REST API (Server-Side Validation)
Authentication:
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user
- `POST /auth/logout` - Logout user

Game Management:
- `GET /lobbies` - Get available lobbies
- `POST /lobbies` - Create lobby
- `GET /lobbies/:id` - Get lobby details
- `GET /games` - Get available games
- `POST /games/:id/submit` - Submit game result (with validation)
- `POST /games/:id/validate-move` - Validate game move

Progression:
- `GET /leaderboard/weekly` - Get weekly leaderboard
- `GET /leaderboard/all-time` - Get all-time leaderboard
- `GET /users/:id` - Get user profile
- `GET /users/:id/progress` - Get user progress

Sync (Offline-First):
- `POST /sync/game` - Sync offline game data
- `POST /sync/progress` - Sync user progress
- `POST /sync/batch` - Batch sync multiple games

Analytics:
- `POST /analytics/track` - Track event
- `GET /ab-test/:name` - Get A/B test variant

## Configuration

Configure the API endpoint in your app:

```dart
// lib/main.dart
final apiService = ApiService(
  baseUrl: 'https://api.mindwars.app', // Your API endpoint
);

// Connect to multiplayer
await multiplayerService.connect(
  'wss://multiplayer.mindwars.app',
  playerId,
);

// Sync offline data (automatic on reconnect)
await offlineService.syncWithServer(
  'https://api.mindwars.app',
  userId,
);
```

## Platform Requirements

### iOS
- iOS 14.0 or higher
- Xcode 14.0 or higher (for development)

### Android
- Android 8.0 (API level 26) or higher
- Android Studio 2022.1+ (for development)
- Gradle 7.5+

## Features Implementation Status

### Epic 1: Authentication & Onboarding ✅
- ✅ User registration and login
- ✅ Profile creation and customization
- ✅ Onboarding flow with tutorial
- ✅ Password validation and security

### Epic 2: Lobby Management & Multiplayer ✅
- ✅ Async multiplayer (2-10 players)
- ✅ Lobby creation and joining
- ✅ Real-time communication via Socket.io
- ✅ Player presence tracking
- ✅ In-game chat with emoji reactions
- ✅ Vote-to-skip mechanics

### Epic 3: Core Gameplay Experience ✅
- ✅ 15+ games across 5 cognitive categories
- ✅ Game voting system (democratic game selection)
- ✅ Turn-based gameplay
- ✅ Unified scoring system with bonuses
- ✅ Game state persistence
- ✅ Hint system and daily challenges

### Epic 4: Cross-Platform & Reliability ✅ (NEW)
- ✅ **iOS 14+ and Android 8+ (API 26) full support**
- ✅ **Native platform configurations (Info.plist, AndroidManifest.xml)**
- ✅ **Platform service with iOS/Android feature parity**
- ✅ **Responsive UI supporting 5" to 12" screens**
- ✅ **Portrait and landscape orientation support**
- ✅ **Minimum 48dp touch targets (accessibility)**
- ✅ **Enhanced offline mode with turn queue**
- ✅ **Automatic sync on reconnect with conflict resolution**
- ✅ **Offline mode indicator UI with status tracking**
- ✅ **Local puzzle solver for single-player practice**
- ✅ **Material Design 3 (Android) and Human Interface Guidelines (iOS)**

### Progression & Social ✅
- ✅ Progression system (leaderboards, badges, streaks)
- ✅ Weekly and all-time leaderboards
- ✅ 15+ badge achievements
- ✅ Streak tracking with multipliers

### Architecture & Infrastructure ✅
- ✅ Offline-first architecture with SQLite
- ✅ Sync queue with retry logic (max 5 retries)
- ✅ Conflict resolution (server wins)
- ✅ RESTful API with server-side validation
- ✅ Security-first (server-side validation, anti-cheating)
- ✅ Mobile-first design (5" touch screens scaling to 12" tablets)
- ✅ Analytics instrumentation

## License

MIT

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

---

Built with ❤️ using Flutter
