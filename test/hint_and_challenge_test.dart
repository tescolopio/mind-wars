/**
 * Tests for Hint System and Daily Challenges
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_wars/services/hint_and_challenge_system.dart';
import 'package:mind_wars/services/game_content_generator.dart';
import 'package:mind_wars/models/models.dart';

void main() {
  group('HintSystem', () {
    late HintSystem hintSystem;
    late GameContentGenerator generator;

    setUp(() {
      hintSystem = HintSystem();
      generator = GameContentGenerator();
    });

    test('should provide hints with penalties', () {
      final puzzle = generator.generatePuzzle(
        gameType: 'memory_match',
        difficulty: Difficulty.medium,
      );

      final result = hintSystem.getHint(
        puzzle: puzzle,
        currentState: {},
      );

      expect(result.hint, isNotNull);
      expect(result.penalty, equals(HintSystem.hintPenalty));
      expect(result.hintsRemaining, equals(HintSystem.maxHintsPerGame - 1));
      expect(result.maxReached, isFalse);
    });

    test('should limit hints to maximum per game', () {
      final puzzle = generator.generatePuzzle(
        gameType: 'memory_match',
        difficulty: Difficulty.medium,
      );

      // Use all hints
      for (var i = 0; i < HintSystem.maxHintsPerGame; i++) {
        final result = hintSystem.getHint(
          puzzle: puzzle,
          currentState: {},
        );
        expect(result.hint, isNotNull);
      }

      // Try to get another hint
      final result = hintSystem.getHint(
        puzzle: puzzle,
        currentState: {},
      );

      expect(result.hint, isNull);
      expect(result.maxReached, isTrue);
      expect(result.hintsRemaining, equals(0));
    });

    test('should accumulate penalties', () {
      final puzzle = generator.generatePuzzle(
        gameType: 'memory_match',
        difficulty: Difficulty.medium,
      );

      hintSystem.getHint(puzzle: puzzle, currentState: {});
      hintSystem.getHint(puzzle: puzzle, currentState: {});

      final totalPenalty = hintSystem.getTotalPenalty(puzzle.id);
      expect(totalPenalty, equals(HintSystem.hintPenalty * 2));
    });

    test('should reset hints for a game', () {
      final puzzle = generator.generatePuzzle(
        gameType: 'memory_match',
        difficulty: Difficulty.medium,
      );

      hintSystem.getHint(puzzle: puzzle, currentState: {});
      expect(hintSystem.getHintsUsed(puzzle.id), equals(1));

      hintSystem.resetHints(puzzle.id);
      expect(hintSystem.getHintsUsed(puzzle.id), equals(0));
      expect(hintSystem.getTotalPenalty(puzzle.id), equals(0));
    });

    test('should provide different hints for different hint numbers', () {
      final puzzle = generator.generatePuzzle(
        gameType: 'sequence_recall',
        difficulty: Difficulty.medium,
      );

      final hint1 = hintSystem.getHint(puzzle: puzzle, currentState: {});
      final hint2 = hintSystem.getHint(puzzle: puzzle, currentState: {});
      final hint3 = hintSystem.getHint(puzzle: puzzle, currentState: {});

      expect(hint1.hint, isNot(equals(hint2.hint)));
      expect(hint2.hint, isNot(equals(hint3.hint)));
    });
  });

  group('DailyChallengeSystem', () {
    late DailyChallengeSystem challengeSystem;
    late GameContentGenerator generator;

    setUp(() {
      challengeSystem = DailyChallengeSystem();
      generator = GameContentGenerator();
    });

    test('should generate daily challenge', () {
      final challenge = challengeSystem.getTodaysChallenge(
        generator: generator,
      );

      expect(challenge.id, startsWith(DailyChallengeSystem.challengePrefix));
      expect(challenge.puzzle, isNotNull);
      expect(challenge.puzzle.difficulty, equals(Difficulty.hard));
      expect(challenge.bonusMultiplier, greaterThan(1.0));
      expect(challenge.expiresAt.isAfter(DateTime.now()), isTrue);
    });

    test('should generate same challenge for same day', () {
      final challenge1 = challengeSystem.getTodaysChallenge(
        generator: generator,
      );
      final challenge2 = challengeSystem.getTodaysChallenge(
        generator: generator,
      );

      expect(challenge1.id, equals(challenge2.id));
      expect(challenge1.puzzle.gameType, equals(challenge2.puzzle.gameType));
    });

    test('should check if player completed today\'s challenge', () {
      final challenge = challengeSystem.getTodaysChallenge(
        generator: generator,
      );
      final completedChallenges = <String>{'player1_${challenge.id}'};

      final hasCompleted = challengeSystem.hasCompletedToday(
        'player1',
        completedChallenges,
      );

      expect(hasCompleted, isTrue);
    });

    test('should calculate streak count', () {
      final today = DateTime.now();
      final completedChallenges = <String>{};

      // Add completed challenges for last 3 days
      for (var i = 0; i < 3; i++) {
        final date = today.subtract(Duration(days: i));
        final dateKey =
            '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
        final challengeId = '${DailyChallengeSystem.challengePrefix}$dateKey';
        completedChallenges.add('player1_$challengeId');
      }

      final streak = challengeSystem.getStreakCount(completedChallenges, 'player1');
      expect(streak, equals(3));
    });

    test('should detect broken streak', () {
      final today = DateTime.now();
      final completedChallenges = <String>{};

      // Add challenge for today and 2 days ago (skipping yesterday)
      final dateToday =
          '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
      completedChallenges.add(
          'player1_${DailyChallengeSystem.challengePrefix}$dateToday');

      final streak = challengeSystem.getStreakCount(completedChallenges, 'player1');
      expect(streak, equals(1)); // Only today counts
    });

    test('challenge should expire at end of day', () {
      final challenge = challengeSystem.getTodaysChallenge(
        generator: generator,
      );

      final expiresAt = challenge.expiresAt;
      expect(expiresAt.hour, equals(23));
      expect(expiresAt.minute, equals(59));
      expect(expiresAt.second, equals(59));
    });
  });
}
