/**
 * Voting Service - Handles game voting functionality
 * Allows players to vote on which games will be played during rounds
 */

import '../models/models.dart';
import '../games/game_catalog.dart';

class VotingService {
  VotingSession? _currentSession;

  /// Create a new voting session for a lobby
  /// [pointsPerPlayer] - Number of voting points each player receives
  /// [totalRounds] - Number of rounds to play in the match
  /// [gamesPerRound] - Number of games to select per round
  /// [playerIds] - List of player IDs participating
  /// [availableGames] - Optional list of game IDs to vote on (defaults to all games suitable for player count)
  VotingSession createVotingSession({
    required String lobbyId,
    required int pointsPerPlayer,
    required int totalRounds,
    required int gamesPerRound,
    required List<String> playerIds,
    List<String>? availableGames,
  }) {
    if (pointsPerPlayer <= 0) {
      throw Exception('Points per player must be greater than 0');
    }

    if (totalRounds <= 0) {
      throw Exception('Total rounds must be greater than 0');
    }

    if (gamesPerRound <= 0) {
      throw Exception('Games per round must be greater than 0');
    }

    if (playerIds.isEmpty) {
      throw Exception('At least one player is required');
    }

    // If no games specified, use all games suitable for the player count
    final games = availableGames ??
        GameCatalog.getGamesForPlayerCount(playerIds.length)
            .map((g) => g.id)
            .toList();

    if (games.isEmpty) {
      throw Exception('No games available for this player count');
    }

    // Ensure at least 3 games are available for meaningful voting
    if (games.length < 3) {
      throw Exception(
          'At least 3 games are required for voting. Only ${games.length} available.');
    }

    // Ensure enough games are available for the voting configuration
    final totalGamesNeeded = totalRounds * gamesPerRound;
    if (games.length < gamesPerRound) {
      throw Exception(
          'Not enough games available. Need at least $gamesPerRound games per round, but only ${games.length} available.');
    }

    // Initialize remaining points for each player
    final remainingPoints = <String, int>{};
    for (var playerId in playerIds) {
      remainingPoints[playerId] = pointsPerPlayer;
    }

    _currentSession = VotingSession(
      id: 'voting_${DateTime.now().millisecondsSinceEpoch}',
      lobbyId: lobbyId,
      pointsPerPlayer: pointsPerPlayer,
      totalRounds: totalRounds,
      gamesPerRound: gamesPerRound,
      currentRound: 1,
      availableGames: games,
      votes: {},
      remainingPoints: remainingPoints,
      selectedGames: [],
      completed: false,
      createdAt: DateTime.now(),
    );

    return _currentSession!;
  }

  /// Cast a vote for a game
  /// [playerId] - ID of the player voting
  /// [gameId] - ID of the game to vote for
  /// [points] - Number of points to allocate to this game
  GameVote castVote({
    required String playerId,
    required String gameId,
    required int points,
  }) {
    if (_currentSession == null) {
      throw Exception('No active voting session');
    }

    if (!_currentSession!.isVotingOpen) {
      throw Exception('Voting is closed');
    }

    if (points <= 0) {
      throw Exception('Points must be greater than 0');
    }

    if (!_currentSession!.availableGames.contains(gameId)) {
      throw Exception('Game not available for voting');
    }

    final remainingPoints = _currentSession!.remainingPoints[playerId];
    if (remainingPoints == null) {
      throw Exception('Player not in voting session');
    }

    if (points > remainingPoints) {
      throw Exception(
          'Not enough points. Available: $remainingPoints, Requested: $points');
    }

    // Update votes
    if (!_currentSession!.votes.containsKey(playerId)) {
      _currentSession!.votes[playerId] = {};
    }

    final currentVote = _currentSession!.votes[playerId]![gameId] ?? 0;
    _currentSession!.votes[playerId]![gameId] = currentVote + points;

    // Update remaining points
    _currentSession!.remainingPoints[playerId] = remainingPoints - points;

    final vote = GameVote(
      playerId: playerId,
      gameId: gameId,
      points: points,
      timestamp: DateTime.now(),
    );

    return vote;
  }

  /// Remove votes from a game
  /// [playerId] - ID of the player
  /// [gameId] - ID of the game to remove votes from
  /// [points] - Number of points to remove (if null, removes all points from that game)
  void removeVote({
    required String playerId,
    required String gameId,
    int? points,
  }) {
    if (_currentSession == null) {
      throw Exception('No active voting session');
    }

    if (!_currentSession!.isVotingOpen) {
      throw Exception('Voting is closed');
    }

    if (!_currentSession!.votes.containsKey(playerId) ||
        !_currentSession!.votes[playerId]!.containsKey(gameId)) {
      throw Exception('No votes to remove for this game');
    }

    final currentVote = _currentSession!.votes[playerId]![gameId]!;
    final pointsToRemove = points ?? currentVote;

    if (pointsToRemove > currentVote) {
      throw Exception('Cannot remove more points than voted');
    }

    // Update votes
    _currentSession!.votes[playerId]![gameId] = currentVote - pointsToRemove;
    if (_currentSession!.votes[playerId]![gameId] == 0) {
      _currentSession!.votes[playerId]!.remove(gameId);
    }

    // Return points to player
    _currentSession!.remainingPoints[playerId] =
        _currentSession!.remainingPoints[playerId]! + pointsToRemove;
  }

  /// End voting for the current round and select the winning games
  /// Returns the list of selected game IDs for this round
  List<String> endVotingRound() {
    if (_currentSession == null) {
      throw Exception('No active voting session');
    }

    if (!_currentSession!.isVotingOpen) {
      throw Exception('Voting is already closed');
    }

    // Get top N games based on gamesPerRound
    final selectedGamesForRound = _currentSession!.getTopGames(
      _currentSession!.gamesPerRound,
    );
    
    if (selectedGamesForRound.isEmpty) {
      throw Exception('No votes cast');
    }

    if (selectedGamesForRound.length < _currentSession!.gamesPerRound) {
      throw Exception(
          'Not enough games voted on. Need ${_currentSession!.gamesPerRound} games, but only ${selectedGamesForRound.length} have votes.');
    }

    // Add selected games to the round
    _currentSession!.selectedGames.add(selectedGamesForRound);

    // Check if all rounds are complete
    if (_currentSession!.currentRound >= _currentSession!.totalRounds) {
      _currentSession = VotingSession(
        id: _currentSession!.id,
        lobbyId: _currentSession!.lobbyId,
        pointsPerPlayer: _currentSession!.pointsPerPlayer,
        totalRounds: _currentSession!.totalRounds,
        gamesPerRound: _currentSession!.gamesPerRound,
        currentRound: _currentSession!.currentRound,
        availableGames: _currentSession!.availableGames,
        votes: _currentSession!.votes,
        remainingPoints: _currentSession!.remainingPoints,
        selectedGames: _currentSession!.selectedGames,
        completed: true,
        createdAt: _currentSession!.createdAt,
      );
    } else {
      // Move to next round and reset votes/points
      final newRemainingPoints = <String, int>{};
      for (var playerId in _currentSession!.remainingPoints.keys) {
        newRemainingPoints[playerId] = _currentSession!.pointsPerPlayer;
      }

      _currentSession = VotingSession(
        id: _currentSession!.id,
        lobbyId: _currentSession!.lobbyId,
        pointsPerPlayer: _currentSession!.pointsPerPlayer,
        totalRounds: _currentSession!.totalRounds,
        gamesPerRound: _currentSession!.gamesPerRound,
        currentRound: _currentSession!.currentRound + 1,
        availableGames: _currentSession!.availableGames,
        votes: {},
        remainingPoints: newRemainingPoints,
        selectedGames: _currentSession!.selectedGames,
        completed: false,
        createdAt: _currentSession!.createdAt,
      );
    }

    return selectedGamesForRound;
  }

  /// Get the current voting session
  VotingSession? get currentSession => _currentSession;

  /// Get voting results for the current round
  Map<String, int> getCurrentResults() {
    if (_currentSession == null) {
      throw Exception('No active voting session');
    }
    return _currentSession!.calculateGameTotals();
  }

  /// Get remaining points for a player
  int getRemainingPoints(String playerId) {
    if (_currentSession == null) {
      throw Exception('No active voting session');
    }
    return _currentSession!.remainingPoints[playerId] ?? 0;
  }

  /// Get player's votes for current round
  Map<String, int> getPlayerVotes(String playerId) {
    if (_currentSession == null) {
      throw Exception('No active voting session');
    }
    return _currentSession!.votes[playerId] ?? {};
  }

  /// Check if all players have voted
  /// Check if all players have voted
  bool get allPlayersVoted {
    if (_currentSession == null) return false;
    return _currentSession!.allPlayersVoted;
  }

  /// Get all selected games from completed and current rounds (flattened)
  List<String> get selectedGames {
    if (_currentSession == null) return [];
    return _currentSession!.allSelectedGames;
  }

  /// Get selected games by round
  List<List<String>> get selectedGamesByRound {
    if (_currentSession == null) return [];
    return _currentSession!.selectedGames;
  }

  /// Clear the current voting session
  void clearSession() {
    _currentSession = null;
  }
}
