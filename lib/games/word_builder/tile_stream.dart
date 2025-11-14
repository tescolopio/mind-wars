/**
 * Word Builder Game - Tile Stream
 * Deterministic tile generation using seeded PRNG
 */

import 'dart:math';

/// Deterministic tile stream for reproducible puzzle generation
class TileStream {
  final Random _random;
  final int seed;
  
  // Letter frequency distribution for English (approximate)
  static const List<String> _letterPool = [
    'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', // 12 E's (12%)
    'T', 'T', 'T', 'T', 'T', 'T', 'T', 'T', 'T', // 9 T's (9%)
    'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', // 8 A's (8%)
    'O', 'O', 'O', 'O', 'O', 'O', 'O', 'O', // 8 O's (8%)
    'I', 'I', 'I', 'I', 'I', 'I', 'I', // 7 I's (7%)
    'N', 'N', 'N', 'N', 'N', 'N', 'N', // 7 N's (7%)
    'S', 'S', 'S', 'S', 'S', 'S', // 6 S's (6%)
    'H', 'H', 'H', 'H', 'H', 'H', // 6 H's (6%)
    'R', 'R', 'R', 'R', 'R', 'R', // 6 R's (6%)
    'D', 'D', 'D', 'D', // 4 D's (4%)
    'L', 'L', 'L', 'L', // 4 L's (4%)
    'C', 'C', 'C', // 3 C's (3%)
    'U', 'U', 'U', // 3 U's (3%)
    'M', 'M', 'M', // 3 M's (3%)
    'W', 'W', // 2 W's (2%)
    'F', 'F', // 2 F's (2%)
    'G', 'G', // 2 G's (2%)
    'Y', 'Y', // 2 Y's (2%)
    'P', 'P', // 2 P's (2%)
    'B', 'B', // 2 B's (2%)
    'V', // 1 V (1%)
    'K', // 1 K (1%)
    'J', // 1 J (1%)
    'X', // 1 X (1%)
    'Q', // 1 Q (1%)
    'Z', // 1 Z (1%)
  ];

  TileStream(this.seed) : _random = Random(seed);

  /// Get the next letter from the stream
  String nextLetter() {
    return _letterPool[_random.nextInt(_letterPool.length)];
  }

  /// Generate initial grid (9 tiles for 3x3)
  List<String> generateInitialGrid() {
    final grid = <String>[];
    for (int i = 0; i < 9; i++) {
      grid.add(nextLetter());
    }
    return grid;
  }

  /// Generate refill letters for specific positions (column-major order)
  /// This ensures deterministic refill behavior for gravity
  List<String> generateRefill(int count) {
    final refill = <String>[];
    for (int i = 0; i < count; i++) {
      refill.add(nextLetter());
    }
    return refill;
  }

  /// Reset to beginning of stream (create new Random with same seed)
  TileStream reset() {
    return TileStream(seed);
  }

  /// Generate special tile configuration based on difficulty
  /// Returns map of index -> special tile type
  Map<int, String> generateSpecialTiles(String difficulty) {
    final special = <int, String>{};
    
    switch (difficulty.toLowerCase()) {
      case 'intermediate':
        // Add 1-2 anchor tiles
        final anchorCount = 1 + _random.nextInt(2); // 1-2 anchor tiles
        for (int i = 0; i < anchorCount; i++) {
          int index;
          do {
            index = _random.nextInt(9);
          } while (special.containsKey(index));
          special[index] = 'anchor';
        }
        break;
        
      case 'advanced':
        // Add 1 anchor and 1-2 golden tiles
        int anchorIndex = _random.nextInt(9);
        special[anchorIndex] = 'anchor';
        
        final goldenCount = 1 + _random.nextInt(2); // 1-2 golden tiles
        for (int i = 0; i < goldenCount; i++) {
          int index;
          do {
            index = _random.nextInt(9);
          } while (special.containsKey(index));
          special[index] = 'golden';
        }
        break;
        
      case 'expert':
        // Add 1 anchor, 1 golden, and 1-2 locked tiles
        int anchorIndex = _random.nextInt(9);
        special[anchorIndex] = 'anchor';
        
        int goldenIndex;
        do {
          goldenIndex = _random.nextInt(9);
        } while (special.containsKey(goldenIndex));
        special[goldenIndex] = 'golden';
        
        final lockedCount = 1 + _random.nextInt(2); // 1-2 locked tiles
        for (int i = 0; i < lockedCount; i++) {
          int index;
          do {
            index = _random.nextInt(9);
          } while (special.containsKey(index));
          special[index] = 'locked';
        }
        break;
        
      default: // beginner
        // No special tiles
        break;
    }
    
    return special;
  }
}
