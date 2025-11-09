# Mind Wars - Developer Onboarding

**Purpose**: Comprehensive onboarding guide for new developers  
**Author**: Engineering Team  
**Last Updated**: 2025-11-09  
**Status**: Active  
**Version**: 1.0

---

## Welcome to Mind Wars! 🎮

Welcome to the Mind Wars development team! This guide will help you get set up and productive quickly.

---

## Quick Start

### Prerequisites

**Required Software**:
- Flutter SDK 3.0+ ([install guide](https://flutter.dev/docs/get-started/install))
- Dart SDK 3.0+
- Git
- VS Code or Android Studio
- Xcode 14+ (macOS only, for iOS development)
- Android Studio (for Android development)

**Accounts Needed**:
- GitHub access (request from team lead)
- Firebase project access
- Slack workspace invitation
- Jira/project management tool access

### Setup Steps

```bash
# 1. Clone the repository
git clone https://github.com/tescolopio/mind-wars.git
cd mind-wars

# 2. Install Flutter dependencies
flutter pub get

# 3. Verify installation
flutter doctor

# 4. Run on simulator/emulator
flutter run -d ios    # iOS simulator (macOS only)
flutter run -d android  # Android emulator

# 5. Run tests
flutter test

# 6. Check code quality
flutter analyze
```

### First Day Checklist

- [ ] Complete setup steps above
- [ ] Read this entire document
- [ ] Review [Architecture](TECHNICAL_ARCHITECTURE.md)
- [ ] Review [Product Backlog](../../PRODUCT_BACKLOG.md)
- [ ] Review [User Personas](../../USER_PERSONAS.md)
- [ ] Join team Slack channels
- [ ] Set up development environment
- [ ] Run app locally on iOS/Android
- [ ] Run full test suite
- [ ] Complete first "good first issue"

---

## Project Structure

```
mind-wars/
├── lib/                      # Main application code
│   ├── models/              # Data models
│   │   └── models.dart      # All app models
│   ├── services/            # Business logic services
│   │   ├── api_service.dart
│   │   ├── multiplayer_service.dart
│   │   ├── offline_service.dart
│   │   └── voting_service.dart
│   ├── games/               # Game implementations
│   │   └── game_catalog.dart
│   ├── screens/             # Screen widgets
│   ├── widgets/             # Reusable UI widgets
│   └── main.dart            # App entry point
├── test/                    # Test files
├── docs/                    # Documentation
└── pubspec.yaml             # Dependencies
```

---

## Development Workflow

### Git Workflow

**Branch Naming**:
- `feature/[ticket-id]-description` - New features
- `bugfix/[ticket-id]-description` - Bug fixes
- `hotfix/[ticket-id]-description` - Production hotfixes
- `chore/description` - Non-feature work (deps, docs)

**Example**: `feature/MW-123-memory-matrix-game`

**Commit Message Format**:
```
[Ticket ID] Brief description (50 chars or less)

More detailed explanation if needed (wrap at 72 chars).
- Bullet points for multiple changes
- Separate concerns logically

Refs: #ticket-number
```

**Example**:
```
[MW-123] Add Memory Matrix game implementation

- Implement grid generation and randomization
- Add scoring logic based on accuracy and speed
- Create UI with responsive grid layout
- Add unit tests for game logic

Refs: #123
```

**Pull Request Process**:
1. Create branch from `main`
2. Make changes and commit with descriptive messages
3. Push branch to GitHub
4. Create pull request with template
5. Request review from at least 1 team member
6. Address review feedback
7. Merge after approval (squash merge preferred)

### Code Review Standards

**Before Requesting Review**:
- [ ] Code runs without errors
- [ ] All tests pass (`flutter test`)
- [ ] Code analysis clean (`flutter analyze`)
- [ ] Added tests for new functionality
- [ ] Updated documentation if needed
- [ ] Tested on both iOS and Android
- [ ] Followed code style guidelines

**As Reviewer**:
- Review within 24 hours
- Provide constructive feedback
- Test the changes locally if significant
- Check for edge cases and errors
- Verify tests are adequate
- Approve or request changes clearly

---

## Coding Standards

### Flutter/Dart Style

**Follow Official Guidelines**:
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Style Guide](https://flutter.dev/docs/development/ui/layout/constraints)

**Key Conventions**:
```dart
// Use lowercase with underscores for file names
// file: memory_matrix_game.dart

// Use UpperCamelCase for class names
class MemoryMatrixGame extends StatefulWidget {
  // Use lowerCamelCase for variable and method names
  final int gridSize;
  final Function(int) onScoreUpdate;

  // Use const constructors when possible
  const MemoryMatrixGame({
    Key? key,
    required this.gridSize,
    required this.onScoreUpdate,
  }) : super(key: key);

  @override
  State<MemoryMatrixGame> createState() => _MemoryMatrixGameState();
}

// Private classes start with underscore
class _MemoryMatrixGameState extends State<MemoryMatrixGame> {
  // Group and order class members logically:
  // 1. Static members
  // 2. Instance variables
  // 3. Constructor
  // 4. Lifecycle methods
  // 5. Helper methods

  @override
  Widget build(BuildContext context) {
    // Use const widgets when possible
    return const Text('Memory Matrix');
  }
}
```

**Code Organization**:
- Keep files under 500 lines (extract if larger)
- One class per file (exceptions: private helper classes)
- Group related functionality in services
- Separate business logic from UI

### Testing Standards

**Test Coverage Target**: 80%+ for services and models

**Test Structure**:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_wars/services/scoring_service.dart';

void main() {
  group('ScoringService', () {
    late ScoringService service;

    setUp(() {
      service = ScoringService();
    });

    test('calculates score correctly with no hints', () {
      // Arrange
      const seconds = 30;
      const hints = 0;
      const perfect = true;

      // Act
      final score = service.calculateScore(
        seconds: seconds,
        hints: hints,
        perfect: perfect,
      );

      // Assert
      expect(score, equals(125)); // 90-30 + 20 + 15 + 30
    });

    test('applies hint penalty correctly', () {
      // Test with hints used
    });

    // More tests...
  });
}
```

**Testing Best Practices**:
- Write tests first (TDD) for complex logic
- Test edge cases and error conditions
- Use meaningful test descriptions
- Mock external dependencies
- Keep tests fast (< 1 second each)

---

## Architecture Overview

### Key Technologies

**Frontend**:
- **Flutter 3.0+**: Cross-platform mobile framework
- **Dart**: Type-safe programming language
- **Provider**: State management
- **SQLite**: Local persistence

**Backend** (separate repo):
- **Node.js**: Server runtime
- **Socket.io**: Real-time multiplayer
- **Firebase**: Authentication, database, hosting
- **PostgreSQL**: Relational data storage

**Infrastructure**:
- **GitHub**: Version control
- **GitHub Actions**: CI/CD
- **Firebase Hosting**: App distribution
- **Sentry**: Error tracking

### Data Flow

```
User Action
    ↓
Widget (UI Layer)
    ↓
Provider (State Management)
    ↓
Service (Business Logic)
    ↓ ↓
API Service         Offline Service
    ↓                   ↓
Backend API         SQLite Database
```

### State Management

We use **Provider** for state management:

```dart
// 1. Define state model
class GameState extends ChangeNotifier {
  int _score = 0;

  int get score => _score;

  void updateScore(int newScore) {
    _score = newScore;
    notifyListeners(); // Triggers UI rebuild
  }
}

// 2. Provide state at app level
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameState()),
        // Other providers...
      ],
      child: MyApp(),
    ),
  );
}

// 3. Consume state in widgets
class ScoreDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Listen to changes
    final gameState = context.watch<GameState>();
    return Text('Score: ${gameState.score}');
  }
}

// 4. Update state
context.read<GameState>().updateScore(100);
```

---

## Common Tasks

### Adding a New Game

1. **Design Phase**:
   - Review game design document in `docs/games/`
   - Understand rules, scoring, and UI requirements
   - Identify required models and services

2. **Implementation**:
   ```dart
   // Create game file: lib/games/memory_matrix_game.dart
   // Extend base game class or StatefulWidget
   // Implement game logic, UI, and scoring
   ```

3. **Add to Catalog**:
   ```dart
   // In lib/games/game_catalog.dart
   GameDefinition(
     id: 'memory-matrix',
     name: 'Memory Matrix',
     category: GameCategory.memory,
     minPlayers: 2,
     maxPlayers: 10,
     builder: (context) => MemoryMatrixGame(),
   )
   ```

4. **Testing**:
   - Write unit tests for game logic
   - Test on both iOS and Android
   - Test with multiple players
   - Verify scoring integration

5. **Documentation**:
   - Update game design doc
   - Add in-game tutorial
   - Update README if needed

### Adding a New Feature

1. Review feature spec in Product Backlog
2. Create feature branch
3. Implement following architecture patterns
4. Add tests (unit + integration)
5. Update documentation
6. Create pull request
7. Address review feedback
8. Merge and deploy

### Fixing a Bug

1. Reproduce bug locally
2. Write failing test that exposes bug
3. Fix bug
4. Verify test passes
5. Check for related bugs
6. Submit pull request
7. Mark ticket as resolved

---

## Testing & QA

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/scoring_service_test.dart

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Run integration tests
flutter drive --target=test_driver/app.dart
```

### Testing Checklist

Before submitting PR:
- [ ] All unit tests pass
- [ ] Code coverage maintained or improved
- [ ] Tested on iOS simulator
- [ ] Tested on Android emulator
- [ ] Tested on real device (if UI changes)
- [ ] Tested offline mode (if relevant)
- [ ] Tested with poor network conditions
- [ ] Tested edge cases and error conditions

### Manual Testing Focus Areas

**Critical Paths**:
- User registration and login
- Lobby creation and joining
- Game voting
- Turn-based gameplay
- Scoring and validation
- Chat and social features
- Offline sync

**Edge Cases**:
- Poor network connectivity
- App backgrounding/foregrounding
- Device rotation
- Different screen sizes
- Accessibility features (VoiceOver, TalkBack)
- Multiple simultaneous games

---

## Debugging Tips

### Common Issues

**Issue**: "Package not found" error
```bash
# Solution: Clean and reinstall dependencies
flutter clean
flutter pub get
```

**Issue**: iOS build fails
```bash
# Solution: Update pods
cd ios
pod install
cd ..
flutter run
```

**Issue**: Hot reload not working
```bash
# Solution: Do hot restart (R key) or full rebuild
# Press 'R' in terminal where flutter run is running
# Or stop and run again
```

### Debugging Tools

**Flutter DevTools**:
```bash
# Launch DevTools
flutter pub global activate devtools
flutter pub global run devtools
# Open browser at http://localhost:9100
```

**Logging**:
```dart
import 'package:flutter/foundation.dart';

// Use debugPrint for logging
debugPrint('User score updated: $score');

// Conditional logging in production
if (kDebugMode) {
  print('Debug info: $data');
}
```

**Breakpoints**: Use IDE breakpoints for step-through debugging

---

## Resources

### Documentation

**Internal**:
- [Technical Architecture](TECHNICAL_ARCHITECTURE.md)
- [API Documentation](API_DOCUMENTATION.md)
- [Testing Strategy](TESTING_STRATEGY.md)
- [Deployment Guide](DEPLOYMENT_GUIDE.md)

**External**:
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Firebase Documentation](https://firebase.google.com/docs)

### Team Communication

**Slack Channels**:
- `#engineering` - Technical discussions
- `#general` - Company-wide announcements
- `#product` - Product updates and feedback
- `#design` - Design reviews and feedback
- `#random` - Non-work chat

**Meetings**:
- **Daily Standup**: 9:30 AM, 15 minutes
- **Sprint Planning**: Every other Monday, 2 hours
- **Sprint Review**: Every other Friday, 1 hour
- **Retrospective**: Every other Friday, 1 hour
- **1-on-1s**: Weekly with manager

### Getting Help

**Technical Questions**:
1. Search documentation and codebase
2. Ask in #engineering Slack channel
3. Schedule pairing session with teammate
4. Escalate to tech lead if blocked

**Product Questions**:
1. Review product backlog and user stories
2. Ask in #product Slack channel
3. Schedule meeting with product manager

---

## Career Growth

### Learning Path

**Junior Developer** → **Mid-Level Developer**:
- Master Flutter and Dart
- Understand full architecture
- Write comprehensive tests
- Review others' code effectively
- Take ownership of features

**Mid-Level** → **Senior Developer**:
- Design system architecture
- Mentor junior developers
- Lead technical initiatives
- Influence product decisions
- Handle on-call and production issues

**Growth Opportunities**:
- Lead game implementation
- Own a service (e.g., multiplayer, offline)
- Speak at team knowledge-shares
- Contribute to open source
- Write technical blog posts

---

## FAQ

**Q: What should I work on first?**  
A: Start with issues tagged "good first issue" in Jira. These are well-scoped tasks perfect for learning the codebase.

**Q: How do I know what to prioritize?**  
A: Check the current sprint backlog. Your manager will assign priority items. When in doubt, ask!

**Q: Can I refactor code I see that needs improvement?**  
A: Small refactors in files you're already touching are fine. Larger refactors should be discussed with team and tracked as separate tickets.

**Q: What if I break something in production?**  
A: Don't panic! Alert the team immediately, help debug the issue, and learn from it. We have rollback procedures.

**Q: How do I request time off?**  
A: Submit in HR system and notify your manager and team in advance (preferably 2+ weeks).

---

**Welcome to the team! We're excited to have you here. 🎉**

---

**Document Version**: 1.0  
**Last Updated**: 2025-11-09  
**Owner**: Engineering Team  
**Review Frequency**: Quarterly
