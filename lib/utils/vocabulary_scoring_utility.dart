/**
 * Vocabulary Scoring Utility
 * Implements Mind Wars-compliant hybrid scoring system
 * Accuracy 70% / Speed 30% with difficulty multipliers and streak bonuses
 */

import 'dart:math';

class VocabularyScoringUtility {
  /// Compute score for a single question
  /// 
  /// Formula:
  /// - AccuracyPoints = correct ? 1000 : 0
  /// - SpeedPoints = max(200, 1000 * (1 - timeTaken/maxTime))
  /// - RawQ = (AccuracyPoints * 0.7) + (SpeedPoints * 0.3)
  /// - Qscore = round(RawQ * DifficultyMultiplier)
  /// - Add streak bonuses if applicable
  static int computeQuestionScore({
    required bool correct,
    required double timeTaken,
    required double maxTime,
    required int difficultyTier, // 1..4
    int streak = 0,
  }) {
    // Validate inputs
    if (difficultyTier < 1 || difficultyTier > 4) {
      throw ArgumentError('difficultyTier must be between 1 and 4');
    }
    if (maxTime <= 0) {
      throw ArgumentError('maxTime must be positive');
    }

    final accuracy = correct ? 1000.0 : 0.0;
    final speed = max(200.0, 1000.0 * (1 - (timeTaken / maxTime)));
    final raw = accuracy * 0.7 + speed * 0.3;
    
    // Difficulty multipliers: 1.0, 1.5, 2.0, 2.5 for tiers 1-4
    final multiplier = [0, 1.0, 1.5, 2.0, 2.5][difficultyTier];
    var score = (raw * multiplier).round();
    
    // Streak bonuses (capped)
    if (streak >= 3) {
      if (streak >= 10) {
        score += 1000;
      } else if (streak >= 7) {
        score += 500;
      } else if (streak >= 5) {
        score += 300;
      } else {
        score += 100;
      }
    }
    
    return score;
  }

  /// Calculate normalized percentage for leaderboard
  /// 
  /// Returns a value between 0.0 and 1.0 representing
  /// how well the player performed relative to maximum possible score
  static double computeNormalizedPercent({
    required int finalScore,
    required int roundMaxScore,
  }) {
    if (roundMaxScore <= 0) {
      return 0.0;
    }
    return (finalScore / roundMaxScore).clamp(0.0, 1.0);
  }

  /// Calculate maximum possible score for a round
  /// 
  /// Assumes perfect performance (100% accuracy, 0 time taken)
  static int calculateRoundMaxScore({
    required List<int> difficultyTiers,
    required List<double> maxTimes,
    bool includeStreakBonus = true,
  }) {
    if (difficultyTiers.length != maxTimes.length) {
      throw ArgumentError('difficultyTiers and maxTimes must have same length');
    }

    int total = 0;
    for (int i = 0; i < difficultyTiers.length; i++) {
      // Perfect score: correct answer in 0 time
      final score = computeQuestionScore(
        correct: true,
        timeTaken: 0.0,
        maxTime: maxTimes[i],
        difficultyTier: difficultyTiers[i],
        streak: includeStreakBonus ? i : 0, // Progressive streak
      );
      total += score;
    }
    return total;
  }

  /// Get score breakdown for display
  static Map<String, dynamic> getScoreBreakdown({
    required bool correct,
    required double timeTaken,
    required double maxTime,
    required int difficultyTier,
    int streak = 0,
  }) {
    final accuracy = correct ? 1000.0 : 0.0;
    final speed = max(200.0, 1000.0 * (1 - (timeTaken / maxTime)));
    final raw = accuracy * 0.7 + speed * 0.3;
    final multiplier = [0, 1.0, 1.5, 2.0, 2.5][difficultyTier];
    final baseScore = (raw * multiplier).round();
    
    int streakBonus = 0;
    if (streak >= 3) {
      if (streak >= 10) {
        streakBonus = 1000;
      } else if (streak >= 7) {
        streakBonus = 500;
      } else if (streak >= 5) {
        streakBonus = 300;
      } else {
        streakBonus = 100;
      }
    }

    return {
      'accuracyPoints': accuracy.round(),
      'speedPoints': speed.round(),
      'rawScore': raw.round(),
      'difficultyMultiplier': multiplier,
      'baseScore': baseScore,
      'streakBonus': streakBonus,
      'totalScore': baseScore + streakBonus,
    };
  }

  /// Validate score data (anti-cheating)
  static bool validateScoreData({
    required int score,
    required double timeTaken,
    required double maxTime,
    required int difficultyTier,
    int streak = 0,
  }) {
    // Basic validation
    if (score < 0) return false;
    if (timeTaken < 0) return false;
    if (maxTime <= 0) return false;
    if (difficultyTier < 1 || difficultyTier > 4) return false;
    if (streak < 0) return false;

    // Calculate maximum possible score for this question
    final maxPossible = computeQuestionScore(
      correct: true,
      timeTaken: 0.0,
      maxTime: maxTime,
      difficultyTier: difficultyTier,
      streak: streak,
    );

    // Score should not exceed maximum possible
    if (score > maxPossible) return false;

    // Time should not be impossibly fast (at least 100ms to read and click)
    if (timeTaken > 0 && timeTaken < 0.1) return false;

    return true;
  }
}
