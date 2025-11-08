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

  /// Create a new game lobby
  Future<GameLobby> createLobby(String name, int maxPlayers) async {
    if (_socket == null) {
      throw Exception('Not connected to server');
    }

    if (maxPlayers < 2 || maxPlayers > 10) {
      throw Exception('Max players must be between 2 and 10');
    }

    final completer = Completer<GameLobby>();

    _socket!.emitWithAck('create-lobby', {
      'name': name,
      'maxPlayers': maxPlayers,
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

  /// Join an existing lobby
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

  /// Get list of available lobbies
  Future<List<GameLobby>> getAvailableLobbies() async {
    if (_socket == null) {
      throw Exception('Not connected to server');
    }

    final completer = Completer<List<GameLobby>>();

    _socket!.emitWithAck('list-lobbies', {}, ack: (data) {
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

    _socket!.on('disconnect', (_) {
      _emit('disconnected', {});
    });

    _socket!.on('reconnect', (_) {
      _emit('reconnected', {});
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
