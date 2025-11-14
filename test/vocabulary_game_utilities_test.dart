/**
 * Tests for Vocabulary Game Utilities
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_wars/utils/vocabulary_game_utilities.dart';

void main() {
  group('VocabularyGameUtilities', () {
    group('seededShuffle', () {
      test('should produce deterministic results with same seed', () {
        final items = [1, 2, 3, 4, 5];
        final seed = 12345;

        final result1 = VocabularyGameUtilities.seededShuffle(items, seed);
        final result2 = VocabularyGameUtilities.seededShuffle(items, seed);

        expect(result1, equals(result2));
      });

      test('should produce different results with different seeds', () {
        final items = [1, 2, 3, 4, 5];

        final result1 = VocabularyGameUtilities.seededShuffle(items, 111);
        final result2 = VocabularyGameUtilities.seededShuffle(items, 222);

        expect(result1, isNot(equals(result2)));
      });

      test('should not modify original list', () {
        final items = [1, 2, 3, 4, 5];
        final original = List.from(items);

        VocabularyGameUtilities.seededShuffle(items, 123);

        expect(items, equals(original));
      });

      test('should handle single item list', () {
        final items = [1];
        final result = VocabularyGameUtilities.seededShuffle(items, 123);

        expect(result, equals([1]));
      });

      test('should handle empty list', () {
        final items = <int>[];
        final result = VocabularyGameUtilities.seededShuffle(items, 123);

        expect(result, isEmpty);
      });
    });

    group('adjustDifficulty', () {
      test('should increase difficulty when success rate is high', () {
        final newDifficulty = VocabularyGameUtilities.adjustDifficulty(5, 0.90);
        
        // Should increase from 5
        expect(newDifficulty, greaterThan(5));
      });

      test('should decrease difficulty when success rate is very low', () {
        final newDifficulty = VocabularyGameUtilities.adjustDifficulty(5, 0.30);
        
        // Should decrease from 5
        expect(newDifficulty, lessThan(5));
      });

      test('should slightly decrease difficulty when success rate is low', () {
        final newDifficulty = VocabularyGameUtilities.adjustDifficulty(5, 0.60);
        
        // Should decrease slightly from 5
        expect(newDifficulty, lessThanOrEqualTo(5));
      });

      test('should maintain difficulty in target zone (0.65-0.85)', () {
        final newDifficulty1 = VocabularyGameUtilities.adjustDifficulty(5, 0.70);
        final newDifficulty2 = VocabularyGameUtilities.adjustDifficulty(5, 0.80);
        
        // Should stay near 5 (within smoothing tolerance)
        expect(newDifficulty1, equals(5));
        expect(newDifficulty2, equals(5));
      });

      test('should use exponential smoothing', () {
        // Large jump should be smoothed (candidate 6, current 5)
        // newDiff = 0.3 * 6 + 0.7 * 5 = 1.8 + 3.5 = 5.3 ≈ 5
        final newDifficulty = VocabularyGameUtilities.adjustDifficulty(5, 0.90);
        
        // Should be smoothed, not immediate jump
        expect(newDifficulty, lessThan(6));
      });

      test('should clamp to minimum of 1', () {
        final newDifficulty = VocabularyGameUtilities.adjustDifficulty(1, 0.20);
        
        expect(newDifficulty, greaterThanOrEqualTo(1));
      });

      test('should clamp to maximum of 10', () {
        final newDifficulty = VocabularyGameUtilities.adjustDifficulty(10, 0.95);
        
        expect(newDifficulty, lessThanOrEqualTo(10));
      });

      test('should throw on invalid success rate', () {
        expect(
          () => VocabularyGameUtilities.adjustDifficulty(5, -0.1),
          throwsArgumentError,
        );

        expect(
          () => VocabularyGameUtilities.adjustDifficulty(5, 1.1),
          throwsArgumentError,
        );
      });
    });

    group('calculateSuccessRate', () {
      test('should calculate correct rate', () {
        final results = [true, true, false, true, false];
        final rate = VocabularyGameUtilities.calculateSuccessRate(results);
        
        // 3 out of 5 = 0.6
        expect(rate, equals(0.6));
      });

      test('should return 1.0 for all correct', () {
        final results = [true, true, true];
        final rate = VocabularyGameUtilities.calculateSuccessRate(results);
        
        expect(rate, equals(1.0));
      });

      test('should return 0.0 for all incorrect', () {
        final results = [false, false, false];
        final rate = VocabularyGameUtilities.calculateSuccessRate(results);
        
        expect(rate, equals(0.0));
      });

      test('should return 0.0 for empty list', () {
        final results = <bool>[];
        final rate = VocabularyGameUtilities.calculateSuccessRate(results);
        
        expect(rate, equals(0.0));
      });
    });

    group('difficultyToTier', () {
      test('should map 1-2 to tier 1', () {
        expect(VocabularyGameUtilities.difficultyToTier(1), equals(1));
        expect(VocabularyGameUtilities.difficultyToTier(2), equals(1));
      });

      test('should map 3-5 to tier 2', () {
        expect(VocabularyGameUtilities.difficultyToTier(3), equals(2));
        expect(VocabularyGameUtilities.difficultyToTier(4), equals(2));
        expect(VocabularyGameUtilities.difficultyToTier(5), equals(2));
      });

      test('should map 6-8 to tier 3', () {
        expect(VocabularyGameUtilities.difficultyToTier(6), equals(3));
        expect(VocabularyGameUtilities.difficultyToTier(7), equals(3));
        expect(VocabularyGameUtilities.difficultyToTier(8), equals(3));
      });

      test('should map 9-10 to tier 4', () {
        expect(VocabularyGameUtilities.difficultyToTier(9), equals(4));
        expect(VocabularyGameUtilities.difficultyToTier(10), equals(4));
      });

      test('should throw on invalid difficulty', () {
        expect(
          () => VocabularyGameUtilities.difficultyToTier(0),
          throwsArgumentError,
        );

        expect(
          () => VocabularyGameUtilities.difficultyToTier(11),
          throwsArgumentError,
        );
      });
    });

    group('generateQuestionTypeMix', () {
      test('should generate correct distribution for 10 questions', () {
        final mix = VocabularyGameUtilities.generateQuestionTypeMix(10);
        
        expect(mix.length, equals(10));
        
        final mcqCount = mix.where((t) => t == 'multipleChoice').length;
        final fillCount = mix.where((t) => t == 'fillInBlank').length;
        final synCount = mix.where((t) => t == 'synonymAntonym').length;
        
        // 60% MCQ, 30% Fill, 10% Syn (for 10 questions: 6, 3, 1)
        expect(mcqCount, equals(6));
        expect(fillCount, equals(3));
        expect(synCount, equals(1));
      });

      test('should handle small question counts', () {
        final mix = VocabularyGameUtilities.generateQuestionTypeMix(3);
        
        expect(mix.length, equals(3));
      });

      test('should throw on invalid question count', () {
        expect(
          () => VocabularyGameUtilities.generateQuestionTypeMix(0),
          throwsArgumentError,
        );

        expect(
          () => VocabularyGameUtilities.generateQuestionTypeMix(-1),
          throwsArgumentError,
        );
      });
    });

    group('generateDifficultyDistribution', () {
      test('should include warmup questions', () {
        final distribution = VocabularyGameUtilities.generateDifficultyDistribution(
          questionCount: 10,
          baseDifficulty: 5,
        );
        
        expect(distribution.length, equals(10));
        
        // First 2-3 should be easier (baseDifficulty - 2)
        expect(distribution[0], equals(3));
        expect(distribution[1], equals(3));
      });

      test('should vary around base difficulty', () {
        final distribution = VocabularyGameUtilities.generateDifficultyDistribution(
          questionCount: 10,
          baseDifficulty: 5,
        );
        
        // Core questions should vary around base
        final coreQuestions = distribution.skip(3).toList();
        expect(coreQuestions.every((d) => d >= 4 && d <= 6), isTrue);
      });

      test('should clamp to valid range', () {
        final distribution = VocabularyGameUtilities.generateDifficultyDistribution(
          questionCount: 5,
          baseDifficulty: 1,
        );
        
        // All should be >= 1
        expect(distribution.every((d) => d >= 1), isTrue);
      });

      test('should throw on invalid inputs', () {
        expect(
          () => VocabularyGameUtilities.generateDifficultyDistribution(
            questionCount: 0,
            baseDifficulty: 5,
          ),
          throwsArgumentError,
        );

        expect(
          () => VocabularyGameUtilities.generateDifficultyDistribution(
            questionCount: 10,
            baseDifficulty: 0,
          ),
          throwsArgumentError,
        );
      });
    });

    group('validateAnswer', () {
      test('should match exact answers', () {
        final valid = VocabularyGameUtilities.validateAnswer(
          correctAnswer: 'hello',
          userAnswer: 'hello',
        );
        expect(valid, isTrue);
      });

      test('should ignore case by default', () {
        final valid = VocabularyGameUtilities.validateAnswer(
          correctAnswer: 'Hello',
          userAnswer: 'hello',
        );
        expect(valid, isTrue);
      });

      test('should respect case sensitivity when enabled', () {
        final valid = VocabularyGameUtilities.validateAnswer(
          correctAnswer: 'Hello',
          userAnswer: 'hello',
          caseSensitive: true,
        );
        expect(valid, isFalse);
      });

      test('should trim whitespace', () {
        final valid = VocabularyGameUtilities.validateAnswer(
          correctAnswer: 'hello',
          userAnswer: '  hello  ',
        );
        expect(valid, isTrue);
      });

      test('should return false for null answer', () {
        final valid = VocabularyGameUtilities.validateAnswer(
          correctAnswer: 'hello',
          userAnswer: null,
        );
        expect(valid, isFalse);
      });
    });
  });
}
