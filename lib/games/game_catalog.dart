/**
 * Game Catalog - 12+ games across 5 cognitive categories
 * Mobile-First: Designed for 5" touch screens
 */

import '../models/models.dart';

class GameTemplate {
  final String id;
  final String name;
  final CognitiveCategory category;
  final String description;
  final int minPlayers;
  final int maxPlayers;
  final String icon;
  final String rules;

  GameTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.minPlayers,
    required this.maxPlayers,
    required this.icon,
    required this.rules,
  });
}

class GameCatalog {
  static final List<GameTemplate> _games = [
    // MEMORY GAMES (3)
    GameTemplate(
      id: 'memory_match',
      name: 'Memory Match',
      category: CognitiveCategory.memory,
      description: 'Match pairs of cards by remembering their positions',
      minPlayers: 2,
      maxPlayers: 4,
      icon: '🃏',
      rules: 'Players take turns flipping two cards. Match pairs to score points.',
    ),
    GameTemplate(
      id: 'sequence_recall',
      name: 'Sequence Recall',
      category: CognitiveCategory.memory,
      description: 'Remember and reproduce increasingly long sequences',
      minPlayers: 2,
      maxPlayers: 6,
      icon: '🔢',
      rules: 'Watch the sequence, then reproduce it. Sequences get longer each round.',
    ),
    GameTemplate(
      id: 'pattern_memory',
      name: 'Pattern Memory',
      category: CognitiveCategory.memory,
      description: 'Remember complex visual patterns and recreate them',
      minPlayers: 2,
      maxPlayers: 8,
      icon: '🎨',
      rules: 'Study the pattern briefly, then recreate it from memory.',
    ),

    // LOGIC GAMES (3)
    GameTemplate(
      id: 'sudoku_duel',
      name: 'Sudoku Duel',
      category: CognitiveCategory.logic,
      description: 'Competitive Sudoku solving with time limits',
      minPlayers: 2,
      maxPlayers: 4,
      icon: '🔢',
      rules: 'Complete the Sudoku puzzle faster than your opponents.',
    ),
    GameTemplate(
      id: 'logic_grid',
      name: 'Logic Grid',
      category: CognitiveCategory.logic,
      description: 'Solve logic puzzles using deduction',
      minPlayers: 2,
      maxPlayers: 6,
      icon: '🧮',
      rules: 'Use clues to deduce the correct arrangement of items.',
    ),
    GameTemplate(
      id: 'code_breaker',
      name: 'Code Breaker',
      category: CognitiveCategory.logic,
      description: 'Deduce secret codes using logical reasoning',
      minPlayers: 2,
      maxPlayers: 4,
      icon: '🔐',
      rules: 'Guess the secret code. Get feedback on each guess.',
    ),

    // ATTENTION GAMES (3)
    GameTemplate(
      id: 'spot_difference',
      name: 'Spot the Difference',
      category: CognitiveCategory.attention,
      description: 'Find differences between similar images quickly',
      minPlayers: 2,
      maxPlayers: 8,
      icon: '👀',
      rules: 'Find all differences between two images. Fastest wins.',
    ),
    GameTemplate(
      id: 'color_rush',
      name: 'Color Rush',
      category: CognitiveCategory.attention,
      description: 'Match colors under time pressure',
      minPlayers: 2,
      maxPlayers: 10,
      icon: '🌈',
      rules: 'Quickly identify and match the colors shown.',
    ),
    GameTemplate(
      id: 'focus_finder',
      name: 'Focus Finder',
      category: CognitiveCategory.attention,
      description: 'Locate specific items in cluttered scenes',
      minPlayers: 2,
      maxPlayers: 6,
      icon: '🔍',
      rules: 'Find the target items as quickly as possible.',
    ),

    // SPATIAL GAMES (3)
    GameTemplate(
      id: 'puzzle_race',
      name: 'Puzzle Race',
      category: CognitiveCategory.spatial,
      description: 'Complete jigsaw puzzles against the clock',
      minPlayers: 2,
      maxPlayers: 4,
      icon: '🧩',
      rules: 'Assemble the puzzle pieces. Fastest completion wins.',
    ),
    GameTemplate(
      id: 'rotation_master',
      name: 'Rotation Master',
      category: CognitiveCategory.spatial,
      description: 'Identify rotated shapes and objects',
      minPlayers: 2,
      maxPlayers: 8,
      icon: '🔄',
      rules: 'Match objects with their rotated counterparts.',
    ),
    GameTemplate(
      id: 'path_finder',
      name: 'Path Finder',
      category: CognitiveCategory.spatial,
      description: 'Navigate mazes and find optimal paths',
      minPlayers: 2,
      maxPlayers: 6,
      icon: '🗺️',
      rules: 'Find the shortest path through the maze.',
    ),

    // LANGUAGE GAMES (3)
    GameTemplate(
      id: 'word_builder',
      name: 'Word Builder',
      category: CognitiveCategory.language,
      description: 'Create words from letter tiles competitively',
      minPlayers: 2,
      maxPlayers: 6,
      icon: '📝',
      rules: 'Form the highest-scoring words from available letters.',
    ),
    GameTemplate(
      id: 'anagram_attack',
      name: 'Anagram Attack',
      category: CognitiveCategory.language,
      description: 'Solve anagrams faster than opponents',
      minPlayers: 2,
      maxPlayers: 8,
      icon: '🔤',
      rules: 'Unscramble words as quickly as possible.',
    ),
    GameTemplate(
      id: 'vocabulary_showdown',
      name: 'Vocabulary Showdown',
      category: CognitiveCategory.language,
      description: 'Test vocabulary knowledge in rapid-fire rounds',
      minPlayers: 2,
      maxPlayers: 10,
      icon: '📚',
      rules: 'Answer vocabulary questions. Most correct answers wins.',
    ),
  ];

  /// Get all available games
  static List<GameTemplate> getAllGames() => List.unmodifiable(_games);

  /// Get games by category
  static List<GameTemplate> getGamesByCategory(CognitiveCategory category) {
    return _games.where((game) => game.category == category).toList();
  }

  /// Get game by ID
  static GameTemplate? getGameById(String id) {
    try {
      return _games.firstWhere((game) => game.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get games suitable for player count
  static List<GameTemplate> getGamesForPlayerCount(int playerCount) {
    return _games
        .where((game) =>
            playerCount >= game.minPlayers && playerCount <= game.maxPlayers)
        .toList();
  }

  /// Get random game for player count
  static GameTemplate? getRandomGame(int playerCount) {
    final suitable = getGamesForPlayerCount(playerCount);
    if (suitable.isEmpty) return null;
    
    final random = DateTime.now().millisecondsSinceEpoch % suitable.length;
    return suitable[random];
  }

  /// Get all categories
  static List<CognitiveCategory> getAllCategories() {
    return CognitiveCategory.values;
  }

  /// Get category info
  static Map<String, String> getCategoryInfo(CognitiveCategory category) {
    const categoryInfo = {
      'memory': {
        'name': 'Memory',
        'icon': '🧠',
        'description': 'Test your recall and recognition abilities',
      },
      'logic': {
        'name': 'Logic',
        'icon': '🧩',
        'description': 'Challenge your reasoning and problem-solving skills',
      },
      'attention': {
        'name': 'Attention',
        'icon': '👁️',
        'description': 'Sharpen your focus and visual processing',
      },
      'spatial': {
        'name': 'Spatial',
        'icon': '🗺️',
        'description': 'Develop your spatial awareness and visualization',
      },
      'language': {
        'name': 'Language',
        'icon': '📚',
        'description': 'Enhance your verbal and linguistic abilities',
      },
    };
    
    return Map<String, String>.from(
      categoryInfo[category.toString().split('.').last]!,
    );
  }

  /// Create game instance from template
  static Game? createGameInstance(
    String templateId,
    String lobbyId,
    List<String> players,
  ) {
    final template = getGameById(templateId);
    if (template == null) return null;

    return Game(
      id: 'game_${DateTime.now().millisecondsSinceEpoch}_${_generateId()}',
      name: template.name,
      category: template.category,
      description: template.description,
      minPlayers: template.minPlayers,
      maxPlayers: template.maxPlayers,
      currentTurn: 0,
      currentPlayerId: players.first,
      state: _initializeGameState(template.id, players),
      completed: false,
    );
  }

  /// Initialize game-specific state
  static Map<String, dynamic> _initializeGameState(
    String gameId,
    List<String> players,
  ) {
    final scores = <String, int>{};
    for (var player in players) {
      scores[player] = 0;
    }

    return {
      'gameId': gameId,
      'players': players,
      'scores': scores,
      'startTime': DateTime.now().millisecondsSinceEpoch,
      'moves': [],
    };
  }

  /// Generate random ID
  static String _generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var id = '';
    var num = random;
    
    for (var i = 0; i < 9; i++) {
      id += chars[num % chars.length];
      num = num ~/ chars.length;
    }
    
    return id;
  }
}
