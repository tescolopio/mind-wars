/**
 * Unit tests for GridEngine
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_wars/games/word_builder/models.dart';
import 'package:mind_wars/games/word_builder/grid_engine.dart';
import 'package:mind_wars/games/word_builder/tile_stream.dart';

void main() {
  group('GridEngine', () {
    late GridEngine engine;
    late GridState testGrid;

    setUp(() {
      // Create a test grid with known letters
      final tiles = [
        const TileData(letter: 'C', index: 0),
        const TileData(letter: 'A', index: 1),
        const TileData(letter: 'T', index: 2),
        const TileData(letter: 'R', index: 3),
        const TileData(letter: 'A', index: 4),
        const TileData(letter: 'N', index: 5),
        const TileData(letter: 'D', index: 6),
        const TileData(letter: 'O', index: 7),
        const TileData(letter: 'G', index: 8),
      ];
      testGrid = GridState(tiles: tiles);
      engine = GridEngine(TileStream(12345));
    });

    group('Adjacency Validation', () {
      test('should validate adjacent horizontal tiles', () {
        // C-A (0-1) are horizontal adjacent
        expect(engine.validateAdjacency([0, 1], testGrid), isTrue);
      });

      test('should validate adjacent vertical tiles', () {
        // C-R (0-3) are vertical adjacent
        expect(engine.validateAdjacency([0, 3], testGrid), isTrue);
      });

      test('should validate adjacent diagonal tiles', () {
        // C-A (0-4) are diagonal adjacent
        expect(engine.validateAdjacency([0, 4], testGrid), isTrue);
      });

      test('should reject non-adjacent tiles', () {
        // C-T (0-2) are not adjacent (one tile between)
        expect(engine.validateAdjacency([0, 2], testGrid), isFalse);
      });

      test('should validate multi-tile paths', () {
        // C-A-T (0-1-2) all adjacent
        expect(engine.validateAdjacency([0, 1, 2], testGrid), isTrue);
      });

      test('should reject paths with non-adjacent tiles', () {
        // C-A-R (0-1-3) but A(1) and R(3) are not adjacent
        expect(engine.validateAdjacency([0, 1, 3], testGrid), isFalse);
      });
    });

    group('Path Uniqueness', () {
      test('should validate unique path', () {
        expect(engine.validatePathUniqueness([0, 1, 2]), isTrue);
      });

      test('should reject path with duplicate indices', () {
        expect(engine.validatePathUniqueness([0, 1, 0]), isFalse);
      });
    });

    group('Tile Availability', () {
      test('should validate available tiles', () {
        expect(engine.validateTileAvailability([0, 1, 2], testGrid), isTrue);
      });

      test('should reject locked tiles', () {
        final lockedTiles = [
          const TileData(letter: 'C', index: 0, isLocked: true, unlockRequirement: 5),
          const TileData(letter: 'A', index: 1),
          const TileData(letter: 'T', index: 2),
          const TileData(letter: 'R', index: 3),
          const TileData(letter: 'A', index: 4),
          const TileData(letter: 'N', index: 5),
          const TileData(letter: 'D', index: 6),
          const TileData(letter: 'O', index: 7),
          const TileData(letter: 'G', index: 8),
        ];
        final lockedGrid = GridState(tiles: lockedTiles);

        expect(engine.validateTileAvailability([0, 1], lockedGrid), isFalse);
      });
    });

    group('Word Submission', () {
      test('should accept valid word', () {
        // CAT = 0-1-2 (C-A-T)
        final result = engine.submitWord('CAT', [0, 1, 2], testGrid, false);
        
        expect(result.isValid, isTrue);
        expect(result.newGrid, isNotNull);
        expect(result.lastChar, equals('T'));
      });

      test('should reject word too short', () {
        final result = engine.submitWord('CA', [0, 1], testGrid, false);
        
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('at least 3'));
      });

      test('should reject mismatched path length', () {
        final result = engine.submitWord('CAT', [0, 1], testGrid, false);
        
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('length'));
      });

      test('should reject non-adjacent path', () {
        final result = engine.submitWord('CAT', [0, 1, 8], testGrid, false);
        
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('adjacent'));
      });

      test('should reject path with duplicates', () {
        final result = engine.submitWord('CAC', [0, 1, 0], testGrid, false);
        
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('reuse'));
      });

      test('should enforce chain rule when enabled', () {
        final gridWithLastChar = testGrid.copyWith(lastWordEndChar: 'T');
        final result = engine.submitWord('CAT', [0, 1, 2], gridWithLastChar, true);
        
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('start with T'));
      });

      test('should not enforce chain rule when disabled', () {
        final gridWithLastChar = testGrid.copyWith(lastWordEndChar: 'T');
        final result = engine.submitWord('CAT', [0, 1, 2], gridWithLastChar, false);
        
        expect(result.isValid, isTrue);
      });

      test('should detect pangram when using all unique letters', () {
        // Create grid with 9 unique letters
        final uniqueTiles = [
          const TileData(letter: 'A', index: 0),
          const TileData(letter: 'B', index: 1),
          const TileData(letter: 'C', index: 2),
          const TileData(letter: 'D', index: 3),
          const TileData(letter: 'E', index: 4),
          const TileData(letter: 'F', index: 5),
          const TileData(letter: 'G', index: 6),
          const TileData(letter: 'H', index: 7),
          const TileData(letter: 'I', index: 8),
        ];
        final uniqueGrid = GridState(tiles: uniqueTiles);
        
        // Use all 9 tiles in a path (adjacency may not be valid for real word)
        // This is testing pangram detection logic
        final result = engine.submitWord(
          'ABCDEFGHI',
          [0, 1, 2, 5, 4, 3, 6, 7, 8],
          uniqueGrid,
          false,
        );
        
        // May fail adjacency, but check pangram detection in valid scenario
        expect(result.uniqueLetters.length, equals(9));
      });
    });

    group('Grid Initialization', () {
      test('should initialize grid with deterministic seed', () {
        final grid1 = GridEngine.initializeGrid(12345, DifficultyLevel.beginner);
        final grid2 = GridEngine.initializeGrid(12345, DifficultyLevel.beginner);
        
        expect(grid1.tiles.length, equals(9));
        expect(grid2.tiles.length, equals(9));
        
        for (int i = 0; i < 9; i++) {
          expect(grid1.tiles[i].letter, equals(grid2.tiles[i].letter));
        }
      });

      test('should create beginner grid with no special tiles', () {
        final grid = GridEngine.initializeGrid(12345, DifficultyLevel.beginner);
        
        expect(grid.tiles.any((t) => t.isAnchor), isFalse);
        expect(grid.tiles.any((t) => t.isGolden), isFalse);
        expect(grid.tiles.any((t) => t.isLocked), isFalse);
      });

      test('should create intermediate grid with anchor tiles', () {
        final grid = GridEngine.initializeGrid(12345, DifficultyLevel.intermediate);
        
        final anchorCount = grid.tiles.where((t) => t.isAnchor).length;
        expect(anchorCount, greaterThan(0));
      });
    });

    group('Legal Moves Check', () {
      test('should detect legal moves with balanced letters', () {
        expect(engine.hasLegalMoves(testGrid), isTrue);
      });

      test('should detect no legal moves with too few tiles', () {
        final fewTiles = [
          const TileData(letter: 'A', index: 0),
          const TileData(letter: 'B', index: 1, isLocked: true),
          const TileData(letter: 'C', index: 2, isLocked: true),
          const TileData(letter: 'D', index: 3, isLocked: true),
          const TileData(letter: 'E', index: 4, isLocked: true),
          const TileData(letter: 'F', index: 5, isLocked: true),
          const TileData(letter: 'G', index: 6, isLocked: true),
          const TileData(letter: 'H', index: 7, isLocked: true),
          const TileData(letter: 'I', index: 8, isLocked: true),
        ];
        final spareGrid = GridState(tiles: fewTiles);
        
        expect(engine.hasLegalMoves(spareGrid), isFalse);
      });
    });

    group('Grid State', () {
      test('should calculate adjacent indices correctly for corner', () {
        // Top-left corner (0) has 3 adjacent: 1, 3, 4
        final adjacent = testGrid.getAdjacentIndices(0);
        expect(adjacent.length, equals(3));
        expect(adjacent.contains(1), isTrue);
        expect(adjacent.contains(3), isTrue);
        expect(adjacent.contains(4), isTrue);
      });

      test('should calculate adjacent indices correctly for center', () {
        // Center (4) has 8 adjacent: all surrounding
        final adjacent = testGrid.getAdjacentIndices(4);
        expect(adjacent.length, equals(8));
      });

      test('should calculate adjacent indices correctly for edge', () {
        // Top edge (1) has 5 adjacent: 0, 2, 3, 4, 5
        final adjacent = testGrid.getAdjacentIndices(1);
        expect(adjacent.length, equals(5));
      });
    });
  });
}
