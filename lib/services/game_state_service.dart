/**
 * Game State Management Service - Feature 3.5
 * Handles game state persistence and synchronization with SQLite
 */

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';
import 'api_service.dart';

class GameStateService {
  final ApiService _apiService;
  Database? _database;
  final Map<String, GameStateSnapshot> _stateCache = {};

  GameStateService(this._apiService);

  /// Initialize SQLite database - Feature 3.5.2
  Future<void> initialize() async {
    if (_database != null) return;

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'mind_wars.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create game states table
        await db.execute('''
          CREATE TABLE game_states (
            id TEXT PRIMARY KEY,
            game_id TEXT NOT NULL,
            lobby_id TEXT NOT NULL,
            state TEXT NOT NULL,
            version INTEGER NOT NULL,
            timestamp TEXT NOT NULL,
            synced INTEGER NOT NULL
          )
        ''');

        // Create index for faster lookups
        await db.execute('''
          CREATE INDEX idx_game_states_game_id ON game_states(game_id)
        ''');
        
        await db.execute('''
          CREATE INDEX idx_game_states_lobby_id ON game_states(lobby_id)
        ''');
      },
    );
  }

  /// Save game state locally - Feature 3.5.1
  Future<void> saveState(GameStateSnapshot snapshot) async {
    await initialize();

    // Save to cache
    _stateCache[snapshot.id] = snapshot;

    // Save to SQLite
    await _database!.insert(
      'game_states',
      {
        'id': snapshot.id,
        'game_id': snapshot.gameId,
        'lobby_id': snapshot.lobbyId,
        'state': jsonEncode(snapshot.state),
        'version': snapshot.version,
        'timestamp': snapshot.timestamp.toIso8601String(),
        'synced': snapshot.synced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Load game state from local storage
  Future<GameStateSnapshot?> loadState(String gameId) async {
    await initialize();

    // Check cache first
    final cached = _stateCache.values.where((s) => s.gameId == gameId).toList();
    if (cached.isNotEmpty) {
      // Return latest version
      cached.sort((a, b) => b.version.compareTo(a.version));
      return cached.first;
    }

    // Query from SQLite
    final results = await _database!.query(
      'game_states',
      where: 'game_id = ?',
      whereArgs: [gameId],
      orderBy: 'version DESC',
      limit: 1,
    );

    if (results.isEmpty) return null;

    final row = results.first;
    final snapshot = GameStateSnapshot(
      id: row['id'] as String,
      gameId: row['game_id'] as String,
      lobbyId: row['lobby_id'] as String,
      state: jsonDecode(row['state'] as String),
      version: row['version'] as int,
      timestamp: DateTime.parse(row['timestamp'] as String),
      synced: (row['synced'] as int) == 1,
    );

    // Cache it
    _stateCache[snapshot.id] = snapshot;

    return snapshot;
  }

  /// Get all states for a lobby
  Future<List<GameStateSnapshot>> getStatesForLobby(String lobbyId) async {
    await initialize();

    final results = await _database!.query(
      'game_states',
      where: 'lobby_id = ?',
      whereArgs: [lobbyId],
      orderBy: 'timestamp DESC',
    );

    return results.map((row) {
      return GameStateSnapshot(
        id: row['id'] as String,
        gameId: row['game_id'] as String,
        lobbyId: row['lobby_id'] as String,
        state: jsonDecode(row['state'] as String),
        version: row['version'] as int,
        timestamp: DateTime.parse(row['timestamp'] as String),
        synced: (row['synced'] as int) == 1,
      );
    }).toList();
  }

  /// Synchronize state with server - Feature 3.5.3
  Future<void> syncState(String gameId) async {
    final localState = await loadState(gameId);
    if (localState == null) return;

    try {
      // Send local state to server
      final response = await _apiService.post(
        '/games/$gameId/state/sync',
        {
          'stateId': localState.id,
          'version': localState.version,
          'state': localState.state,
          'timestamp': localState.timestamp.toIso8601String(),
        },
      );

      if (response['success'] == true) {
        // Server accepted our state
        if (response['conflict'] == true) {
          // Conflict detected - server wins
          final serverState = GameStateSnapshot.fromJson(response['serverState']);
          await _resolveConflict(localState, serverState);
        } else {
          // No conflict - mark as synced
          final syncedState = GameStateSnapshot(
            id: localState.id,
            gameId: localState.gameId,
            lobbyId: localState.lobbyId,
            state: localState.state,
            version: localState.version,
            timestamp: localState.timestamp,
            synced: true,
          );
          await saveState(syncedState);
        }
      }
    } catch (e) {
      // Sync failed - will retry later
      print('State sync failed: $e');
    }
  }

  /// Resolve conflict between local and server state - Feature 3.5.3
  /// Server wins for scoring, but preserve user input
  Future<void> _resolveConflict(
    GameStateSnapshot localState,
    GameStateSnapshot serverState,
  ) async {
    // Merge states: server state as base, preserve local user input
    final mergedState = Map<String, dynamic>.from(serverState.state);

    // Preserve local user input fields
    if (localState.state.containsKey('userInput')) {
      mergedState['userInput'] = localState.state['userInput'];
    }

    // Create new snapshot with merged state
    final resolvedSnapshot = GameStateSnapshot(
      id: 'resolved_${DateTime.now().millisecondsSinceEpoch}',
      gameId: serverState.gameId,
      lobbyId: serverState.lobbyId,
      state: mergedState,
      version: serverState.version + 1,
      timestamp: DateTime.now(),
      synced: true,
    );

    await saveState(resolvedSnapshot);
  }

  /// Auto-save state after action - Feature 3.5.1
  Future<void> autoSaveState({
    required String gameId,
    required String lobbyId,
    required Map<String, dynamic> state,
  }) async {
    final currentState = await loadState(gameId);
    final version = currentState != null ? currentState.version + 1 : 1;

    final snapshot = GameStateSnapshot(
      id: 'state_${DateTime.now().millisecondsSinceEpoch}',
      gameId: gameId,
      lobbyId: lobbyId,
      state: state,
      version: version,
      timestamp: DateTime.now(),
      synced: false,
    );

    await saveState(snapshot);

    // Attempt to sync immediately (non-blocking)
    syncState(gameId).catchError((e) {
      print('Background sync failed: $e');
    });
  }

  /// Recover game state - Feature 3.5.4
  Future<GameStateSnapshot?> recoverState(String gameId) async {
    // Try to load from local storage
    var state = await loadState(gameId);
    
    if (state != null) {
      return state;
    }

    // Try to fetch from server
    try {
      final response = await _apiService.get('/games/$gameId/state');
      
      if (response['success'] == true && response['state'] != null) {
        final serverState = GameStateSnapshot.fromJson(response['state']);
        await saveState(serverState);
        return serverState;
      }
    } catch (e) {
      print('Failed to recover state from server: $e');
    }

    return null;
  }

  /// Get unsynced states
  Future<List<GameStateSnapshot>> getUnsyncedStates() async {
    await initialize();

    final results = await _database!.query(
      'game_states',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'timestamp ASC',
    );

    return results.map((row) {
      return GameStateSnapshot(
        id: row['id'] as String,
        gameId: row['game_id'] as String,
        lobbyId: row['lobby_id'] as String,
        state: jsonDecode(row['state'] as String),
        version: row['version'] as int,
        timestamp: DateTime.parse(row['timestamp'] as String),
        synced: false,
      );
    }).toList();
  }

  /// Sync all unsynced states
  Future<void> syncAllStates() async {
    final unsyncedStates = await getUnsyncedStates();
    
    for (var state in unsyncedStates) {
      try {
        await syncState(state.gameId);
      } catch (e) {
        print('Failed to sync state ${state.id}: $e');
        // Continue with next state
      }
    }
  }

  /// Delete old states (cleanup)
  Future<void> cleanupOldStates({int keepDays = 30}) async {
    await initialize();

    final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));

    await _database!.delete(
      'game_states',
      where: 'timestamp < ? AND synced = ?',
      whereArgs: [cutoffDate.toIso8601String(), 1],
    );

    // Clear cache for deleted states
    _stateCache.removeWhere((key, value) =>
        value.timestamp.isBefore(cutoffDate) && value.synced);
  }

  /// Delete state
  Future<void> deleteState(String stateId) async {
    await initialize();

    await _database!.delete(
      'game_states',
      where: 'id = ?',
      whereArgs: [stateId],
    );

    _stateCache.remove(stateId);
  }

  /// Close database
  Future<void> close() async {
    await _database?.close();
    _database = null;
    _stateCache.clear();
  }
}
