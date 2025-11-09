/**
 * Tests for Game Content Generator
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_wars/services/game_content_generator.dart';
import 'package:mind_wars/models/models.dart';

void main() {
  group('GameContentGenerator', () {
    late GameContentGenerator generator;

    setUp(() {
      generator = GameContentGenerator();
    });

    test('should generate puzzle for each game type', () {
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

      for (var gameType in gameTypes) {
        final puzzle = generator.generatePuzzle(
          gameType: gameType,
          difficulty: Difficulty.medium,
        );

        expect(puzzle.gameType, equals(gameType));
        expect(puzzle.difficulty, equals(Difficulty.medium));
        expect(puzzle.maxScore, greaterThan(0));
        expect(puzzle.timeLimit, greaterThan(0));
        expect(puzzle.data, isNotEmpty);
      }
    });

    test('should generate puzzles with different difficulties', () {
      final easy = generator.generatePuzzle(
        gameType: 'memory_match',
        difficulty: Difficulty.easy,
      );
      final medium = generator.generatePuzzle(
        gameType: 'memory_match',
        difficulty: Difficulty.medium,
      );
      final hard = generator.generatePuzzle(
        gameType: 'memory_match',
        difficulty: Difficulty.hard,
      );

      expect(easy.difficulty, equals(Difficulty.easy));
      expect(medium.difficulty, equals(Difficulty.medium));
      expect(hard.difficulty, equals(Difficulty.hard));

      // Harder difficulties should have higher max scores
      expect(easy.maxScore, lessThan(medium.maxScore));
      expect(medium.maxScore, lessThan(hard.maxScore));
    });

    test('should generate puzzle set with multiple difficulties', () {
      final puzzles = generator.generatePuzzleSet(
        gameType: 'word_builder',
        count: 3,
      );

      expect(puzzles.length, equals(3));
      expect(puzzles.every((p) => p.gameType == 'word_builder'), isTrue);
    });

    test('should generate all content (15 games x 3 difficulties)', () {
      final allContent = generator.generateAllContent();

      expect(allContent.length, equals(15));
      expect(allContent.values.every((puzzles) => puzzles.length == 3), isTrue);

      // Check categories are covered
      final categories = allContent.values
          .expand((puzzles) => puzzles)
          .map((p) => p.category)
          .toSet();
      expect(categories.length, equals(5)); // All 5 cognitive categories
    });

    test('memory match puzzle should have valid card count', () {
      final puzzle = generator.generatePuzzle(
        gameType: 'memory_match',
        difficulty: Difficulty.medium,
      );

      final cards = puzzle.data['cards'] as List;
      expect(cards.length % 2, equals(0)); // Even number of cards
      expect(cards.length, greaterThanOrEqualTo(8)); // At least 4 pairs
    });

    test('sequence recall puzzle should have increasing length with difficulty', () {
      final easy = generator.generatePuzzle(
        gameType: 'sequence_recall',
        difficulty: Difficulty.easy,
      );
      final hard = generator.generatePuzzle(
        gameType: 'sequence_recall',
        difficulty: Difficulty.hard,
      );

      final easySeq = easy.data['sequence'] as List;
      final hardSeq = hard.data['sequence'] as List;

      expect(easySeq.length, lessThan(hardSeq.length));
    });

    test('anagram puzzle should have scrambled word and solution', () {
      final puzzle = generator.generatePuzzle(
        gameType: 'anagram_attack',
        difficulty: Difficulty.medium,
      );

      expect(puzzle.data['scrambledWord'], isNotNull);
      expect(puzzle.solution['word'], isNotNull);

      final scrambled = puzzle.data['scrambledWord'] as String;
      final solution = puzzle.solution['word'] as String;

      expect(scrambled.length, equals(solution.length));
      expect(scrambled, isNot(equals(solution))); // Should be scrambled
    });

    test('puzzles should have unique IDs', () {
      final puzzle1 = generator.generatePuzzle(
        gameType: 'memory_match',
        difficulty: Difficulty.easy,
      );
      final puzzle2 = generator.generatePuzzle(
        gameType: 'memory_match',
        difficulty: Difficulty.easy,
      );

      expect(puzzle1.id, isNot(equals(puzzle2.id)));
    });
  });
}
