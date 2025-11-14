/**
 * Word Builder Game - Grid Engine
 * Core game mechanics: adjacency, path validation, gravity, refill
 */

import 'models.dart';
import 'tile_stream.dart';

/// Result of a word submission
class WordResult {
  final bool isValid;
  final String? errorMessage;
  final GridState? newGrid;
  final String? lastChar;
  final bool isPangram;
  final Set<String> uniqueLetters;

  const WordResult({
    required this.isValid,
    this.errorMessage,
    this.newGrid,
    this.lastChar,
    this.isPangram = false,
    required this.uniqueLetters,
  });
}

/// Grid engine for cascade-chain mechanics
class GridEngine {
  final TileStream tileStream;
  
  GridEngine(this.tileStream);

  /// Validate that a path follows Boggle-style adjacency rules
  /// Each tile must be adjacent to the previous tile (horizontal, vertical, or diagonal)
  bool validateAdjacency(List<int> pathIndices, GridState grid) {
    if (pathIndices.length < 2) return true;

    for (int i = 1; i < pathIndices.length; i++) {
      final prevIndex = pathIndices[i - 1];
      final currIndex = pathIndices[i];
      
      final adjacentIndices = grid.getAdjacentIndices(prevIndex);
      if (!adjacentIndices.contains(currIndex)) {
        return false;
      }
    }
    return true;
  }

  /// Validate that path doesn't reuse tiles
  bool validatePathUniqueness(List<int> pathIndices) {
    final uniqueIndices = pathIndices.toSet();
    return uniqueIndices.length == pathIndices.length;
  }

  /// Check if tiles in path are available (not locked or unavailable)
  bool validateTileAvailability(List<int> pathIndices, GridState grid) {
    for (final index in pathIndices) {
      final tile = grid.getTile(index);
      if (tile.isLocked && tile.unlockRequirement != null) {
        // Locked tile - will be validated separately
        return false;
      }
    }
    return true;
  }

  /// Submit a word and process the grid
  WordResult submitWord(
    String word,
    List<int> pathIndices,
    GridState currentGrid,
    bool chainRuleEnabled,
  ) {
    // Validate minimum length
    if (word.length < 3) {
      return const WordResult(
        isValid: false,
        errorMessage: 'Word must be at least 3 letters',
        uniqueLetters: {},
      );
    }

    // Validate path length matches word length
    if (pathIndices.length != word.length) {
      return const WordResult(
        isValid: false,
        errorMessage: 'Path length does not match word length',
        uniqueLetters: {},
      );
    }

    // Validate adjacency
    if (!validateAdjacency(pathIndices, currentGrid)) {
      return const WordResult(
        isValid: false,
        errorMessage: 'Tiles must be adjacent',
        uniqueLetters: {},
      );
    }

    // Validate path uniqueness
    if (!validatePathUniqueness(pathIndices)) {
      return const WordResult(
        isValid: false,
        errorMessage: 'Cannot reuse tiles in same word',
        uniqueLetters: {},
      );
    }

    // Validate tile availability (not locked)
    if (!validateTileAvailability(pathIndices, currentGrid)) {
      return const WordResult(
        isValid: false,
        errorMessage: 'Cannot use locked tiles',
        uniqueLetters: {},
      );
    }

    // Validate letters match
    final expectedWord = pathIndices.map((i) => currentGrid.getTile(i).letter).join();
    if (expectedWord.toUpperCase() != word.toUpperCase()) {
      return const WordResult(
        isValid: false,
        errorMessage: 'Letters do not match path',
        uniqueLetters: {},
      );
    }

    // Check chain rule if enabled
    if (chainRuleEnabled && currentGrid.lastWordEndChar != null) {
      if (word[0].toUpperCase() != currentGrid.lastWordEndChar!.toUpperCase()) {
        return WordResult(
          isValid: false,
          errorMessage: 'Word must start with ${currentGrid.lastWordEndChar}',
          uniqueLetters: {},
        );
      }
    }

    // Check for pangram (all 9 unique letters used)
    final uniqueLetters = pathIndices.map((i) => currentGrid.getTile(i).letter).toSet();
    final isPangram = uniqueLetters.length == 9;

    // Process grid: remove tiles, apply gravity, refill
    final newGrid = _processGridAfterWord(currentGrid, pathIndices, word);

    return WordResult(
      isValid: true,
      newGrid: newGrid,
      lastChar: word[word.length - 1].toUpperCase(),
      isPangram: isPangram,
      uniqueLetters: uniqueLetters,
    );
  }

  /// Process grid after a valid word: remove tiles, apply gravity, refill
  GridState _processGridAfterWord(
    GridState currentGrid,
    List<int> pathIndices,
    String word,
  ) {
    // Create mutable copy of tiles
    final newTiles = List<TileData?>.from(currentGrid.tiles);

    // Remove used tiles (but keep anchors)
    for (final index in pathIndices) {
      final tile = newTiles[index];
      if (tile != null && !tile.isAnchor) {
        newTiles[index] = null; // Mark for removal
      }
    }

    // Apply gravity: column-major, top to bottom
    // For each column (0, 1, 2), move non-null tiles down
    for (int col = 0; col < 3; col++) {
      final columnIndices = [col, col + 3, col + 6]; // Top to bottom
      final columnTiles = <TileData>[];

      // Collect non-null tiles in this column
      for (final idx in columnIndices) {
        if (newTiles[idx] != null) {
          columnTiles.add(newTiles[idx]!);
        }
      }

      // Calculate how many new tiles we need
      final tilesNeeded = 3 - columnTiles.length;

      // Generate new tiles from stream
      final newLetters = tileStream.generateRefill(tilesNeeded);
      final refillTiles = newLetters.asMap().entries.map((entry) {
        return TileData(
          letter: entry.value,
          index: col + entry.key * 3, // Temporary, will be updated
        );
      }).toList();

      // Combine: new tiles at top, existing tiles at bottom
      final combinedColumn = [...refillTiles, ...columnTiles];

      // Place back in grid with correct indices
      for (int i = 0; i < 3; i++) {
        final gridIndex = col + i * 3;
        newTiles[gridIndex] = combinedColumn[i].copyWith(index: gridIndex);
      }
    }

    // Create new grid state
    return currentGrid.copyWith(
      tiles: newTiles.cast<TileData>(),
      moveCount: currentGrid.moveCount + 1,
      lastWordEndChar: word[word.length - 1].toUpperCase(),
    );
  }

  /// Initialize grid from seed
  static GridState initializeGrid(int seed, DifficultyLevel difficulty) {
    final stream = TileStream(seed);
    final letters = stream.generateInitialGrid();
    
    // Generate special tiles based on difficulty
    String difficultyStr;
    switch (difficulty) {
      case DifficultyLevel.beginner:
        difficultyStr = 'beginner';
        break;
      case DifficultyLevel.intermediate:
        difficultyStr = 'intermediate';
        break;
      case DifficultyLevel.advanced:
        difficultyStr = 'advanced';
        break;
      case DifficultyLevel.expert:
        difficultyStr = 'expert';
        break;
    }
    
    final specialTiles = stream.generateSpecialTiles(difficultyStr);
    
    // Create tiles
    final tiles = <TileData>[];
    for (int i = 0; i < 9; i++) {
      final special = specialTiles[i];
      tiles.add(TileData(
        letter: letters[i],
        index: i,
        isAnchor: special == 'anchor',
        isGolden: special == 'golden',
        isLocked: special == 'locked',
        unlockRequirement: special == 'locked' ? 5 : null, // Require 5-letter word
      ));
    }

    return GridState(tiles: tiles);
  }

  /// Check if any legal moves remain
  /// (Simple heuristic: check if enough vowels and consonants exist)
  bool hasLegalMoves(GridState grid) {
    final letters = grid.tiles.where((t) => !t.isLocked).map((t) => t.letter).toList();
    if (letters.length < 3) return false;

    final vowels = letters.where((l) => 'AEIOU'.contains(l)).length;
    final consonants = letters.length - vowels;

    // Need at least 1 vowel and 2 consonants (or vice versa) for potential words
    return (vowels >= 1 && consonants >= 2) || (vowels >= 2 && consonants >= 1);
  }
}
