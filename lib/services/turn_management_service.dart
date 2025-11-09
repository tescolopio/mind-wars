/**
 * Turn Management Service - Feature 3.3
 * Handles turn-based gameplay with async support
 * Server-side validation and turn history tracking
 */

import '../models/models.dart';
import 'api_service.dart';

class TurnManagementService {
  final ApiService _apiService;
  Game? _currentGame;
  final List<Turn> _turnHistory = [];
  final List<TurnNotification> _notifications = [];

  TurnManagementService(this._apiService);

  /// Get current game
  Game? get currentGame => _currentGame;

  /// Set current game
  void setCurrentGame(Game game) {
    _currentGame = game;
    _turnHistory.clear();
  }

  /// Get turn history
  List<Turn> get turnHistory => List.unmodifiable(_turnHistory);

  /// Get whose turn it is
  String? get currentTurnPlayerId => _currentGame?.currentPlayerId;

  /// Get current turn number
  int get currentTurnNumber => _currentGame?.currentTurn ?? 0;

  /// Check if it's a specific player's turn
  bool isPlayerTurn(String playerId) {
    return _currentGame?.currentPlayerId == playerId;
  }

  /// Submit a turn - Feature 3.3.1
  /// Validates turn data server-side and updates game state
  Future<Turn> submitTurn({
    required String playerId,
    required String playerName,
    required Map<String, dynamic> turnData,
  }) async {
    if (_currentGame == null) {
      throw Exception('No active game');
    }

    if (!isPlayerTurn(playerId)) {
      throw Exception('Not your turn');
    }

    // Create turn object
    final turn = Turn(
      id: 'turn_${DateTime.now().millisecondsSinceEpoch}',
      gameId: _currentGame!.id,
      playerId: playerId,
      playerName: playerName,
      turnNumber: currentTurnNumber + 1,
      data: turnData,
      timestamp: DateTime.now(),
      validated: false,
    );

    try {
      // Submit to server for validation (Feature 3.3.3)
      final response = await _apiService.post(
        '/games/${_currentGame!.id}/turns',
        {
          'turnId': turn.id,
          'playerId': playerId,
          'turnNumber': turn.turnNumber,
          'turnData': turnData,
        },
      );

      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Turn validation failed');
      }

      // Update turn with validated data
      final validatedTurn = Turn(
        id: turn.id,
        gameId: turn.gameId,
        playerId: turn.playerId,
        playerName: turn.playerName,
        turnNumber: turn.turnNumber,
        data: turnData,
        timestamp: turn.timestamp,
        validated: true,
        score: response['score'],
      );

      // Update game state
      _currentGame = Game.fromJson(response['game']);

      // Add to history
      _turnHistory.add(validatedTurn);

      // Create notification for other players (Feature 3.3.4)
      await _notifyTurnComplete(validatedTurn);

      return validatedTurn;
    } catch (e) {
      throw Exception('Failed to submit turn: $e');
    }
  }

  /// Get turn by ID
  Turn? getTurn(String turnId) {
    try {
      return _turnHistory.firstWhere((turn) => turn.id == turnId);
    } catch (e) {
      return null;
    }
  }

  /// Get turns by player
  List<Turn> getTurnsByPlayer(String playerId) {
    return _turnHistory.where((turn) => turn.playerId == playerId).toList();
  }

  /// Get recent turns (last N)
  List<Turn> getRecentTurns([int count = 10]) {
    if (_turnHistory.length <= count) {
      return List.from(_turnHistory.reversed);
    }
    return _turnHistory.sublist(_turnHistory.length - count).reversed.toList();
  }

  /// Load turn history from server
  Future<void> loadTurnHistory() async {
    if (_currentGame == null) {
      throw Exception('No active game');
    }

    try {
      final response = await _apiService.get(
        '/games/${_currentGame!.id}/turns',
      );

      if (response['success'] == true) {
        _turnHistory.clear();
        final turns = (response['turns'] as List)
            .map((t) => Turn.fromJson(t))
            .toList();
        _turnHistory.addAll(turns);
      }
    } catch (e) {
      throw Exception('Failed to load turn history: $e');
    }
  }

  /// Notify other players of turn completion - Feature 3.3.4
  Future<void> _notifyTurnComplete(Turn turn) async {
    try {
      await _apiService.post(
        '/games/${turn.gameId}/notify',
        {
          'type': 'turn_complete',
          'playerId': turn.playerId,
          'playerName': turn.playerName,
          'turnNumber': turn.turnNumber,
        },
      );
    } catch (e) {
      // Notification failure should not break turn submission
      print('Failed to notify players: $e');
    }
  }

  /// Get notifications for a player - Feature 3.3.4
  Future<List<TurnNotification>> getNotifications(String playerId) async {
    try {
      final response = await _apiService.get(
        '/players/$playerId/notifications',
      );

      if (response['success'] == true) {
        final notifications = (response['notifications'] as List)
            .map((n) => TurnNotification.fromJson(n))
            .toList();
        _notifications.clear();
        _notifications.addAll(notifications);
        return notifications;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  /// Mark notification as read - Feature 3.3.4
  Future<void> markNotificationRead(String notificationId) async {
    try {
      await _apiService.post(
        '/notifications/$notificationId/read',
        {},
      );

      // Update local notification
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = TurnNotification(
          id: _notifications[index].id,
          gameId: _notifications[index].gameId,
          gameName: _notifications[index].gameName,
          playerId: _notifications[index].playerId,
          playerName: _notifications[index].playerName,
          message: _notifications[index].message,
          timestamp: _notifications[index].timestamp,
          read: true,
        );
      }
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Get unread notification count
  int get unreadNotificationCount {
    return _notifications.where((n) => !n.read).length;
  }

  /// Validate turn data locally before submission
  bool validateTurnData(Map<String, dynamic> turnData) {
    if (_currentGame == null) return false;

    // Basic validation - can be extended per game type
    if (turnData.isEmpty) return false;

    // Ensure required fields exist
    if (!turnData.containsKey('action')) return false;

    return true;
  }

  /// Skip turn (if allowed by game rules)
  Future<void> skipTurn(String playerId) async {
    if (_currentGame == null) {
      throw Exception('No active game');
    }

    if (!isPlayerTurn(playerId)) {
      throw Exception('Not your turn');
    }

    await submitTurn(
      playerId: playerId,
      playerName: 'Player', // Should be retrieved from player data
      turnData: {
        'action': 'skip',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Get game progress (percentage)
  double getGameProgress() {
    if (_currentGame == null) return 0.0;

    final totalTurns = _currentGame!.state['totalTurns'] as int? ?? 100;
    return (currentTurnNumber / totalTurns).clamp(0.0, 1.0);
  }

  /// Check if game is complete
  bool get isGameComplete => _currentGame?.completed ?? false;

  /// Clear current game and history
  void clearGame() {
    _currentGame = null;
    _turnHistory.clear();
  }

  /// Clear notifications
  void clearNotifications() {
    _notifications.clear();
  }
}
