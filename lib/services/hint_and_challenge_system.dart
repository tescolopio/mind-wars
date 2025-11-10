/**
 * Hint System - Feature 3.6.2
 * Provides hints with score penalties
 */

import 'game_content_generator.dart';

class HintSystem {
  static const int hintPenalty = 50; // Points deducted per hint
  static const int maxHintsPerGame = 3;

  final Map<String, int> _hintsUsed = {};
  final Map<String, int> _penaltiesAccumulated = {};

  /// Get hint for a puzzle - Feature 3.6.2
  HintResult getHint({
    required Puzzle puzzle,
    required Map<String, dynamic> currentState,
  }) {
    final gameId = puzzle.id;
    final hintsUsed = _hintsUsed[gameId] ?? 0;

    if (hintsUsed >= maxHintsPerGame) {
      return HintResult(
        hint: null,
        hintsRemaining: 0,
        penalty: 0,
        maxReached: true,
      );
    }

    // Generate hint based on game type and current state
    final hint = _generateHint(puzzle, currentState, hintsUsed);

    // Update hints used
    _hintsUsed[gameId] = hintsUsed + 1;

    // Accumulate penalty
    final currentPenalty = _penaltiesAccumulated[gameId] ?? 0;
    _penaltiesAccumulated[gameId] = currentPenalty + hintPenalty;

    return HintResult(
      hint: hint,
      hintsRemaining: maxHintsPerGame - (hintsUsed + 1),
      penalty: hintPenalty,
      maxReached: false,
    );
  }

  /// Get total penalty for a game
  int getTotalPenalty(String gameId) {
    return _penaltiesAccumulated[gameId] ?? 0;
  }

  /// Get hints used count
  int getHintsUsed(String gameId) {
    return _hintsUsed[gameId] ?? 0;
  }

  /// Reset hints for a game
  void resetHints(String gameId) {
    _hintsUsed.remove(gameId);
    _penaltiesAccumulated.remove(gameId);
  }

  /// Generate hint based on game type
  String _generateHint(Puzzle puzzle, Map<String, dynamic> currentState, int hintNumber) {
    switch (puzzle.gameType) {
      case 'memory_match':
        return _getMemoryMatchHint(puzzle, currentState, hintNumber);
      case 'sequence_recall':
        return _getSequenceRecallHint(puzzle, currentState, hintNumber);
      case 'pattern_memory':
        return _getPatternMemoryHint(puzzle, currentState, hintNumber);
      case 'sudoku_duel':
        return _getSudokuHint(puzzle, currentState, hintNumber);
      case 'logic_grid':
        return _getLogicGridHint(puzzle, currentState, hintNumber);
      case 'code_breaker':
        return _getCodeBreakerHint(puzzle, currentState, hintNumber);
      case 'word_builder':
        return _getWordBuilderHint(puzzle, currentState, hintNumber);
      case 'anagram_attack':
        return _getAnagramHint(puzzle, currentState, hintNumber);
      default:
        return 'Think about the pattern and try different approaches.';
    }
  }

  String _getMemoryMatchHint(Puzzle puzzle, Map<String, dynamic> state, int hintNumber) {
    switch (hintNumber) {
      case 0:
        return 'Focus on remembering card positions in pairs.';
      case 1:
        return 'Try to match cards systematically, row by row.';
      case 2:
        final cards = puzzle.data['cards'] as List;
        return 'There are ${cards.length ~/ 2} unique pairs to find.';
      default:
        return 'Keep practicing your memory skills!';
    }
  }

  String _getSequenceRecallHint(Puzzle puzzle, Map<String, dynamic> state, int hintNumber) {
    final sequence = puzzle.solution['sequence'] as List<int>;
    switch (hintNumber) {
      case 0:
        return 'The sequence has ${sequence.length} numbers.';
      case 1:
        return 'The first number is ${sequence.first}.';
      case 2:
        return 'The last number is ${sequence.last}.';
      default:
        return 'Try chunking the numbers into groups.';
    }
  }

  String _getPatternMemoryHint(Puzzle puzzle, Map<String, dynamic> state, int hintNumber) {
    final gridSize = puzzle.data['gridSize'] as int;
    final pattern = puzzle.solution['pattern'] as List<bool>;
    final fillCount = pattern.where((filled) => filled).length;

    switch (hintNumber) {
      case 0:
        return 'The grid is ${gridSize}x$gridSize.';
      case 1:
        return 'There are $fillCount filled cells.';
      case 2:
        return 'Try to remember the pattern by sections.';
      default:
        return 'Focus on one row at a time.';
    }
  }

  String _getSudokuHint(Puzzle puzzle, Map<String, dynamic> state, int hintNumber) {
    switch (hintNumber) {
      case 0:
        return 'Each row must contain unique numbers.';
      case 1:
        return 'Each column must also contain unique numbers.';
      case 2:
        return 'Start with rows/columns that have the most clues.';
      default:
        return 'Use process of elimination.';
    }
  }

  String _getLogicGridHint(Puzzle puzzle, Map<String, dynamic> state, int hintNumber) {
    switch (hintNumber) {
      case 0:
        return 'Read all clues carefully before starting.';
      case 1:
        return 'Mark impossible combinations with X.';
      case 2:
        return 'When you find a match, eliminate other options.';
      default:
        return 'Work through the clues systematically.';
    }
  }

  String _getCodeBreakerHint(Puzzle puzzle, Map<String, dynamic> state, int hintNumber) {
    final code = puzzle.solution['code'] as List<int>;
    switch (hintNumber) {
      case 0:
        return 'The code has ${code.length} digits.';
      case 1:
        return 'Each digit is between 1 and 6.';
      case 2:
        return 'The first digit is ${code.first}.';
      default:
        return 'Use feedback from previous guesses.';
    }
  }

  String _getWordBuilderHint(Puzzle puzzle, Map<String, dynamic> state, int hintNumber) {
    final letters = puzzle.data['letters'] as String;
    switch (hintNumber) {
      case 0:
        return 'You have ${letters.length} letters to work with.';
      case 1:
        return 'Look for common word patterns like -ING or -ED.';
      case 2:
        return 'Try rearranging vowels and consonants.';
      default:
        return 'Longer words score more points.';
    }
  }

  String _getAnagramHint(Puzzle puzzle, Map<String, dynamic> state, int hintNumber) {
    final solution = puzzle.solution['word'] as String;
    switch (hintNumber) {
      case 0:
        return 'The word has ${solution.length} letters.';
      case 1:
        return 'The first letter is ${solution[0]}.';
      case 2:
        return 'The last letter is ${solution[solution.length - 1]}.';
      default:
        return 'Try saying the letters out loud.';
    }
  }
}

/// Hint result model
class HintResult {
  final String? hint;
  final int hintsRemaining;
  final int penalty;
  final bool maxReached;

  HintResult({
    required this.hint,
    required this.hintsRemaining,
    required this.penalty,
    required this.maxReached,
  });
}

/**
 * Daily Challenge System - Feature 3.6.3
 * Rotates challenges daily with special rewards
 */

class DailyChallengeSystem {
  static const String challengePrefix = 'daily_challenge_';

  /// Get daily challenge for today
  DailyChallenge getTodaysChallenge({
    required GameContentGenerator generator,
  }) {
    final today = DateTime.now();
    final dateKey = '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';

    // Use date as seed for consistent daily challenge
    final seed = dateKey.hashCode;
    final gameTypes = [
      'memory_match',
      'sequence_recall',
      'pattern_memory',
      'sudoku_duel',
      'logic_grid',
      'code_breaker',
      'spot_difference',
      'color_rush',
      'focus_finder',
      'puzzle_race',
      'rotation_master',
      'path_finder',
      'word_builder',
      'anagram_attack',
      'vocabulary_showdown',
    ];

    // Select game type based on day
    final gameType = gameTypes[seed.abs() % gameTypes.length];

    // Generate challenge puzzle (always hard difficulty for daily challenge)
    final puzzle = generator.generatePuzzle(
      gameType: gameType,
      difficulty: Difficulty.hard,
    );

    return DailyChallenge(
      id: '$challengePrefix$dateKey',
      date: today,
      puzzle: puzzle,
      bonusMultiplier: 1.5,
      expiresAt: DateTime(today.year, today.month, today.day, 23, 59, 59),
    );
  }

  /// Check if player has completed today's challenge
  bool hasCompletedToday(String playerId, Set<String> completedChallenges) {
    final today = DateTime.now();
    final dateKey = '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
    final challengeId = '$challengePrefix$dateKey';

    return completedChallenges.contains('${playerId}_$challengeId');
  }

  /// Get challenge history (last 7 days)
  List<DailyChallenge> getChallengeHistory({
    required GameContentGenerator generator,
    int days = 7,
  }) {
    final challenges = <DailyChallenge>[];
    final today = DateTime.now();

    for (var i = 0; i < days; i++) {
      // Note: This would need to be enhanced to generate consistent challenges
      // for past dates using the same seed logic as getTodaysChallenge
    }

    return challenges;
  }

  /// Get streak count
  int getStreakCount(Set<String> completedChallenges, String playerId) {
    var streak = 0;
    final today = DateTime.now();

    for (var i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
      final challengeId = '$challengePrefix$dateKey';

      if (completedChallenges.contains('${playerId}_$challengeId')) {
        streak++;
      } else {
        break; // Streak broken
      }
    }

    return streak;
  }
}

/// Daily challenge model
class DailyChallenge {
  final String id;
  final DateTime date;
  final Puzzle puzzle;
  final double bonusMultiplier;
  final DateTime expiresAt;

  DailyChallenge({
    required this.id,
    required this.date,
    required this.puzzle,
    required this.bonusMultiplier,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'puzzle': puzzle.toJson(),
        'bonusMultiplier': bonusMultiplier,
        'expiresAt': expiresAt.toIso8601String(),
      };
}
