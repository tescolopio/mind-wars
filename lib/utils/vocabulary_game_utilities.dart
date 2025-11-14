/**
 * Vocabulary Game Utilities
 * Helper functions for vocabulary game mechanics
 */

import 'dart:math';

class VocabularyGameUtilities {
  /// Deterministic shuffle using a seed
  /// 
  /// Ensures reproducible shuffling for multiplayer fairness
  /// All players with same seed will get same order
  static List<T> seededShuffle<T>(List<T> items, int seed) {
    final rnd = Random(seed);
    final list = List<T>.from(items);
    for (var i = list.length - 1; i > 0; i--) {
      final j = rnd.nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
    return list;
  }

  /// Adjust difficulty based on success rate
  /// 
  /// Uses exponential smoothing to prevent rapid changes
  /// Target: ~70% success rate
  static int adjustDifficulty(int currentDifficulty, double successRate) {
    if (successRate < 0.0 || successRate > 1.0) {
      throw ArgumentError('successRate must be between 0.0 and 1.0');
    }

    double candidate = currentDifficulty.toDouble();
    
    if (successRate > 0.85) {
      candidate = currentDifficulty + 1.0;
    } else if (successRate < 0.40) {
      candidate = currentDifficulty - 1.0;
    } else if (successRate < 0.65) {
      candidate = currentDifficulty - 0.5;
    }
    // If successRate is between 0.65 and 0.85, no change (target zone)

    // Apply exponential smoothing: 30% new value, 70% old value
    final smoothed = (0.3 * candidate + 0.7 * currentDifficulty);
    
    // Clamp to valid range (1-10)
    return smoothed.clamp(1, 10).round();
  }

  /// Calculate success rate from rolling window
  static double calculateSuccessRate(List<bool> results) {
    if (results.isEmpty) return 0.0;
    final correct = results.where((r) => r).length;
    return correct / results.length;
  }

  /// Map difficulty (1-10) to difficulty tier (1-4) for scoring
  static int difficultyToTier(int difficulty) {
    if (difficulty < 1 || difficulty > 10) {
      throw ArgumentError('difficulty must be between 1 and 10');
    }
    
    // Map 1-10 scale to 1-4 tiers
    // 1-2: Tier 1, 3-5: Tier 2, 6-8: Tier 3, 9-10: Tier 4
    if (difficulty <= 2) return 1;
    if (difficulty <= 5) return 2;
    if (difficulty <= 8) return 3;
    return 4;
  }

  /// Get max time for question based on type and difficulty
  static double getMaxTimeForQuestion({
    required String questionType,
    required int difficulty,
  }) {
    // Base times by question type
    Map<String, double> baseTimes = {
      'multipleChoice': 25.0,
      'fillInBlank': 35.0,
      'synonymAntonym': 30.0,
    };

    double baseTime = baseTimes[questionType] ?? 25.0;

    // Adjust for difficulty (harder = more time)
    // Tier 1: -5s, Tier 2: base, Tier 3: +5s, Tier 4: +10s
    final tier = difficultyToTier(difficulty);
    final adjustments = {1: -5.0, 2: 0.0, 3: 5.0, 4: 10.0};
    
    return baseTime + (adjustments[tier] ?? 0.0);
  }

  /// Generate question mix following 40-30-20-10 distribution
  /// 
  /// Returns list of question type strings
  static List<String> generateQuestionTypeMix(int totalQuestions) {
    if (totalQuestions <= 0) {
      throw ArgumentError('totalQuestions must be positive');
    }

    final types = <String>[];
    
    // Calculate counts (40% MCQ, 30% Fill, 30% Syn/Ant for MVP)
    // Note: Using 60-30-10 as mentioned in spec for MVP
    final mcqCount = (totalQuestions * 0.6).round();
    final fillCount = (totalQuestions * 0.3).round();
    final synCount = totalQuestions - mcqCount - fillCount;

    // Add question types
    for (int i = 0; i < mcqCount; i++) {
      types.add('multipleChoice');
    }
    for (int i = 0; i < fillCount; i++) {
      types.add('fillInBlank');
    }
    for (int i = 0; i < synCount; i++) {
      types.add('synonymAntonym');
    }

    return types;
  }

  /// Select difficulty distribution for a round
  /// 
  /// Returns list of difficulties balancing challenge
  static List<int> generateDifficultyDistribution({
    required int questionCount,
    required int baseDifficulty,
  }) {
    if (questionCount <= 0) {
      throw ArgumentError('questionCount must be positive');
    }
    if (baseDifficulty < 1 || baseDifficulty > 10) {
      throw ArgumentError('baseDifficulty must be between 1 and 10');
    }

    final difficulties = <int>[];
    
    // Start with 2-3 warmup questions (easier)
    final warmupCount = min(3, questionCount);
    for (int i = 0; i < warmupCount; i++) {
      difficulties.add(max(1, baseDifficulty - 2));
    }

    // Core questions at base difficulty
    final coreCount = questionCount - warmupCount;
    for (int i = 0; i < coreCount; i++) {
      // Vary slightly around base
      final variance = (i % 3) - 1; // -1, 0, 1 pattern
      difficulties.add((baseDifficulty + variance).clamp(1, 10));
    }

    return difficulties;
  }

  /// Validate question answer
  static bool validateAnswer({
    required String correctAnswer,
    required String? userAnswer,
    bool caseSensitive = false,
  }) {
    if (userAnswer == null) return false;
    
    final correct = caseSensitive ? correctAnswer : correctAnswer.toLowerCase();
    final user = caseSensitive ? userAnswer : userAnswer.toLowerCase();
    
    return correct.trim() == user.trim();
  }
}
