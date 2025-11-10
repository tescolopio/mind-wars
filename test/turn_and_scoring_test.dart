/**
 * Tests for Turn Management and Scoring Services
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_wars/services/turn_management_service.dart';
import 'package:mind_wars/services/scoring_service.dart';
import 'package:mind_wars/services/api_service.dart';
import 'package:mind_wars/models/models.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ApiService])
import 'turn_and_scoring_test.mocks.dart';

void main() {
  group('ScoringService', () {
    late ScoringService scoringService;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      scoringService = ScoringService(mockApiService);
    });

    test('should calculate score correctly', () {
      final score = scoringService.calculateScore(
        gameId: 'game1',
        playerId: 'player1',
        baseScore: 100,
        timeSeconds: 30,
        accuracy: 1.0,
        currentStreak: 0,
      );

      expect(score.baseScore, equals(100));
      expect(score.timeBonus, equals(500)); // < 30 seconds
      expect(score.accuracyBonus, equals(300)); // 100% accuracy
      expect(score.streakMultiplier, equals(1.0)); // No streak
      expect(score.finalScore, equals(900)); // (100 + 500 + 300) * 1.0
    });

    test('should apply streak multiplier correctly', () {
      final scores = [
        scoringService.calculateScore(
          gameId: 'game1',
          playerId: 'player1',
          baseScore: 100,
          timeSeconds: 60,
          accuracy: 1.0,
          currentStreak: 0,
        ),
        scoringService.calculateScore(
          gameId: 'game1',
          playerId: 'player1',
          baseScore: 100,
          timeSeconds: 60,
          accuracy: 1.0,
          currentStreak: 3,
        ),
        scoringService.calculateScore(
          gameId: 'game1',
          playerId: 'player1',
          baseScore: 100,
          timeSeconds: 60,
          accuracy: 1.0,
          currentStreak: 7,
        ),
        scoringService.calculateScore(
          gameId: 'game1',
          playerId: 'player1',
          baseScore: 100,
          timeSeconds: 60,
          accuracy: 1.0,
          currentStreak: 30,
        ),
      ];

      expect(scores[0].streakMultiplier, equals(1.0));
      expect(scores[1].streakMultiplier, equals(1.1));
      expect(scores[2].streakMultiplier, equals(1.3));
      expect(scores[3].streakMultiplier, equals(2.0));

      // Check final scores increase with streak
      expect(scores[0].finalScore, lessThan(scores[1].finalScore));
      expect(scores[1].finalScore, lessThan(scores[2].finalScore));
      expect(scores[2].finalScore, lessThan(scores[3].finalScore));
    });

    test('should calculate time bonus correctly', () {
      final scores = [
        scoringService.calculateScore(
          gameId: 'game1',
          playerId: 'player1',
          baseScore: 100,
          timeSeconds: 25,
          accuracy: 0.5,
          currentStreak: 0,
        ),
        scoringService.calculateScore(
          gameId: 'game1',
          playerId: 'player1',
          baseScore: 100,
          timeSeconds: 50,
          accuracy: 0.5,
          currentStreak: 0,
        ),
        scoringService.calculateScore(
          gameId: 'game1',
          playerId: 'player1',
          baseScore: 100,
          timeSeconds: 100,
          accuracy: 0.5,
          currentStreak: 0,
        ),
        scoringService.calculateScore(
          gameId: 'game1',
          playerId: 'player1',
          baseScore: 100,
          timeSeconds: 350,
          accuracy: 0.5,
          currentStreak: 0,
        ),
      ];

      expect(scores[0].timeBonus, equals(500)); // < 30s
      expect(scores[1].timeBonus, equals(300)); // < 60s
      expect(scores[2].timeBonus, equals(150)); // < 120s
      expect(scores[3].timeBonus, equals(0)); // > 300s
    });

    test('should calculate accuracy bonus correctly', () {
      final perfectAccuracy = scoringService.calculateScore(
        gameId: 'game1',
        playerId: 'player1',
        baseScore: 100,
        timeSeconds: 60,
        accuracy: 1.0,
        currentStreak: 0,
      );

      final halfAccuracy = scoringService.calculateScore(
        gameId: 'game1',
        playerId: 'player1',
        baseScore: 100,
        timeSeconds: 60,
        accuracy: 0.5,
        currentStreak: 0,
      );

      final zeroAccuracy = scoringService.calculateScore(
        gameId: 'game1',
        playerId: 'player1',
        baseScore: 100,
        timeSeconds: 60,
        accuracy: 0.0,
        currentStreak: 0,
      );

      expect(perfectAccuracy.accuracyBonus, equals(300));
      expect(halfAccuracy.accuracyBonus, equals(150));
      expect(zeroAccuracy.accuracyBonus, equals(0));
    });

    test('should validate score data', () {
      expect(
        scoringService.validateScoreData(
          baseScore: 100,
          timeSeconds: 60,
          accuracy: 0.8,
          gameData: {'moves': []},
        ),
        isTrue,
      );

      // Negative base score
      expect(
        scoringService.validateScoreData(
          baseScore: -100,
          timeSeconds: 60,
          accuracy: 0.8,
          gameData: {'moves': []},
        ),
        isFalse,
      );

      // Invalid accuracy
      expect(
        scoringService.validateScoreData(
          baseScore: 100,
          timeSeconds: 60,
          accuracy: 1.5,
          gameData: {'moves': []},
        ),
        isFalse,
      );

      // Impossibly fast time
      expect(
        scoringService.validateScoreData(
          baseScore: 100,
          timeSeconds: 2,
          accuracy: 0.8,
          gameData: {'moves': []},
        ),
        isFalse,
      );

      // Empty game data
      expect(
        scoringService.validateScoreData(
          baseScore: 100,
          timeSeconds: 60,
          accuracy: 0.8,
          gameData: {},
        ),
        isFalse,
      );
    });

    test('should get score breakdown', () {
      final score = scoringService.calculateScore(
        gameId: 'game1',
        playerId: 'player1',
        baseScore: 100,
        timeSeconds: 30,
        accuracy: 0.8,
        currentStreak: 7,
      );

      final breakdown = scoringService.getScoreBreakdown(score);

      expect(breakdown['baseScore'], equals(100));
      expect(breakdown['timeBonus'], equals(500));
      expect(breakdown['accuracyBonus'], equals(240));
      expect(breakdown['subtotal'], equals(840));
      expect(breakdown['streakMultiplier'], equals(1.3));
      expect(breakdown['finalScore'], equals(score.finalScore));
    });
  });

  group('TurnManagementService', () {
    late TurnManagementService turnService;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      turnService = TurnManagementService(mockApiService);
    });

    test('should track current game', () {
      expect(turnService.currentGame, isNull);

      final game = Game(
        id: 'game1',
        name: 'Test Game',
        category: CognitiveCategory.memory,
        description: 'Test',
        minPlayers: 2,
        maxPlayers: 4,
        currentTurn: 0,
        currentPlayerId: 'player1',
        state: {},
        completed: false,
      );

      turnService.setCurrentGame(game);
      expect(turnService.currentGame, equals(game));
    });

    test('should identify whose turn it is', () {
      final game = Game(
        id: 'game1',
        name: 'Test Game',
        category: CognitiveCategory.memory,
        description: 'Test',
        minPlayers: 2,
        maxPlayers: 4,
        currentTurn: 0,
        currentPlayerId: 'player1',
        state: {},
        completed: false,
      );

      turnService.setCurrentGame(game);

      expect(turnService.currentTurnPlayerId, equals('player1'));
      expect(turnService.isPlayerTurn('player1'), isTrue);
      expect(turnService.isPlayerTurn('player2'), isFalse);
    });

    test('should validate turn data', () {
      final game = Game(
        id: 'game1',
        name: 'Test Game',
        category: CognitiveCategory.memory,
        description: 'Test',
        minPlayers: 2,
        maxPlayers: 4,
        currentTurn: 0,
        currentPlayerId: 'player1',
        state: {},
        completed: false,
      );

      turnService.setCurrentGame(game);

      expect(
        turnService.validateTurnData({'action': 'move', 'position': 5}),
        isTrue,
      );

      expect(turnService.validateTurnData({}), isFalse);
      expect(turnService.validateTurnData({'position': 5}), isFalse);
    });

    test('should track turn history', () {
      expect(turnService.turnHistory.isEmpty, isTrue);

      final game = Game(
        id: 'game1',
        name: 'Test Game',
        category: CognitiveCategory.memory,
        description: 'Test',
        minPlayers: 2,
        maxPlayers: 4,
        currentTurn: 0,
        currentPlayerId: 'player1',
        state: {},
        completed: false,
      );

      turnService.setCurrentGame(game);
      expect(turnService.currentTurnNumber, equals(0));
    });

    test('should calculate game progress', () {
      final game = Game(
        id: 'game1',
        name: 'Test Game',
        category: CognitiveCategory.memory,
        description: 'Test',
        minPlayers: 2,
        maxPlayers: 4,
        currentTurn: 50,
        currentPlayerId: 'player1',
        state: {'totalTurns': 100},
        completed: false,
      );

      turnService.setCurrentGame(game);
      expect(turnService.getGameProgress(), equals(0.5));
    });

    test('should clear game and history', () {
      final game = Game(
        id: 'game1',
        name: 'Test Game',
        category: CognitiveCategory.memory,
        description: 'Test',
        minPlayers: 2,
        maxPlayers: 4,
        currentTurn: 0,
        currentPlayerId: 'player1',
        state: {},
        completed: false,
      );

      turnService.setCurrentGame(game);
      expect(turnService.currentGame, isNotNull);

      turnService.clearGame();
      expect(turnService.currentGame, isNull);
      expect(turnService.turnHistory.isEmpty, isTrue);
    });
  });
}
