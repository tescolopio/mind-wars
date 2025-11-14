/**
 * Tests for Vocabulary Scoring Utility
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_wars/utils/vocabulary_scoring_utility.dart';

void main() {
  group('VocabularyScoringUtility', () {
    group('computeQuestionScore', () {
      test('correct answer with 0 time should give maximum score', () {
        final score = VocabularyScoringUtility.computeQuestionScore(
          correct: true,
          timeTaken: 0.0,
          maxTime: 30.0,
          difficultyTier: 1,
          streak: 0,
        );
        
        // Accuracy: 1000 * 0.7 = 700
        // Speed: 1000 * 0.3 = 300
        // Total: 1000 * 1.0 multiplier = 1000
        expect(score, equals(1000));
      });

      test('correct answer with max time should give minimum speed bonus', () {
        final score = VocabularyScoringUtility.computeQuestionScore(
          correct: true,
          timeTaken: 30.0,
          maxTime: 30.0,
          difficultyTier: 1,
          streak: 0,
        );
        
        // Accuracy: 1000 * 0.7 = 700
        // Speed: 200 * 0.3 = 60 (capped at 200)
        // Total: 760 * 1.0 multiplier = 760
        expect(score, equals(760));
      });

      test('incorrect answer should give only speed points', () {
        final score = VocabularyScoringUtility.computeQuestionScore(
          correct: false,
          timeTaken: 0.0,
          maxTime: 30.0,
          difficultyTier: 1,
          streak: 0,
        );
        
        // Accuracy: 0 * 0.7 = 0
        // Speed: 1000 * 0.3 = 300
        // Total: 300 * 1.0 multiplier = 300
        expect(score, equals(300));
      });

      test('difficulty multiplier tier 2 should multiply by 1.5', () {
        final score = VocabularyScoringUtility.computeQuestionScore(
          correct: true,
          timeTaken: 0.0,
          maxTime: 30.0,
          difficultyTier: 2,
          streak: 0,
        );
        
        // Base: 1000
        // Multiplier: 1.5
        // Total: 1500
        expect(score, equals(1500));
      });

      test('difficulty multiplier tier 4 should multiply by 2.5', () {
        final score = VocabularyScoringUtility.computeQuestionScore(
          correct: true,
          timeTaken: 0.0,
          maxTime: 30.0,
          difficultyTier: 4,
          streak: 0,
        );
        
        // Base: 1000
        // Multiplier: 2.5
        // Total: 2500
        expect(score, equals(2500));
      });

      test('streak of 3 should add 100 bonus', () {
        final score = VocabularyScoringUtility.computeQuestionScore(
          correct: true,
          timeTaken: 0.0,
          maxTime: 30.0,
          difficultyTier: 1,
          streak: 3,
        );
        
        // Base: 1000
        // Streak bonus: 100
        // Total: 1100
        expect(score, equals(1100));
      });

      test('streak of 5 should add 300 bonus', () {
        final score = VocabularyScoringUtility.computeQuestionScore(
          correct: true,
          timeTaken: 0.0,
          maxTime: 30.0,
          difficultyTier: 1,
          streak: 5,
        );
        
        // Base: 1000
        // Streak bonus: 300
        // Total: 1300
        expect(score, equals(1300));
      });

      test('streak of 7 should add 500 bonus', () {
        final score = VocabularyScoringUtility.computeQuestionScore(
          correct: true,
          timeTaken: 0.0,
          maxTime: 30.0,
          difficultyTier: 1,
          streak: 7,
        );
        
        // Base: 1000
        // Streak bonus: 500
        // Total: 1500
        expect(score, equals(1500));
      });

      test('streak of 10+ should add 1000 bonus (capped)', () {
        final score = VocabularyScoringUtility.computeQuestionScore(
          correct: true,
          timeTaken: 0.0,
          maxTime: 30.0,
          difficultyTier: 1,
          streak: 15,
        );
        
        // Base: 1000
        // Streak bonus: 1000 (capped)
        // Total: 2000
        expect(score, equals(2000));
      });

      test('time exceeding maxTime should still be capped at minimum', () {
        final score = VocabularyScoringUtility.computeQuestionScore(
          correct: true,
          timeTaken: 60.0,
          maxTime: 30.0,
          difficultyTier: 1,
          streak: 0,
        );
        
        // Speed should be capped at 200 minimum
        // Accuracy: 700, Speed: 60, Total: 760
        expect(score, equals(760));
      });

      test('should throw on invalid difficulty tier', () {
        expect(
          () => VocabularyScoringUtility.computeQuestionScore(
            correct: true,
            timeTaken: 10.0,
            maxTime: 30.0,
            difficultyTier: 0,
            streak: 0,
          ),
          throwsArgumentError,
        );

        expect(
          () => VocabularyScoringUtility.computeQuestionScore(
            correct: true,
            timeTaken: 10.0,
            maxTime: 30.0,
            difficultyTier: 5,
            streak: 0,
          ),
          throwsArgumentError,
        );
      });
    });

    group('computeNormalizedPercent', () {
      test('should return 1.0 for perfect score', () {
        final percent = VocabularyScoringUtility.computeNormalizedPercent(
          finalScore: 10000,
          roundMaxScore: 10000,
        );
        expect(percent, equals(1.0));
      });

      test('should return 0.5 for half score', () {
        final percent = VocabularyScoringUtility.computeNormalizedPercent(
          finalScore: 5000,
          roundMaxScore: 10000,
        );
        expect(percent, equals(0.5));
      });

      test('should return 0.0 for zero score', () {
        final percent = VocabularyScoringUtility.computeNormalizedPercent(
          finalScore: 0,
          roundMaxScore: 10000,
        );
        expect(percent, equals(0.0));
      });

      test('should clamp above 1.0', () {
        final percent = VocabularyScoringUtility.computeNormalizedPercent(
          finalScore: 15000,
          roundMaxScore: 10000,
        );
        expect(percent, equals(1.0));
      });

      test('should handle zero max score gracefully', () {
        final percent = VocabularyScoringUtility.computeNormalizedPercent(
          finalScore: 5000,
          roundMaxScore: 0,
        );
        expect(percent, equals(0.0));
      });
    });

    group('calculateRoundMaxScore', () {
      test('should calculate max score for uniform difficulty', () {
        final maxScore = VocabularyScoringUtility.calculateRoundMaxScore(
          difficultyTiers: [1, 1, 1],
          maxTimes: [30.0, 30.0, 30.0],
          includeStreakBonus: false,
        );
        
        // Each question: 1000 points * 1.0 multiplier = 1000
        // Total: 3000
        expect(maxScore, equals(3000));
      });

      test('should include streak bonuses when enabled', () {
        final maxScore = VocabularyScoringUtility.calculateRoundMaxScore(
          difficultyTiers: [1, 1, 1],
          maxTimes: [30.0, 30.0, 30.0],
          includeStreakBonus: true,
        );
        
        // Question 1: 1000 + 0 (streak 0) = 1000
        // Question 2: 1000 + 0 (streak 1) = 1000
        // Question 3: 1000 + 0 (streak 2) = 1000
        // Total: 3000 (no bonus until streak 3)
        expect(maxScore, equals(3000));
      });

      test('should throw when lists have different lengths', () {
        expect(
          () => VocabularyScoringUtility.calculateRoundMaxScore(
            difficultyTiers: [1, 2],
            maxTimes: [30.0],
          ),
          throwsArgumentError,
        );
      });
    });

    group('validateScoreData', () {
      test('should accept valid score data', () {
        final valid = VocabularyScoringUtility.validateScoreData(
          score: 1000,
          timeTaken: 10.0,
          maxTime: 30.0,
          difficultyTier: 2,
          streak: 3,
        );
        expect(valid, isTrue);
      });

      test('should reject negative score', () {
        final valid = VocabularyScoringUtility.validateScoreData(
          score: -100,
          timeTaken: 10.0,
          maxTime: 30.0,
          difficultyTier: 2,
        );
        expect(valid, isFalse);
      });

      test('should reject negative time', () {
        final valid = VocabularyScoringUtility.validateScoreData(
          score: 1000,
          timeTaken: -5.0,
          maxTime: 30.0,
          difficultyTier: 2,
        );
        expect(valid, isFalse);
      });

      test('should reject impossibly fast time', () {
        final valid = VocabularyScoringUtility.validateScoreData(
          score: 1000,
          timeTaken: 0.05, // 50ms - too fast
          maxTime: 30.0,
          difficultyTier: 2,
        );
        expect(valid, isFalse);
      });

      test('should reject score exceeding maximum possible', () {
        final valid = VocabularyScoringUtility.validateScoreData(
          score: 10000, // Way too high for tier 1
          timeTaken: 5.0,
          maxTime: 30.0,
          difficultyTier: 1,
          streak: 0,
        );
        expect(valid, isFalse);
      });

      test('should reject invalid difficulty tier', () {
        final valid1 = VocabularyScoringUtility.validateScoreData(
          score: 1000,
          timeTaken: 10.0,
          maxTime: 30.0,
          difficultyTier: 0,
        );
        expect(valid1, isFalse);

        final valid2 = VocabularyScoringUtility.validateScoreData(
          score: 1000,
          timeTaken: 10.0,
          maxTime: 30.0,
          difficultyTier: 5,
        );
        expect(valid2, isFalse);
      });
    });
  });
}
