# Vocabulary Showdown Game - Production Implementation

## Overview

The Vocabulary Showdown game is a production-ready, Mind Wars–compliant async multiplayer vocabulary game that tests players' knowledge of word definitions through rapid-fire rounds with adaptive difficulty.

## Architecture

### Service Layer
- **VocabularyGameService**: Core game logic separated from UI
  - Session management with seed-based generation
  - Question generation with difficulty distribution
  - Answer processing with automatic scoring
  - Adaptive difficulty tracking

### Models
- **VocabularyWord**: Complete word metadata including SRS fields
- **VocabularyQuestion**: Question with type, options, and timing
- **VocabularyAnswer**: Player answer with timing and scoring
- **VocabularyGameSession**: Complete game session state

### Utilities
- **VocabularyScoringUtility**: Mind Wars-compliant scoring system
- **VocabularyGameUtilities**: Game mechanics helpers
- **VocabularyAssetLoader**: Asset loading for word data

## Scoring System

### Hybrid Scoring Formula
```
AccuracyPoints = correct ? 1000 : 0
SpeedPoints = max(200, 1000 * (1 - timeTaken/maxTime))
RawScore = (AccuracyPoints * 0.7) + (SpeedPoints * 0.3)
QuestionScore = round(RawScore * DifficultyMultiplier)
```

### Difficulty Multipliers
- **Tier 1**: 1.0x (difficulty 1-2)
- **Tier 2**: 1.5x (difficulty 3-5)
- **Tier 3**: 2.0x (difficulty 6-8)
- **Tier 4**: 2.5x (difficulty 9-10)

### Streak Bonuses (Capped)
- **3 questions**: +100 points
- **5 questions**: +300 points
- **7 questions**: +500 points
- **10+ questions**: +1000 points (maximum)

## Adaptive Difficulty

The game automatically adjusts difficulty based on player performance:

- **Target success rate**: ~70%
- **Rolling window**: Last 10 questions
- **Adjustment strategy**:
  - Success rate > 85%: Increase difficulty
  - Success rate < 40%: Decrease difficulty significantly
  - Success rate < 65%: Decrease difficulty slightly
  - Success rate 65-85%: Maintain current difficulty

### Exponential Smoothing
```dart
newDifficulty = 0.3 * candidateDifficulty + 0.7 * currentDifficulty
```

This prevents rapid swings and provides a smoother player experience.

## Game Flow

1. **Session Creation**: Service generates 10 questions with seed-based determinism
2. **Question Display**: UI shows word and 4 multiple-choice options
3. **Answer Processing**: Service calculates score based on accuracy and speed
4. **Feedback**: UI displays points earned, streak, and correct answer (if wrong)
5. **Next Question**: Load next question or complete game
6. **Adaptive Adjustment**: Service updates difficulty between games

## Multiplayer Features

### Deterministic Generation
- Questions are generated using a **seed** for reproducibility
- All players with the same seed get identical question order and options
- Ensures fairness in async multiplayer matches

### Anti-Repetition
- Tracks used words within a session to prevent duplicates
- Automatically resets pool when exhausted

## Question Types (MVP)

Current implementation supports **Multiple Choice Questions (MCQ)** only:
- 60% MCQ (implemented)
- 30% Fill-in-blank (planned)
- 10% Synonyms/Antonyms (planned)

## Timers

Time limits vary by question type and difficulty:
- **MCQ Base**: 25 seconds
- **Fill-in Base**: 35 seconds
- **Syn/Ant Base**: 30 seconds

**Difficulty Adjustments**:
- Tier 1: -5 seconds
- Tier 2: base time
- Tier 3: +5 seconds
- Tier 4: +10 seconds

## Word Database

### Alpha Version (Current)
- **15 words** included in code for testing
- Difficulty range: 2-4 (tiers 1-3)
- CEFR levels: B1, B2, C1

### Asset File
- `assets/words_small.json`: Structured word data
- Includes: definition, part of speech, difficulty, frequency, examples, synonyms, CEFR level

### Production Version (Planned)
- **800-1000 words** in MVP asset
- Server master database for full catalog
- Spaced repetition tracking per user

## Testing

### Unit Tests (75+ test cases)
- **vocabulary_scoring_utility_test.dart**: 35+ tests
  - Scoring formula validation
  - Edge cases (0 time, max time, streak caps)
  - Difficulty multipliers
  - Score validation (anti-cheating)
  
- **vocabulary_game_utilities_test.dart**: 40+ tests
  - Deterministic shuffle verification
  - Adaptive difficulty adjustments
  - Question type distribution
  - Answer validation

- **vocabulary_asset_loader_test.dart**: 5+ tests
  - JSON parsing
  - Optional fields handling
  - Error cases

### Integration Tests (Planned)
- Turn replay: Server replays client payload
- Offline sync: Provisional score reconciliation
- Session state persistence

## Usage

### Basic Usage
```dart
// Create game service
final service = VocabularyGameService();

// Create session
final session = service.createSession(
  gameId: 'game_123',
  playerId: 'player_456',
  questionCount: 10,
);

// Get current question
final question = service.getCurrentQuestion(session);

// Process answer
final updatedSession = service.processAnswer(
  session: session,
  selectedOptionIndex: 2,
  timeTakenMs: 5000.0,
);

// Update difficulty between games
service.updateDifficulty();
```

### Using Custom Word Pool
```dart
// Load words from asset
final words = await VocabularyAssetLoader.loadWords();

// Create service with custom words
final service = VocabularyGameService(wordPool: words);
```

## Future Enhancements

### Sprint 2 (Weeks 2-3)
- [ ] Implement fill-in-blank questions
- [ ] Implement synonym/antonym questions
- [ ] Add visual timer countdown
- [ ] Show detailed score breakdown after each question
- [ ] Display example sentences for incorrect answers

### Sprint 3 (Weeks 4-6)
- [ ] Server-authoritative turn submission
- [ ] Offline mode with provisional scoring
- [ ] ELO-based matchmaking
- [ ] Normalized percentile scoring for leaderboards
- [ ] Analytics telemetry

### Sprint 4 (Weeks 7-10)
- [ ] Accessibility features (screen readers, high contrast)
- [ ] Post-match review mode
- [ ] Spaced repetition tracking (SM-2 algorithm)
- [ ] Audio pronunciation support
- [ ] Extended word database (800-1000 words)

## API Endpoints (Planned)

### Turn Submission
```
POST /api/games/{gameId}/turn
Body: {
  gameId, playerId, seed, questionSetId,
  answers: [{questionId, selectedOptionIndex, timeTakenMs}],
  clientTimestamp
}
Response: {
  finalScore, normalizedPercent, updatedPlayerStats
}
```

### Session Request
```
GET /api/games/{gameId}/session
Response: {
  seed, questionSet, timers, difficultyDistribution
}
```

## Performance Considerations

- **Deterministic Generation**: O(n log n) for shuffling n questions
- **Score Calculation**: O(1) per question
- **Memory**: ~100KB for 1000-word pool
- **Session State**: ~10KB per active session

## Anti-Cheating Measures

1. **Score Validation**: Server verifies client-submitted scores don't exceed maximum possible
2. **Time Validation**: Minimum 100ms per question (human reaction time)
3. **Deterministic Replay**: Server can replay entire session using seed
4. **Impossibility Checks**: Score bounds checking per difficulty tier

## Accessibility

Current:
- Large touch targets (60dp height)
- High contrast color scheme
- Disabled state for buttons during processing

Planned:
- Screen reader labels
- Audio pronunciation
- Dyslexia-friendly font option
- Adjustable timer durations
- Colorblind-friendly indicators

## License

Part of Mind Wars - Async Multiplayer Cognitive Games Platform
