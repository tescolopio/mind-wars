/**
 * Tests for enhanced GameLobby model
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_wars/models/models.dart';

void main() {
  group('GameLobby', () {
    late GameLobby testLobby;
    late List<Player> testPlayers;

    setUp(() {
      testPlayers = [
        Player(
          id: 'player1',
          username: 'Alice',
          status: PlayerStatus.active,
          score: 100,
          streak: 3,
          badges: [],
          lastActive: DateTime.now(),
        ),
        Player(
          id: 'player2',
          username: 'Bob',
          status: PlayerStatus.active,
          score: 80,
          streak: 1,
          badges: [],
          lastActive: DateTime.now(),
        ),
      ];

      testLobby = GameLobby(
        id: 'lobby1',
        name: 'Test Lobby',
        hostId: 'player1',
        players: testPlayers,
        maxPlayers: 4,
        status: 'waiting',
        createdAt: DateTime.now(),
        lobbyCode: 'FAMILY42',
        isPrivate: true,
        numberOfRounds: 3,
        votingPointsPerPlayer: 10,
      );
    });

    group('constructor and defaults', () {
      test('creates lobby with all fields', () {
        expect(testLobby.id, 'lobby1');
        expect(testLobby.name, 'Test Lobby');
        expect(testLobby.hostId, 'player1');
        expect(testLobby.players.length, 2);
        expect(testLobby.maxPlayers, 4);
        expect(testLobby.lobbyCode, 'FAMILY42');
        expect(testLobby.isPrivate, true);
        expect(testLobby.numberOfRounds, 3);
        expect(testLobby.votingPointsPerPlayer, 10);
      });

      test('defaults to private lobby', () {
        final lobby = GameLobby(
          id: 'lobby2',
          name: 'Test',
          hostId: 'host1',
          players: [],
          maxPlayers: 4,
          status: 'waiting',
          createdAt: DateTime.now(),
        );
        expect(lobby.isPrivate, true);
      });

      test('defaults to 3 rounds', () {
        final lobby = GameLobby(
          id: 'lobby2',
          name: 'Test',
          hostId: 'host1',
          players: [],
          maxPlayers: 4,
          status: 'waiting',
          createdAt: DateTime.now(),
        );
        expect(lobby.numberOfRounds, 3);
      });

      test('defaults to 10 voting points', () {
        final lobby = GameLobby(
          id: 'lobby2',
          name: 'Test',
          hostId: 'host1',
          players: [],
          maxPlayers: 4,
          status: 'waiting',
          createdAt: DateTime.now(),
        );
        expect(lobby.votingPointsPerPlayer, 10);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final json = testLobby.toJson();

        expect(json['id'], 'lobby1');
        expect(json['name'], 'Test Lobby');
        expect(json['hostId'], 'player1');
        expect(json['maxPlayers'], 4);
        expect(json['status'], 'waiting');
        expect(json['lobbyCode'], 'FAMILY42');
        expect(json['isPrivate'], true);
        expect(json['numberOfRounds'], 3);
        expect(json['votingPointsPerPlayer'], 10);
        expect(json['players'], isA<List>());
      });
    });

    group('fromJson', () {
      test('deserializes all fields correctly', () {
        final json = {
          'id': 'lobby2',
          'name': 'JSON Lobby',
          'hostId': 'host2',
          'players': [
            {
              'id': 'p1',
              'username': 'User1',
              'status': 'PlayerStatus.active',
              'score': 50,
              'streak': 2,
              'badges': [],
              'lastActive': DateTime.now().toIso8601String(),
            }
          ],
          'maxPlayers': 6,
          'status': 'waiting',
          'createdAt': DateTime.now().toIso8601String(),
          'lobbyCode': 'TEAM99',
          'isPrivate': false,
          'numberOfRounds': 5,
          'votingPointsPerPlayer': 15,
        };

        final lobby = GameLobby.fromJson(json);

        expect(lobby.id, 'lobby2');
        expect(lobby.name, 'JSON Lobby');
        expect(lobby.hostId, 'host2');
        expect(lobby.maxPlayers, 6);
        expect(lobby.lobbyCode, 'TEAM99');
        expect(lobby.isPrivate, false);
        expect(lobby.numberOfRounds, 5);
        expect(lobby.votingPointsPerPlayer, 15);
      });

      test('handles missing optional fields', () {
        final json = {
          'id': 'lobby3',
          'name': 'Minimal Lobby',
          'hostId': 'host3',
          'players': [],
          'maxPlayers': 4,
          'status': 'waiting',
          'createdAt': DateTime.now().toIso8601String(),
        };

        final lobby = GameLobby.fromJson(json);

        expect(lobby.lobbyCode, null);
        expect(lobby.isPrivate, true); // Default
        expect(lobby.numberOfRounds, 3); // Default
        expect(lobby.votingPointsPerPlayer, 10); // Default
      });
    });

    group('copyWith', () {
      test('copies with updated fields', () {
        final updated = testLobby.copyWith(
          name: 'Updated Lobby',
          maxPlayers: 6,
        );

        expect(updated.name, 'Updated Lobby');
        expect(updated.maxPlayers, 6);
        expect(updated.id, testLobby.id); // Unchanged
        expect(updated.hostId, testLobby.hostId); // Unchanged
      });

      test('copies with updated lobby settings', () {
        final updated = testLobby.copyWith(
          isPrivate: false,
          numberOfRounds: 5,
          votingPointsPerPlayer: 20,
        );

        expect(updated.isPrivate, false);
        expect(updated.numberOfRounds, 5);
        expect(updated.votingPointsPerPlayer, 20);
      });
    });

    group('isHost', () {
      test('returns true for host player', () {
        expect(testLobby.isHost('player1'), true);
      });

      test('returns false for non-host player', () {
        expect(testLobby.isHost('player2'), false);
      });

      test('returns false for non-existent player', () {
        expect(testLobby.isHost('unknown'), false);
      });
    });

    group('isFull', () {
      test('returns false when not full', () {
        expect(testLobby.isFull, false);
      });

      test('returns true when full', () {
        final fullLobby = testLobby.copyWith(
          players: List.generate(
            4,
            (i) => Player(
              id: 'p$i',
              username: 'Player$i',
              status: PlayerStatus.active,
              score: 0,
              streak: 0,
              badges: [],
              lastActive: DateTime.now(),
            ),
          ),
        );

        expect(fullLobby.isFull, true);
      });
    });

    group('canJoin', () {
      test('returns true when waiting and not full', () {
        expect(testLobby.canJoin, true);
      });

      test('returns false when in-progress', () {
        final inProgressLobby = testLobby.copyWith(status: 'in-progress');
        expect(inProgressLobby.canJoin, false);
      });

      test('returns false when full', () {
        final fullLobby = testLobby.copyWith(
          players: List.generate(
            4,
            (i) => Player(
              id: 'p$i',
              username: 'Player$i',
              status: PlayerStatus.active,
              score: 0,
              streak: 0,
              badges: [],
              lastActive: DateTime.now(),
            ),
          ),
        );

        expect(fullLobby.canJoin, false);
      });
    });
  });
}
