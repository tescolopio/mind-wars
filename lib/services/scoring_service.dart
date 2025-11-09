/**
 * Scoring Service - Feature 3.4
 * Unified scoring system with server-side validation
 * Base score + time bonus + accuracy + streak multipliers
 */

import '../models/models.dart';
import 'api_service.dart';

class ScoringService {
  final ApiService _apiService;
  final Map<String, ScoreRecord> _scoreCache = {};

  ScoringService(this._apiService);

  /// Calculate score locally - Feature 3.4.2
  /// This is for immediate feedback, but server validation is required
  ScoreRecord calculateScore({
    required String gameId,
    required String playerId,
    required int baseScore,
    required int timeSeconds,
    required double accuracy,
    required int currentStreak,
  }) {
    // Time bonus: faster = more points (max 500 bonus)
    final timeBonus = _calculateTimeBonus(timeSeconds);

    // Accuracy bonus: higher accuracy = more points (max 300 bonus)
    final accuracyBonus = _calculateAccuracyBonus(accuracy);

    // Streak multiplier: up to 2.0x (doubles score at 30-day streak)
    final streakMultiplier = _calculateStreakMultiplier(currentStreak);

    // Calculate final score
    final subtotal = baseScore + timeBonus + accuracyBonus;
    final finalScore = (subtotal * streakMultiplier).round();

    return ScoreRecord(
      id: 'score_${DateTime.now().millisecondsSinceEpoch}',
      gameId: gameId,
      playerId: playerId,
      baseScore: baseScore,
      timeBonus: timeBonus,
      accuracyBonus: accuracyBonus,
      streakMultiplier: streakMultiplier,
      finalScore: finalScore,
      timestamp: DateTime.now(),
      validated: false,
    );
  }

  /// Submit score to server for validation - Feature 3.4.4
  Future<ScoreRecord> submitScore({
    required String gameId,
    required String playerId,
    required int baseScore,
    required int timeSeconds,
    required double accuracy,
    required int currentStreak,
    required Map<String, dynamic> gameData,
  }) async {
    try {
      // Calculate local score
      final localScore = calculateScore(
        gameId: gameId,
        playerId: playerId,
        baseScore: baseScore,
        timeSeconds: timeSeconds,
        accuracy: accuracy,
        currentStreak: currentStreak,
      );

      // Submit to server with anti-cheating validation
      final response = await _apiService.post(
        '/games/$gameId/score',
        {
          'playerId': playerId,
          'baseScore': baseScore,
          'timeSeconds': timeSeconds,
          'accuracy': accuracy,
          'currentStreak': currentStreak,
          'gameData': gameData,
          'localScore': localScore.finalScore,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Score validation failed');
      }

      // Create validated score record
      final validatedScore = ScoreRecord.fromJson(response['scoreRecord']);

      // Cache the score
      _scoreCache[validatedScore.id] = validatedScore;

      return validatedScore;
    } catch (e) {
      throw Exception('Failed to submit score: $e');
    }
  }

  /// Get score record by ID
  Future<ScoreRecord?> getScore(String scoreId) async {
    // Check cache first
    if (_scoreCache.containsKey(scoreId)) {
      return _scoreCache[scoreId];
    }

    try {
      final response = await _apiService.get('/scores/$scoreId');

      if (response['success'] == true) {
        final score = ScoreRecord.fromJson(response['scoreRecord']);
        _scoreCache[scoreId] = score;
        return score;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get scores for a game
  Future<List<ScoreRecord>> getGameScores(String gameId) async {
    try {
      final response = await _apiService.get('/games/$gameId/scores');

      if (response['success'] == true) {
        final scores = (response['scores'] as List)
            .map((s) => ScoreRecord.fromJson(s))
            .toList();

        // Cache all scores
        for (var score in scores) {
          _scoreCache[score.id] = score;
        }

        return scores;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get game scores: $e');
    }
  }

  /// Get player's score history
  Future<List<ScoreRecord>> getPlayerScores(String playerId) async {
    try {
      final response = await _apiService.get('/players/$playerId/scores');

      if (response['success'] == true) {
        final scores = (response['scores'] as List)
            .map((s) => ScoreRecord.fromJson(s))
            .toList();

        // Cache all scores
        for (var score in scores) {
          _scoreCache[score.id] = score;
        }

        return scores;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get player scores: $e');
    }
  }

  /// Calculate time bonus (max 500 points)
  int _calculateTimeBonus(int timeSeconds) {
    // Fast completion = higher bonus
    // < 30 seconds: 500 points
    // < 60 seconds: 300 points
    // < 120 seconds: 150 points
    // < 300 seconds: 50 points
    // > 300 seconds: 0 points

    if (timeSeconds < 30) return 500;
    if (timeSeconds < 60) return 300;
    if (timeSeconds < 120) return 150;
    if (timeSeconds < 300) return 50;
    return 0;
  }

  /// Calculate accuracy bonus (max 300 points)
  int _calculateAccuracyBonus(double accuracy) {
    // accuracy is 0.0 to 1.0
    final normalizedAccuracy = accuracy.clamp(0.0, 1.0);
    return (normalizedAccuracy * 300).round();
  }

  /// Calculate streak multiplier (1.0x to 2.0x)
  double _calculateStreakMultiplier(int streak) {
    // 0 days: 1.0x
    // 3 days: 1.1x
    // 7 days: 1.3x
    // 14 days: 1.5x
    // 30+ days: 2.0x

    if (streak >= 30) return 2.0;
    if (streak >= 14) return 1.5;
    if (streak >= 7) return 1.3;
    if (streak >= 3) return 1.1;
    return 1.0;
  }

  /// Get score breakdown for display
  Map<String, dynamic> getScoreBreakdown(ScoreRecord score) {
    return {
      'baseScore': score.baseScore,
      'timeBonus': score.timeBonus,
      'accuracyBonus': score.accuracyBonus,
      'subtotal': score.baseScore + score.timeBonus + score.accuracyBonus,
      'streakMultiplier': score.streakMultiplier,
      'finalScore': score.finalScore,
    };
  }

  /// Validate score data for anti-cheating - Feature 3.4.4
  bool validateScoreData({
    required int baseScore,
    required int timeSeconds,
    required double accuracy,
    required Map<String, dynamic> gameData,
  }) {
    // Basic validation rules
    if (baseScore < 0) return false;
    if (timeSeconds < 0) return false;
    if (accuracy < 0.0 || accuracy > 1.0) return false;

    // Game data should not be empty
    if (gameData.isEmpty) return false;

    // Time should be reasonable (not impossibly fast)
    if (timeSeconds < 5) return false;

    // Base score should be within reasonable range for game type
    if (baseScore > 100000) return false;

    return true;
  }

  /// Clear score cache
  void clearCache() {
    _scoreCache.clear();
  }
}
