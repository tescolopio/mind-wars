/**
 * Core type definitions for Mind Wars
 */

/// Player status enum
enum PlayerStatus { active, idle, disconnected }

/// Cognitive category enum
enum CognitiveCategory { memory, logic, attention, spatial, language }

/// Player model
class Player {
  final String id;
  final String username;
  final String? avatar;
  final PlayerStatus status;
  final int score;
  final int streak;
  final List<Badge> badges;
  final DateTime lastActive;

  Player({
    required this.id,
    required this.username,
    this.avatar,
    required this.status,
    required this.score,
    required this.streak,
    required this.badges,
    required this.lastActive,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'avatar': avatar,
        'status': status.toString(),
        'score': score,
        'streak': streak,
        'badges': badges.map((b) => b.toJson()).toList(),
        'lastActive': lastActive.toIso8601String(),
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'],
        username: json['username'],
        avatar: json['avatar'],
        status: PlayerStatus.values.firstWhere(
          (e) => e.toString() == json['status'],
          orElse: () => PlayerStatus.active,
        ),
        score: json['score'] ?? 0,
        streak: json['streak'] ?? 0,
        badges: (json['badges'] as List?)
                ?.map((b) => Badge.fromJson(b))
                .toList() ??
            [],
        lastActive: DateTime.parse(json['lastActive']),
      );
}

/// Badge model
class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final DateTime earnedAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.earnedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'earnedAt': earnedAt.toIso8601String(),
      };

  factory Badge.fromJson(Map<String, dynamic> json) => Badge(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        icon: json['icon'],
        earnedAt: DateTime.parse(json['earnedAt']),
      );
}

/// Game lobby model
class GameLobby {
  final String id;
  final String name;
  final String hostId;
  final List<Player> players;
  final int maxPlayers;
  final Game? currentGame;
  final String status; // 'waiting', 'in-progress', 'completed'
  final DateTime createdAt;

  GameLobby({
    required this.id,
    required this.name,
    required this.hostId,
    required this.players,
    required this.maxPlayers,
    this.currentGame,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'hostId': hostId,
        'players': players.map((p) => p.toJson()).toList(),
        'maxPlayers': maxPlayers,
        'currentGame': currentGame?.toJson(),
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GameLobby.fromJson(Map<String, dynamic> json) => GameLobby(
        id: json['id'],
        name: json['name'],
        hostId: json['hostId'],
        players: (json['players'] as List)
            .map((p) => Player.fromJson(p))
            .toList(),
        maxPlayers: json['maxPlayers'],
        currentGame: json['currentGame'] != null
            ? Game.fromJson(json['currentGame'])
            : null,
        status: json['status'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

/// Game model
class Game {
  final String id;
  final String name;
  final CognitiveCategory category;
  final String description;
  final int minPlayers;
  final int maxPlayers;
  final int currentTurn;
  final String currentPlayerId;
  final Map<String, dynamic> state;
  final bool completed;

  Game({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.minPlayers,
    required this.maxPlayers,
    required this.currentTurn,
    required this.currentPlayerId,
    required this.state,
    required this.completed,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.toString(),
        'description': description,
        'minPlayers': minPlayers,
        'maxPlayers': maxPlayers,
        'currentTurn': currentTurn,
        'currentPlayerId': currentPlayerId,
        'state': state,
        'completed': completed,
      };

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        id: json['id'],
        name: json['name'],
        category: CognitiveCategory.values.firstWhere(
          (e) => e.toString() == json['category'],
        ),
        description: json['description'],
        minPlayers: json['minPlayers'],
        maxPlayers: json['maxPlayers'],
        currentTurn: json['currentTurn'],
        currentPlayerId: json['currentPlayerId'],
        state: json['state'],
        completed: json['completed'],
      );
}

/// Chat message model
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final String? emoji;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.emoji,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'emoji': emoji,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'],
        senderId: json['senderId'],
        senderName: json['senderName'],
        message: json['message'],
        timestamp: DateTime.parse(json['timestamp']),
        emoji: json['emoji'],
      );
}

/// Leaderboard entry model
class LeaderboardEntry {
  final String playerId;
  final String username;
  final int totalScore;
  final int gamesPlayed;
  final int wins;
  final int rank;
  final DateTime weekStartDate;

  LeaderboardEntry({
    required this.playerId,
    required this.username,
    required this.totalScore,
    required this.gamesPlayed,
    required this.wins,
    required this.rank,
    required this.weekStartDate,
  });

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'username': username,
        'totalScore': totalScore,
        'gamesPlayed': gamesPlayed,
        'wins': wins,
        'rank': rank,
        'weekStartDate': weekStartDate.toIso8601String(),
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        playerId: json['playerId'],
        username: json['username'],
        totalScore: json['totalScore'],
        gamesPlayed: json['gamesPlayed'],
        wins: json['wins'],
        rank: json['rank'],
        weekStartDate: DateTime.parse(json['weekStartDate']),
      );
}

/// Offline game data model
class OfflineGameData {
  final String id;
  final String gameType;
  final CognitiveCategory category;
  final Map<String, dynamic> state;
  final int score;
  final bool completed;
  final DateTime timestamp;
  final bool synced;

  OfflineGameData({
    required this.id,
    required this.gameType,
    required this.category,
    required this.state,
    required this.score,
    required this.completed,
    required this.timestamp,
    required this.synced,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'gameType': gameType,
        'category': category.toString(),
        'state': state,
        'score': score,
        'completed': completed,
        'timestamp': timestamp.toIso8601String(),
        'synced': synced,
      };

  factory OfflineGameData.fromJson(Map<String, dynamic> json) =>
      OfflineGameData(
        id: json['id'],
        gameType: json['gameType'],
        category: CognitiveCategory.values.firstWhere(
          (e) => e.toString() == json['category'],
        ),
        state: json['state'],
        score: json['score'],
        completed: json['completed'],
        timestamp: DateTime.parse(json['timestamp']),
        synced: json['synced'],
      );
}

/// User progress model
class UserProgress {
  final String userId;
  final int level;
  final int totalScore;
  final int gamesPlayed;
  final int currentStreak;
  final int longestStreak;
  final List<Badge> badges;
  final DateTime lastPlayedDate;

  UserProgress({
    required this.userId,
    required this.level,
    required this.totalScore,
    required this.gamesPlayed,
    required this.currentStreak,
    required this.longestStreak,
    required this.badges,
    required this.lastPlayedDate,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'level': level,
        'totalScore': totalScore,
        'gamesPlayed': gamesPlayed,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'badges': badges.map((b) => b.toJson()).toList(),
        'lastPlayedDate': lastPlayedDate.toIso8601String(),
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
        userId: json['userId'],
        level: json['level'],
        totalScore: json['totalScore'],
        gamesPlayed: json['gamesPlayed'],
        currentStreak: json['currentStreak'],
        longestStreak: json['longestStreak'],
        badges: (json['badges'] as List)
            .map((b) => Badge.fromJson(b))
            .toList(),
        lastPlayedDate: DateTime.parse(json['lastPlayedDate']),
      );
}

/// Vote to skip model
class VoteToSkip {
  final String gameId;
  final Map<String, bool> votes;
  final int required;

  VoteToSkip({
    required this.gameId,
    required this.votes,
    required this.required,
  });

  Map<String, dynamic> toJson() => {
        'gameId': gameId,
        'votes': votes,
        'required': required,
      };

  factory VoteToSkip.fromJson(Map<String, dynamic> json) => VoteToSkip(
        gameId: json['gameId'],
        votes: Map<String, bool>.from(json['votes']),
        required: json['required'],
      );
}

/// Game vote model - represents a player's vote for a game
class GameVote {
  final String playerId;
  final String gameId;
  final int points;
  final DateTime timestamp;

  GameVote({
    required this.playerId,
    required this.gameId,
    required this.points,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'gameId': gameId,
        'points': points,
        'timestamp': timestamp.toIso8601String(),
      };

  factory GameVote.fromJson(Map<String, dynamic> json) => GameVote(
        playerId: json['playerId'],
        gameId: json['gameId'],
        points: json['points'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

/// Voting session model - manages voting for games across multiple rounds
class VotingSession {
  final String id;
  final String lobbyId;
  final int pointsPerPlayer;
  final int totalRounds;
  final int gamesPerRound;
  final int currentRound;
  final List<String> availableGames;
  final Map<String, Map<String, int>> votes; // playerId -> gameId -> points
  final Map<String, int> remainingPoints; // playerId -> remaining points
  final List<List<String>> selectedGames; // Games selected for each round (rounds -> games)
  final bool completed;
  final DateTime createdAt;

  VotingSession({
    required this.id,
    required this.lobbyId,
    required this.pointsPerPlayer,
    required this.totalRounds,
    required this.gamesPerRound,
    required this.currentRound,
    required this.availableGames,
    required this.votes,
    required this.remainingPoints,
    required this.selectedGames,
    required this.completed,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'lobbyId': lobbyId,
        'pointsPerPlayer': pointsPerPlayer,
        'totalRounds': totalRounds,
        'gamesPerRound': gamesPerRound,
        'currentRound': currentRound,
        'availableGames': availableGames,
        'votes': votes,
        'remainingPoints': remainingPoints,
        'selectedGames': selectedGames,
        'completed': completed,
        'createdAt': createdAt.toIso8601String(),
      };

  factory VotingSession.fromJson(Map<String, dynamic> json) => VotingSession(
        id: json['id'],
        lobbyId: json['lobbyId'],
        pointsPerPlayer: json['pointsPerPlayer'],
        totalRounds: json['totalRounds'],
        gamesPerRound: json['gamesPerRound'],
        currentRound: json['currentRound'],
        availableGames: List<String>.from(json['availableGames']),
        votes: (json['votes'] as Map<String, dynamic>).map(
          (playerId, playerVotes) => MapEntry(
            playerId,
            Map<String, int>.from(playerVotes as Map),
          ),
        ),
        remainingPoints: Map<String, int>.from(json['remainingPoints']),
        selectedGames: (json['selectedGames'] as List)
            .map((round) => List<String>.from(round))
            .toList(),
        completed: json['completed'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  /// Calculate total points for each game
  Map<String, int> calculateGameTotals() {
    final totals = <String, int>{};
    for (var playerVotes in votes.values) {
      for (var entry in playerVotes.entries) {
        totals[entry.key] = (totals[entry.key] ?? 0) + entry.value;
      }
    }
    return totals;
  }

  /// Get the top N games with most points for the round
  /// Returns list of game IDs sorted by points (highest first)
  List<String> getTopGames(int count) {
    final totals = calculateGameTotals();
    if (totals.isEmpty) return [];
    
    // Sort games by points (descending)
    final sortedEntries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Return top N games
    return sortedEntries
        .take(count)
        .map((e) => e.key)
        .toList();
  }

  /// Get the winning game (game with most points) - for backward compatibility
  String? getWinningGame() {
    final winners = getTopGames(1);
    return winners.isEmpty ? null : winners.first;
  }

  /// Check if all players have used their points
  bool get allPlayersVoted {
    return remainingPoints.values.every((points) => points == 0);
  }

  /// Check if voting is open for current round
  bool get isVotingOpen {
    return !completed && currentRound <= totalRounds;
  }

  /// Get total number of games in the match
  int get totalGames => totalRounds * gamesPerRound;

  /// Get all selected games flattened
  List<String> get allSelectedGames {
    return selectedGames.expand((round) => round).toList();
  }
}
