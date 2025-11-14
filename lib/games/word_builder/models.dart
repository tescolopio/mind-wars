/**
 * Word Builder Game - Data Models
 * Core data structures for cascade-chain word building game
 */

import 'package:equatable/equatable.dart';

/// Represents a single tile in the grid
class TileData extends Equatable {
  final String letter;
  final int index; // 0-8 for 3x3 grid
  final bool isAnchor; // Does not cascade (Intermediate+)
  final bool isGolden; // One-time double multiplier (Advanced)
  final bool isLocked; // Requires long word to unlock (Expert)
  final int? unlockRequirement; // Minimum word length to unlock

  const TileData({
    required this.letter,
    required this.index,
    this.isAnchor = false,
    this.isGolden = false,
    this.isLocked = false,
    this.unlockRequirement,
  });

  TileData copyWith({
    String? letter,
    int? index,
    bool? isAnchor,
    bool? isGolden,
    bool? isLocked,
    int? unlockRequirement,
  }) {
    return TileData(
      letter: letter ?? this.letter,
      index: index ?? this.index,
      isAnchor: isAnchor ?? this.isAnchor,
      isGolden: isGolden ?? this.isGolden,
      isLocked: isLocked ?? this.isLocked,
      unlockRequirement: unlockRequirement ?? this.unlockRequirement,
    );
  }

  @override
  List<Object?> get props => [
        letter,
        index,
        isAnchor,
        isGolden,
        isLocked,
        unlockRequirement,
      ];
}

/// Represents the state of the 3x3 grid
class GridState extends Equatable {
  final List<TileData> tiles; // Always 9 tiles for 3x3 grid
  final int moveCount;
  final String? lastWordEndChar; // For chain rule enforcement

  const GridState({
    required this.tiles,
    this.moveCount = 0,
    this.lastWordEndChar,
  });

  GridState copyWith({
    List<TileData>? tiles,
    int? moveCount,
    String? lastWordEndChar,
  }) {
    return GridState(
      tiles: tiles ?? this.tiles,
      moveCount: moveCount ?? this.moveCount,
      lastWordEndChar: lastWordEndChar,
    );
  }

  /// Get tile at specific index
  TileData getTile(int index) => tiles[index];

  /// Get adjacent tile indices (Boggle-style: horizontal, vertical, diagonal)
  List<int> getAdjacentIndices(int index) {
    final row = index ~/ 3;
    final col = index % 3;
    final adjacent = <int>[];

    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue; // Skip self
        final newRow = row + dr;
        final newCol = col + dc;
        if (newRow >= 0 && newRow < 3 && newCol >= 0 && newCol < 3) {
          adjacent.add(newRow * 3 + newCol);
        }
      }
    }
    return adjacent;
  }

  @override
  List<Object?> get props => [tiles, moveCount, lastWordEndChar];
}

/// Represents a single move/word submission
class MoveRecord extends Equatable {
  final String word;
  final List<int> pathIndices; // Indices of tiles used
  final int score;
  final DateTime timestamp;
  final bool isPangram;
  final bool usedGoldenTile;
  final ScoreBreakdown breakdown;

  const MoveRecord({
    required this.word,
    required this.pathIndices,
    required this.score,
    required this.timestamp,
    this.isPangram = false,
    this.usedGoldenTile = false,
    required this.breakdown,
  });

  @override
  List<Object?> get props => [
        word,
        pathIndices,
        score,
        timestamp,
        isPangram,
        usedGoldenTile,
        breakdown,
      ];
}

/// Detailed breakdown of word score
class ScoreBreakdown extends Equatable {
  final int baseScore; // length²
  final int rarityBonus; // 0, 5, 10, 15, 25
  final int patternBonus; // +5 for prefix/suffix/compound
  final int pangramBonus; // +50
  final double multiplier; // From efficiency, golden tiles, etc.
  final int finalScore;

  const ScoreBreakdown({
    required this.baseScore,
    this.rarityBonus = 0,
    this.patternBonus = 0,
    this.pangramBonus = 0,
    this.multiplier = 1.0,
    required this.finalScore,
  });

  @override
  List<Object?> get props => [
        baseScore,
        rarityBonus,
        patternBonus,
        pangramBonus,
        multiplier,
        finalScore,
      ];
}

/// Difficulty level for puzzle configuration
enum DifficultyLevel {
  beginner, // No chain rule, no special tiles
  intermediate, // Chain rule optional, anchor tiles
  advanced, // Chain rule enforced, golden tiles
  expert, // All features, locked tiles
}

/// Configuration for a puzzle
class PuzzleConfig extends Equatable {
  final int seed; // For deterministic PRNG
  final DifficultyLevel difficulty;
  final bool chainRuleEnabled;
  final int targetWordCount; // Target words to complete round
  final int? timeLimit; // Optional time limit in seconds

  const PuzzleConfig({
    required this.seed,
    required this.difficulty,
    required this.chainRuleEnabled,
    this.targetWordCount = 10,
    this.timeLimit,
  });

  @override
  List<Object?> get props => [
        seed,
        difficulty,
        chainRuleEnabled,
        targetWordCount,
        timeLimit,
      ];
}

/// Metadata about a puzzle (precomputed by PuzzleEvaluator)
class PuzzleMetadata extends Equatable {
  final int seed;
  final int maxPossiblePoints;
  final int maxPossibleWords;
  final bool hasPangram;
  final DifficultyLevel suggestedDifficulty;
  final List<int> solutionLengthDistribution; // Count by word length

  const PuzzleMetadata({
    required this.seed,
    required this.maxPossiblePoints,
    required this.maxPossibleWords,
    required this.hasPangram,
    required this.suggestedDifficulty,
    required this.solutionLengthDistribution,
  });

  @override
  List<Object?> get props => [
        seed,
        maxPossiblePoints,
        maxPossibleWords,
        hasPangram,
        suggestedDifficulty,
        solutionLengthDistribution,
      ];
}

/// Complete game session state
class GameSession extends Equatable {
  final String sessionId;
  final PuzzleConfig config;
  final GridState currentGrid;
  final List<MoveRecord> moves;
  final int totalScore;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isComplete;

  const GameSession({
    required this.sessionId,
    required this.config,
    required this.currentGrid,
    required this.moves,
    required this.totalScore,
    required this.startTime,
    this.endTime,
    this.isComplete = false,
  });

  GameSession copyWith({
    String? sessionId,
    PuzzleConfig? config,
    GridState? currentGrid,
    List<MoveRecord>? moves,
    int? totalScore,
    DateTime? startTime,
    DateTime? endTime,
    bool? isComplete,
  }) {
    return GameSession(
      sessionId: sessionId ?? this.sessionId,
      config: config ?? this.config,
      currentGrid: currentGrid ?? this.currentGrid,
      moves: moves ?? this.moves,
      totalScore: totalScore ?? this.totalScore,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  List<Object?> get props => [
        sessionId,
        config,
        currentGrid,
        moves,
        totalScore,
        startTime,
        endTime,
        isComplete,
      ];
}
