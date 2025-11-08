/**
 * Tests for Game Catalog
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_wars/games/game_catalog.dart';
import 'package:mind_wars/models/models.dart';

void main() {
  group('GameCatalog', () {
    test('should have 15 games total', () {
      final games = GameCatalog.getAllGames();
      expect(games.length, equals(15));
    });

    test('should have 3 games per category', () {
      final categories = GameCatalog.getAllCategories();
      
      for (var category in categories) {
        final gamesInCategory = GameCatalog.getGamesByCategory(category);
        expect(gamesInCategory.length, equals(3),
            reason: 'Category $category should have 3 games');
      }
    });

    test('should have all 5 cognitive categories', () {
      final categories = GameCatalog.getAllCategories();
      
      expect(categories.length, equals(5));
      expect(categories, contains(CognitiveCategory.memory));
      expect(categories, contains(CognitiveCategory.logic));
      expect(categories, contains(CognitiveCategory.attention));
      expect(categories, contains(CognitiveCategory.spatial));
      expect(categories, contains(CognitiveCategory.language));
    });

    test('should find game by ID', () {
      final game = GameCatalog.getGameById('memory_match');
      
      expect(game, isNotNull);
      expect(game!.name, equals('Memory Match'));
      expect(game.category, equals(CognitiveCategory.memory));
    });

    test('should return null for invalid game ID', () {
      final game = GameCatalog.getGameById('invalid_game');
      expect(game, isNull);
    });

    test('should filter games by player count (2 players)', () {
      final games = GameCatalog.getGamesForPlayerCount(2);
      
      expect(games.isNotEmpty, isTrue);
      for (var game in games) {
        expect(game.minPlayers, lessThanOrEqualTo(2));
        expect(game.maxPlayers, greaterThanOrEqualTo(2));
      }
    });

    test('should filter games by player count (10 players)', () {
      final games = GameCatalog.getGamesForPlayerCount(10);
      
      expect(games.isNotEmpty, isTrue);
      for (var game in games) {
        expect(game.minPlayers, lessThanOrEqualTo(10));
        expect(game.maxPlayers, greaterThanOrEqualTo(10));
      }
    });

    test('should get random game for valid player count', () {
      final game = GameCatalog.getRandomGame(4);
      
      expect(game, isNotNull);
      expect(game!.minPlayers, lessThanOrEqualTo(4));
      expect(game.maxPlayers, greaterThanOrEqualTo(4));
    });

    test('should return null for player count with no valid games', () {
      final game = GameCatalog.getRandomGame(100);
      expect(game, isNull);
    });

    test('should get category info', () {
      final info = GameCatalog.getCategoryInfo(CognitiveCategory.memory);
      
      expect(info['name'], equals('Memory'));
      expect(info['icon'], equals('🧠'));
      expect(info['description'], isNotEmpty);
    });

    test('should create game instance from template', () {
      final players = ['player1', 'player2', 'player3'];
      final game = GameCatalog.createGameInstance(
        'memory_match',
        'lobby123',
        players,
      );
      
      expect(game, isNotNull);
      expect(game!.name, equals('Memory Match'));
      expect(game.category, equals(CognitiveCategory.memory));
      expect(game.currentPlayerId, equals('player1'));
      expect(game.completed, isFalse);
      expect(game.state['players'], equals(players));
      expect(game.state['scores'], isNotEmpty);
    });

    test('should return null when creating instance with invalid template', () {
      final game = GameCatalog.createGameInstance(
        'invalid_game',
        'lobby123',
        ['player1'],
      );
      
      expect(game, isNull);
    });

    test('all games should support at least 2 players', () {
      final games = GameCatalog.getAllGames();
      
      for (var game in games) {
        expect(game.minPlayers, greaterThanOrEqualTo(2),
            reason: '${game.name} should support at least 2 players');
        expect(game.maxPlayers, greaterThanOrEqualTo(game.minPlayers),
            reason: '${game.name} max players should be >= min players');
      }
    });

    test('should have games that support 10 players', () {
      final games = GameCatalog.getGamesForPlayerCount(10);
      
      expect(games.isNotEmpty, isTrue,
          reason: 'Should have at least one game supporting 10 players');
    });

    test('memory games should have correct properties', () {
      final memoryGames = GameCatalog.getGamesByCategory(CognitiveCategory.memory);
      
      expect(memoryGames.length, equals(3));
      expect(memoryGames.any((g) => g.id == 'memory_match'), isTrue);
      expect(memoryGames.any((g) => g.id == 'sequence_recall'), isTrue);
      expect(memoryGames.any((g) => g.id == 'pattern_memory'), isTrue);
    });

    test('logic games should have correct properties', () {
      final logicGames = GameCatalog.getGamesByCategory(CognitiveCategory.logic);
      
      expect(logicGames.length, equals(3));
      expect(logicGames.any((g) => g.id == 'sudoku_duel'), isTrue);
      expect(logicGames.any((g) => g.id == 'logic_grid'), isTrue);
      expect(logicGames.any((g) => g.id == 'code_breaker'), isTrue);
    });

    test('attention games should have correct properties', () {
      final attentionGames = GameCatalog.getGamesByCategory(CognitiveCategory.attention);
      
      expect(attentionGames.length, equals(3));
      expect(attentionGames.any((g) => g.id == 'spot_difference'), isTrue);
      expect(attentionGames.any((g) => g.id == 'color_rush'), isTrue);
      expect(attentionGames.any((g) => g.id == 'focus_finder'), isTrue);
    });

    test('spatial games should have correct properties', () {
      final spatialGames = GameCatalog.getGamesByCategory(CognitiveCategory.spatial);
      
      expect(spatialGames.length, equals(3));
      expect(spatialGames.any((g) => g.id == 'puzzle_race'), isTrue);
      expect(spatialGames.any((g) => g.id == 'rotation_master'), isTrue);
      expect(spatialGames.any((g) => g.id == 'path_finder'), isTrue);
    });

    test('language games should have correct properties', () {
      final languageGames = GameCatalog.getGamesByCategory(CognitiveCategory.language);
      
      expect(languageGames.length, equals(3));
      expect(languageGames.any((g) => g.id == 'word_builder'), isTrue);
      expect(languageGames.any((g) => g.id == 'anagram_attack'), isTrue);
      expect(languageGames.any((g) => g.id == 'vocabulary_showdown'), isTrue);
    });
  });
}
