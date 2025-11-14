/**
 * Word Builder Game - Scorer
 * Calculate scores for words with various bonuses
 */

import 'models.dart';

/// Word scorer with comprehensive scoring rules
class Scorer {
  // Word frequency buckets (placeholder - would be loaded from asset)
  static const Map<String, int> _frequencyBuckets = {
    // Common words (bucket 1) - 0 bonus
    'THE': 1, 'AND': 1, 'FOR': 1, 'ARE': 1, 'BUT': 1,
    // Uncommon words (bucket 2) - 5 bonus
    'CAT': 2, 'DOG': 2, 'RUN': 2, 'SIT': 2,
    // Rare words (bucket 3) - 10 bonus
    'ZEN': 3, 'JAM': 3, 'VOW': 3,
    // Very rare words (bucket 4) - 15 bonus
    'ZAX': 4, 'QUA': 4,
    // Extremely rare words (bucket 5) - 25 bonus
    'ZUZ': 5, 'QAT': 5,
  };

  // Morphology patterns (placeholder - would be loaded from asset)
  static const List<String> _prefixes = ['UN', 'RE', 'PRE', 'DIS', 'MIS'];
  static const List<String> _suffixes = ['ING', 'ED', 'ER', 'EST', 'LY'];
  
  /// Calculate score for a word
  ScoreBreakdown calculateScore(
    String word,
    bool isPangram,
    bool usedGoldenTile,
    Set<String> uniqueLetters,
  ) {
    // Base score: length²
    final baseScore = word.length * word.length;

    // Rarity bonus
    final rarityBonus = _getRarityBonus(word.toUpperCase());

    // Pattern bonus
    final patternBonus = _getPatternBonus(word.toUpperCase());

    // Pangram bonus
    final pangramBonus = isPangram ? 50 : 0;

    // Calculate multiplier
    double multiplier = 1.0;
    if (usedGoldenTile) {
      multiplier *= 2.0; // Golden tile doubles score
    }
    if (isPangram) {
      multiplier *= 2.0; // Pangram doubles score
    }

    // Calculate final score
    final subtotal = baseScore + rarityBonus + patternBonus + pangramBonus;
    final finalScore = (subtotal * multiplier).round();

    return ScoreBreakdown(
      baseScore: baseScore,
      rarityBonus: rarityBonus,
      patternBonus: patternBonus,
      pangramBonus: pangramBonus,
      multiplier: multiplier,
      finalScore: finalScore,
    );
  }

  /// Get rarity bonus based on word frequency
  int _getRarityBonus(String word) {
    final bucket = _frequencyBuckets[word] ?? 2; // Default to uncommon
    
    switch (bucket) {
      case 1:
        return 0; // Common
      case 2:
        return 5; // Uncommon
      case 3:
        return 10; // Rare
      case 4:
        return 15; // Very rare
      case 5:
        return 25; // Extremely rare
      default:
        return 5;
    }
  }

  /// Get pattern bonus for recognized morphology
  int _getPatternBonus(String word) {
    // Check for prefixes
    for (final prefix in _prefixes) {
      if (word.startsWith(prefix) && word.length > prefix.length + 2) {
        return 5;
      }
    }

    // Check for suffixes
    for (final suffix in _suffixes) {
      if (word.endsWith(suffix) && word.length > suffix.length + 2) {
        return 5;
      }
    }

    // Check for compound words (simple heuristic: long words)
    if (word.length >= 8) {
      return 5;
    }

    return 0;
  }

  /// Calculate efficiency multiplier for end-of-round
  double calculateEfficiencyMultiplier(
    int wordsFound,
    int targetWords,
    int maxPossibleWords,
  ) {
    if (maxPossibleWords == 0) return 1.0;

    final percentComplete = wordsFound / targetWords;
    final percentOfMax = wordsFound / maxPossibleWords;

    // Tiered efficiency multipliers
    if (percentComplete >= 1.0 && percentOfMax >= 0.8) {
      return 1.5; // Found target and 80%+ of max
    } else if (percentComplete >= 1.0) {
      return 1.2; // Found target
    } else if (percentOfMax >= 0.6) {
      return 1.2; // Found 60%+ of max
    } else {
      return 1.0; // No bonus
    }
  }

  /// Calculate player percentage for leaderboard normalization
  double calculatePlayerPercent(int playerScore, int maxPossibleScore) {
    if (maxPossibleScore == 0) return 0.0;
    return (playerScore / maxPossibleScore * 100.0);
  }
}
