/**
 * Unit tests for TileStream
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_wars/games/word_builder/tile_stream.dart';

void main() {
  group('TileStream', () {
    test('should generate deterministic sequence from same seed', () {
      final stream1 = TileStream(12345);
      final stream2 = TileStream(12345);

      final grid1 = stream1.generateInitialGrid();
      final grid2 = stream2.generateInitialGrid();

      expect(grid1, equals(grid2));
      expect(grid1.length, equals(9));
    });

    test('should generate different sequences from different seeds', () {
      final stream1 = TileStream(12345);
      final stream2 = TileStream(54321);

      final grid1 = stream1.generateInitialGrid();
      final grid2 = stream2.generateInitialGrid();

      expect(grid1, isNot(equals(grid2)));
    });

    test('should generate refill deterministically', () {
      final stream1 = TileStream(12345);
      final stream2 = TileStream(12345);

      // Consume initial grid
      stream1.generateInitialGrid();
      stream2.generateInitialGrid();

      final refill1 = stream1.generateRefill(3);
      final refill2 = stream2.generateRefill(3);

      expect(refill1, equals(refill2));
      expect(refill1.length, equals(3));
    });

    test('should generate valid letters from pool', () {
      final stream = TileStream(12345);
      final grid = stream.generateInitialGrid();

      for (final letter in grid) {
        expect(letter.length, equals(1));
        expect(letter.codeUnitAt(0), greaterThanOrEqualTo(65)); // 'A' or higher
        expect(letter.codeUnitAt(0), lessThanOrEqualTo(90)); // 'Z' or lower
      }
    });

    test('should reset stream with same seed', () {
      final stream1 = TileStream(12345);
      final grid1 = stream1.generateInitialGrid();

      final stream2 = stream1.reset();
      final grid2 = stream2.generateInitialGrid();

      expect(grid1, equals(grid2));
    });

    test('should generate special tiles for intermediate difficulty', () {
      final stream = TileStream(12345);
      final special = stream.generateSpecialTiles('intermediate');

      // Should have 1-2 anchor tiles
      final anchorCount = special.values.where((v) => v == 'anchor').length;
      expect(anchorCount, greaterThan(0));
      expect(anchorCount, lessThanOrEqualTo(2));
    });

    test('should generate special tiles for advanced difficulty', () {
      final stream = TileStream(12345);
      final special = stream.generateSpecialTiles('advanced');

      // Should have anchor and golden tiles
      expect(special.values.where((v) => v == 'anchor').length, equals(1));
      expect(special.values.where((v) => v == 'golden').length, greaterThan(0));
    });

    test('should generate special tiles for expert difficulty', () {
      final stream = TileStream(12345);
      final special = stream.generateSpecialTiles('expert');

      // Should have anchor, golden, and locked tiles
      expect(special.values.where((v) => v == 'anchor').length, equals(1));
      expect(special.values.where((v) => v == 'golden').length, equals(1));
      expect(special.values.where((v) => v == 'locked').length, greaterThan(0));
    });

    test('should generate no special tiles for beginner difficulty', () {
      final stream = TileStream(12345);
      final special = stream.generateSpecialTiles('beginner');

      expect(special.isEmpty, isTrue);
    });

    test('should not overlap special tile positions', () {
      final stream = TileStream(12345);
      final special = stream.generateSpecialTiles('expert');

      final indices = special.keys.toList();
      final uniqueIndices = indices.toSet();

      expect(indices.length, equals(uniqueIndices.length));
    });
  });
}
