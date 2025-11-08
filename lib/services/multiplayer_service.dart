/**
 * Multiplayer Service - Handles async multiplayer functionality
 * Supports 2-10 players per lobby with turn-based gameplay
 */

import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/models.dart';

class MultiplayerService {
  IO.Socket? _socket;
  GameLobby? _currentLobby;
  final Map<String, List<Function>> _listeners = {};

  /// Connect to the multiplayer server
  Future<void> connect(String serverUrl, String playerId) async {
    _socket = IO.io(serverUrl, <String, dynamic>{
      'auth': {'playerId': playerId},
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });

    _socket!.onConnect((_) {
      print('Connected to multiplayer server');
      _setupEventListeners();
    });

    _socket!.onConnectError((error) {
      print('Connection error: $error');
    });

    _socket!.connect();

    // Wait for connection
    await Future.delayed(Duration(seconds: 1));
  }

  /// Disconnect from the multiplayer server
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _currentLobby = null;
  }

  /// Create a new game lobby with enhanced options
  Future<GameLobby> createLobby({
    required String name,
    required int maxPlayers,
    bool isPrivate = true,
    int numberOfRounds = 3,
    int votingPointsPerPlayer = 10,
  }) async {
    if (_socket == null) {
      throw Exception('Not connected to server');
    }

    if (maxPlayers < 2 || maxPlayers > 10) {
      throw Exception('Max players must be between 2 and 10');
    }

    if (numberOfRounds < 1 || numberOfRounds > 10) {
      throw Exception('Number of rounds must be between 1 and 10');
    }

    if (votingPointsPerPlayer < 1 || votingPointsPerPlayer > 20) {
      throw Exception('Voting points must be between 1 and 20');
    }

    final completer = Completer<GameLobby>();

    _socket!.emitWithAck('create-lobby', {
      'name': name,
      'maxPlayers': maxPlayers,
      'isPrivate': isPrivate,
      'numberOfRounds': numberOfRounds,
      'votingPointsPerPlayer': votingPointsPerPlayer,
    }, ack: (data) {
      if (data['success']) {
        final lobby = GameLobby.fromJson(data['lobby']);
        _currentLobby = lobby;
        completer.complete(lobby);
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Join an existing lobby by ID
  Future<GameLobby> joinLobby(String lobbyId) async {
    if (_socket == null) {
      throw Exception('Not connected to server');
    }

    final completer = Completer<GameLobby>();

    _socket!.emitWithAck('join-lobby', {
      'lobbyId': lobbyId,
    }, ack: (data) {
      if (data['success']) {
        final lobby = GameLobby.fromJson(data['lobby']);
        _currentLobby = lobby;
        completer.complete(lobby);
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }
  
  /// Join a lobby by code (for private lobbies)
  Future<GameLobby> joinLobbyByCode(String lobbyCode) async {
    if (_socket == null) {
      throw Exception('Not connected to server');
    }

    final completer = Completer<GameLobby>();

    _socket!.emitWithAck('join-lobby-by-code', {
      'lobbyCode': lobbyCode.toUpperCase(),
    }, ack: (data) {
      if (data['success']) {
        final lobby = GameLobby.fromJson(data['lobby']);
        _currentLobby = lobby;
        completer.complete(lobby);
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Leave current lobby
  Future<void> leaveLobby() async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    final completer = Completer<void>();

    _socket!.emitWithAck('leave-lobby', {
      'lobbyId': _currentLobby!.id,
    }, ack: (data) {
      if (data['success']) {
        _currentLobby = null;
        completer.complete();
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Start a game in the current lobby
  Future<Game> startGame(String gameId) async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    final completer = Completer<Game>();

    _socket!.emitWithAck('start-game', {
      'lobbyId': _currentLobby!.id,
      'gameId': gameId,
    }, ack: (data) {
      if (data['success']) {
        completer.complete(Game.fromJson(data['game']));
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Make a turn in the current game
  Future<void> makeTurn(Map<String, dynamic> turnData) async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a game');
    }

    final completer = Completer<void>();

    _socket!.emitWithAck('make-turn', {
      'lobbyId': _currentLobby!.id,
      'turnData': turnData,
    }, ack: (data) {
      if (data['success']) {
        completer.complete();
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Send a chat message
  void sendMessage(String message) {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    _socket!.emit('chat-message', {
      'lobbyId': _currentLobby!.id,
      'message': message,
    });
  }

  /// Send an emoji reaction
  void sendReaction(String messageId, String emoji) {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    _socket!.emit('emoji-reaction', {
      'lobbyId': _currentLobby!.id,
      'messageId': messageId,
      'emoji': emoji,
    });
  }

  /// Vote to skip current turn/game
  Future<VoteToSkip> voteToSkip() async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a game');
    }

    final completer = Completer<VoteToSkip>();

    _socket!.emitWithAck('vote-skip', {
      'lobbyId': _currentLobby!.id,
    }, ack: (data) {
      if (data['success']) {
        completer.complete(VoteToSkip.fromJson(data['voteStatus']));
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Start a voting session for game selection
  Future<VotingSession> startVotingSession({
    required int pointsPerPlayer,
    required int totalRounds,
    required int gamesPerRound,
    List<String>? availableGames,
  }) async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    final completer = Completer<VotingSession>();

    _socket!.emitWithAck('start-voting', {
      'lobbyId': _currentLobby!.id,
      'pointsPerPlayer': pointsPerPlayer,
      'totalRounds': totalRounds,
      'gamesPerRound': gamesPerRound,
      'availableGames': availableGames,
    }, ack: (data) {
      if (data['success']) {
        completer.complete(VotingSession.fromJson(data['votingSession']));
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Cast a vote for a game
  Future<void> voteForGame({
    required String gameId,
    required int points,
  }) async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    final completer = Completer<void>();

    _socket!.emitWithAck('vote-game', {
      'lobbyId': _currentLobby!.id,
      'gameId': gameId,
      'points': points,
    }, ack: (data) {
      if (data['success']) {
        completer.complete();
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Remove vote from a game
  Future<void> removeGameVote({
    required String gameId,
    int? points,
  }) async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    final completer = Completer<void>();

    _socket!.emitWithAck('remove-vote', {
      'lobbyId': _currentLobby!.id,
      'gameId': gameId,
      'points': points,
    }, ack: (data) {
      if (data['success']) {
        completer.complete();
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// End voting for current round
  Future<List<String>> endVotingRound() async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    final completer = Completer<List<String>>();

    _socket!.emitWithAck('end-voting', {
      'lobbyId': _currentLobby!.id,
    }, ack: (data) {
      if (data['success']) {
        completer.complete(List<String>.from(data['selectedGames']));
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Get list of available lobbies
  Future<List<GameLobby>> getAvailableLobbies({
    String status = 'waiting',
    bool? isPrivate,
  }) async {
    if (_socket == null) {
      throw Exception('Not connected to server');
    }

    final completer = Completer<List<GameLobby>>();

    _socket!.emitWithAck('list-lobbies', {
      'status': status,
      'isPrivate': isPrivate,
    }, ack: (data) {
      if (data['success']) {
        final lobbies = (data['lobbies'] as List)
            .map((l) => GameLobby.fromJson(l))
            .toList();
        completer.complete(lobbies);
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }
  
  /// Kick a player from the lobby (host only)
  Future<void> kickPlayer(String playerId) async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    final completer = Completer<void>();

    _socket!.emitWithAck('kick-player', {
      'lobbyId': _currentLobby!.id,
      'playerId': playerId,
    }, ack: (data) {
      if (data['success']) {
        completer.complete();
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }
  
  /// Transfer host role to another player
  Future<void> transferHost(String newHostId) async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    final completer = Completer<void>();

    _socket!.emitWithAck('transfer-host', {
      'lobbyId': _currentLobby!.id,
      'newHostId': newHostId,
    }, ack: (data) {
      if (data['success']) {
        completer.complete();
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }
  
  /// Close the lobby (host only)
  Future<void> closeLobby() async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    final completer = Completer<void>();

    _socket!.emitWithAck('close-lobby', {
      'lobbyId': _currentLobby!.id,
    }, ack: (data) {
      if (data['success']) {
        _currentLobby = null;
        completer.complete();
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }
  
  /// Update lobby settings (host only)
  Future<GameLobby> updateLobbySettings({
    String? name,
    int? maxPlayers,
    bool? isPrivate,
    int? numberOfRounds,
    int? votingPointsPerPlayer,
  }) async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    final completer = Completer<GameLobby>();
    
    final settings = <String, dynamic>{
      'lobbyId': _currentLobby!.id,
    };
    
    if (name != null) settings['name'] = name;
    if (maxPlayers != null) settings['maxPlayers'] = maxPlayers;
    if (isPrivate != null) settings['isPrivate'] = isPrivate;
    if (numberOfRounds != null) settings['numberOfRounds'] = numberOfRounds;
    if (votingPointsPerPlayer != null) settings['votingPointsPerPlayer'] = votingPointsPerPlayer;

    _socket!.emitWithAck('update-lobby-settings', settings, ack: (data) {
      if (data['success']) {
        final lobby = GameLobby.fromJson(data['lobby']);
        _currentLobby = lobby;
        completer.complete(lobby);
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Subscribe to events
  void on(String event, Function callback) {
    if (!_listeners.containsKey(event)) {
      _listeners[event] = [];
    }
    _listeners[event]!.add(callback);
  }

  /// Unsubscribe from events
  void off(String event, Function callback) {
    if (_listeners.containsKey(event)) {
      _listeners[event]!.remove(callback);
    }
  }

  /// Setup internal event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    _socket!.on('player-joined', (data) {
      _emit('player-joined', data);
    });

    _socket!.on('player-left', (data) {
      _emit('player-left', data);
    });
    
    _socket!.on('player-kicked', (data) {
      _emit('player-kicked', data);
    });
    
    _socket!.on('host-transferred', (data) {
      _emit('host-transferred', data);
    });
    
    _socket!.on('lobby-closed', (data) {
      _emit('lobby-closed', data);
      _currentLobby = null;
    });
    
    _socket!.on('lobby-updated', (data) {
      _emit('lobby-updated', data);
    });
    
    _socket!.on('player-status-changed', (data) {
      _emit('player-status-changed', data);
    });
    
    _socket!.on('player-typing', (data) {
      _emit('player-typing', data);
    });

    _socket!.on('game-started', (data) {
      _emit('game-started', data);
    });

    _socket!.on('turn-made', (data) {
      _emit('turn-made', data);
    });

    _socket!.on('game-ended', (data) {
      _emit('game-ended', data);
    });

    _socket!.on('chat-message', (data) {
      _emit('chat-message', data);
    });

    _socket!.on('emoji-reaction', (data) {
      _emit('emoji-reaction', data);
    });

    _socket!.on('vote-skip-update', (data) {
      _emit('vote-skip-update', data);
    });

    _socket!.on('voting-started', (data) {
      _emit('voting-started', data);
    });

    _socket!.on('vote-cast', (data) {
      _emit('vote-cast', data);
    });

    _socket!.on('voting-update', (data) {
      _emit('voting-update', data);
    });

    _socket!.on('voting-ended', (data) {
      _emit('voting-ended', data);
    });

    _socket!.on('disconnect', (_) {
      _emit('disconnected', {});
    });

    _socket!.on('reconnect', (_) {
      _emit('reconnected', {});
    });
  }
  
  /// Update player status (for presence tracking)
  void updatePlayerStatus(PlayerStatus status) {
    if (_socket == null || _currentLobby == null) {
      return;
    }

    _socket!.emit('update-player-status', {
      'lobbyId': _currentLobby!.id,
      'status': status.toString(),
    });
  }
  
  /// Send typing indicator
  void sendTypingIndicator(bool isTyping) {
    if (_socket == null || _currentLobby == null) {
      return;
    }

    _socket!.emit('typing-indicator', {
      'lobbyId': _currentLobby!.id,
      'isTyping': isTyping,
    });
  }
  
  /// Start heartbeat for presence tracking
  void startHeartbeat() {
    if (_socket == null) return;
    
    // Send heartbeat every 30 seconds to maintain presence
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 30));
      if (_socket?.connected == true && _currentLobby != null) {
        _socket!.emit('heartbeat', {
          'lobbyId': _currentLobby!.id,
        });
        return true;
      }
      return false;
    });
  }

  /// Emit events to listeners
  void _emit(String event, dynamic data) {
    if (_listeners.containsKey(event)) {
      for (var callback in _listeners[event]!) {
        callback(data);
      }
    }
  }

  /// Get current lobby
  GameLobby? get currentLobby => _currentLobby;

  /// Check if connected
  bool get isConnected => _socket?.connected ?? false;
}
