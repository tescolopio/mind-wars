/**
 * Tests for Voting Service
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_wars/services/voting_service.dart';
import 'package:mind_wars/models/models.dart';

void main() {
  group('VotingService', () {
    late VotingService votingService;

    setUp(() {
      votingService = VotingService();
    });

    tearDown(() {
      votingService.clearSession();
    });

    group('createVotingSession', () {
      test('should create a voting session with valid parameters', () {
        final session = votingService.createVotingSession(
          lobbyId: 'lobby123',
          pointsPerPlayer: 10,
          totalRounds: 3,
          playerIds: ['player1', 'player2', 'player3'],
        );

        expect(session.lobbyId, equals('lobby123'));
        expect(session.pointsPerPlayer, equals(10));
        expect(session.totalRounds, equals(3));
        expect(session.currentRound, equals(1));
        expect(session.remainingPoints['player1'], equals(10));
        expect(session.remainingPoints['player2'], equals(10));
        expect(session.remainingPoints['player3'], equals(10));
        expect(session.completed, isFalse);
        expect(session.isVotingOpen, isTrue);
        expect(session.availableGames.isNotEmpty, isTrue);
      });

      test('should create session with specified games', () {
        final games = ['memory_match', 'sudoku_duel', 'word_builder'];
        final session = votingService.createVotingSession(
          lobbyId: 'lobby123',
          pointsPerPlayer: 10,
          totalRounds: 3,
          playerIds: ['player1', 'player2'],
          availableGames: games,
        );

        expect(session.availableGames, equals(games));
      });

      test('should throw exception if pointsPerPlayer is zero or negative', () {
        expect(
          () => votingService.createVotingSession(
            lobbyId: 'lobby123',
            pointsPerPlayer: 0,
            totalRounds: 3,
            playerIds: ['player1'],
          ),
          throwsException,
        );

        expect(
          () => votingService.createVotingSession(
            lobbyId: 'lobby123',
            pointsPerPlayer: -5,
            totalRounds: 3,
            playerIds: ['player1'],
          ),
          throwsException,
        );
      });

      test('should throw exception if totalRounds is zero or negative', () {
        expect(
          () => votingService.createVotingSession(
            lobbyId: 'lobby123',
            pointsPerPlayer: 10,
            totalRounds: 0,
            playerIds: ['player1'],
          ),
          throwsException,
        );

        expect(
          () => votingService.createVotingSession(
            lobbyId: 'lobby123',
            pointsPerPlayer: 10,
            totalRounds: -3,
            playerIds: ['player1'],
          ),
          throwsException,
        );
      });

      test('should throw exception if no players', () {
        expect(
          () => votingService.createVotingSession(
            lobbyId: 'lobby123',
            pointsPerPlayer: 10,
            totalRounds: 3,
            playerIds: [],
          ),
          throwsException,
        );
      });
    });

    group('castVote', () {
      setUp(() {
        votingService.createVotingSession(
          lobbyId: 'lobby123',
          pointsPerPlayer: 10,
          totalRounds: 3,
          playerIds: ['player1', 'player2'],
          availableGames: ['memory_match', 'sudoku_duel', 'word_builder'],
        );
      });

      test('should allow player to cast vote', () {
        final vote = votingService.castVote(
          playerId: 'player1',
          gameId: 'memory_match',
          points: 5,
        );

        expect(vote.playerId, equals('player1'));
        expect(vote.gameId, equals('memory_match'));
        expect(vote.points, equals(5));
        expect(votingService.getRemainingPoints('player1'), equals(5));
      });

      test('should allow multiple votes from same player', () {
        votingService.castVote(
          playerId: 'player1',
          gameId: 'memory_match',
          points: 3,
        );
        votingService.castVote(
          playerId: 'player1',
          gameId: 'sudoku_duel',
          points: 4,
        );

        expect(votingService.getRemainingPoints('player1'), equals(3));
        final votes = votingService.getPlayerVotes('player1');
        expect(votes['memory_match'], equals(3));
        expect(votes['sudoku_duel'], equals(4));
      });

      test('should allow multiple votes on same game', () {
        votingService.castVote(
          playerId: 'player1',
          gameId: 'memory_match',
          points: 3,
        );
        votingService.castVote(
          playerId: 'player1',
          gameId: 'memory_match',
          points: 2,
        );

        final votes = votingService.getPlayerVotes('player1');
        expect(votes['memory_match'], equals(5));
        expect(votingService.getRemainingPoints('player1'), equals(5));
      });

      test('should throw exception if not enough points', () {
        expect(
          () => votingService.castVote(
            playerId: 'player1',
            gameId: 'memory_match',
            points: 15,
          ),
          throwsException,
        );
      });

      test('should throw exception if points is zero or negative', () {
        expect(
          () => votingService.castVote(
            playerId: 'player1',
            gameId: 'memory_match',
            points: 0,
          ),
          throwsException,
        );

        expect(
          () => votingService.castVote(
            playerId: 'player1',
            gameId: 'memory_match',
            points: -3,
          ),
          throwsException,
        );
      });

      test('should throw exception if game not available', () {
        expect(
          () => votingService.castVote(
            playerId: 'player1',
            gameId: 'invalid_game',
            points: 5,
          ),
          throwsException,
        );
      });

      test('should throw exception if player not in session', () {
        expect(
          () => votingService.castVote(
            playerId: 'player3',
            gameId: 'memory_match',
            points: 5,
          ),
          throwsException,
        );
      });
    });

    group('removeVote', () {
      setUp(() {
        votingService.createVotingSession(
          lobbyId: 'lobby123',
          pointsPerPlayer: 10,
          totalRounds: 3,
          playerIds: ['player1', 'player2'],
          availableGames: ['memory_match', 'sudoku_duel', 'word_builder'],
        );
        votingService.castVote(
          playerId: 'player1',
          gameId: 'memory_match',
          points: 5,
        );
      });

      test('should remove specific points from vote', () {
        votingService.removeVote(
          playerId: 'player1',
          gameId: 'memory_match',
          points: 2,
        );

        final votes = votingService.getPlayerVotes('player1');
        expect(votes['memory_match'], equals(3));
        expect(votingService.getRemainingPoints('player1'), equals(7));
      });

      test('should remove all points if not specified', () {
        votingService.removeVote(
          playerId: 'player1',
          gameId: 'memory_match',
        );

        final votes = votingService.getPlayerVotes('player1');
        expect(votes['memory_match'], isNull);
        expect(votingService.getRemainingPoints('player1'), equals(10));
      });

      test('should throw exception if no votes to remove', () {
        expect(
          () => votingService.removeVote(
            playerId: 'player1',
            gameId: 'sudoku_duel',
          ),
          throwsException,
        );
      });

      test('should throw exception if removing more points than voted', () {
        expect(
          () => votingService.removeVote(
            playerId: 'player1',
            gameId: 'memory_match',
            points: 10,
          ),
          throwsException,
        );
      });
    });

    group('endVotingRound', () {
      setUp(() {
        votingService.createVotingSession(
          lobbyId: 'lobby123',
          pointsPerPlayer: 10,
          totalRounds: 3,
          playerIds: ['player1', 'player2', 'player3'],
          availableGames: ['memory_match', 'sudoku_duel', 'word_builder'],
        );
      });

      test('should select game with most votes', () {
        votingService.castVote(
          playerId: 'player1',
          gameId: 'memory_match',
          points: 5,
        );
        votingService.castVote(
          playerId: 'player2',
          gameId: 'memory_match',
          points: 7,
        );
        votingService.castVote(
          playerId: 'player3',
          gameId: 'sudoku_duel',
          points: 3,
        );

        final winner = votingService.endVotingRound();
        expect(winner, equals('memory_match'));
        expect(votingService.selectedGames, contains('memory_match'));
      });

      test('should move to next round after voting', () {
        votingService.castVote(
          playerId: 'player1',
          gameId: 'memory_match',
          points: 5,
        );

        votingService.endVotingRound();

        final session = votingService.currentSession!;
        expect(session.currentRound, equals(2));
        expect(session.completed, isFalse);
        expect(session.isVotingOpen, isTrue);
        // Points should be reset
        expect(session.remainingPoints['player1'], equals(10));
      });

      test('should complete session after all rounds', () {
        // Round 1
        votingService.castVote(
          playerId: 'player1',
          gameId: 'memory_match',
          points: 5,
        );
        votingService.endVotingRound();

        // Round 2
        votingService.castVote(
          playerId: 'player1',
          gameId: 'sudoku_duel',
          points: 5,
        );
        votingService.endVotingRound();

        // Round 3
        votingService.castVote(
          playerId: 'player1',
          gameId: 'word_builder',
          points: 5,
        );
        votingService.endVotingRound();

        final session = votingService.currentSession!;
        expect(session.completed, isTrue);
        expect(session.isVotingOpen, isFalse);
        expect(session.selectedGames.length, equals(3));
      });

      test('should throw exception if no votes cast', () {
        expect(
          () => votingService.endVotingRound(),
          throwsException,
        );
      });
    });

    group('getCurrentResults', () {
      setUp(() {
        votingService.createVotingSession(
          lobbyId: 'lobby123',
          pointsPerPlayer: 10,
          totalRounds: 3,
          playerIds: ['player1', 'player2', 'player3'],
          availableGames: ['memory_match', 'sudoku_duel', 'word_builder'],
        );
      });

      test('should calculate vote totals correctly', () {
        votingService.castVote(
          playerId: 'player1',
          gameId: 'memory_match',
          points: 5,
        );
        votingService.castVote(
          playerId: 'player2',
          gameId: 'memory_match',
          points: 3,
        );
        votingService.castVote(
          playerId: 'player3',
          gameId: 'sudoku_duel',
          points: 7,
        );

        final results = votingService.getCurrentResults();
        expect(results['memory_match'], equals(8));
        expect(results['sudoku_duel'], equals(7));
      });

      test('should return empty map if no votes', () {
        final results = votingService.getCurrentResults();
        expect(results.isEmpty, isTrue);
      });
    });

    group('allPlayersVoted', () {
      setUp(() {
        votingService.createVotingSession(
          lobbyId: 'lobby123',
          pointsPerPlayer: 10,
          totalRounds: 3,
          playerIds: ['player1', 'player2'],
          availableGames: ['memory_match', 'sudoku_duel'],
        );
      });

      test('should return false if players have remaining points', () {
        votingService.castVote(
          playerId: 'player1',
          gameId: 'memory_match',
          points: 5,
        );

        expect(votingService.allPlayersVoted, isFalse);
      });

      test('should return true if all players used all points', () {
        votingService.castVote(
          playerId: 'player1',
          gameId: 'memory_match',
          points: 10,
        );
        votingService.castVote(
          playerId: 'player2',
          gameId: 'sudoku_duel',
          points: 10,
        );

        expect(votingService.allPlayersVoted, isTrue);
      });
    });

    group('VotingSession model', () {
      test('should calculate game totals correctly', () {
        final session = VotingSession(
          id: 'session1',
          lobbyId: 'lobby1',
          pointsPerPlayer: 10,
          totalRounds: 3,
          currentRound: 1,
          availableGames: ['game1', 'game2', 'game3'],
          votes: {
            'player1': {'game1': 5, 'game2': 3},
            'player2': {'game1': 7, 'game3': 2},
          },
          remainingPoints: {'player1': 2, 'player2': 1},
          selectedGames: [],
          completed: false,
          createdAt: DateTime.now(),
        );

        final totals = session.calculateGameTotals();
        expect(totals['game1'], equals(12));
        expect(totals['game2'], equals(3));
        expect(totals['game3'], equals(2));
      });

      test('should get winning game correctly', () {
        final session = VotingSession(
          id: 'session1',
          lobbyId: 'lobby1',
          pointsPerPlayer: 10,
          totalRounds: 3,
          currentRound: 1,
          availableGames: ['game1', 'game2', 'game3'],
          votes: {
            'player1': {'game1': 5, 'game2': 3},
            'player2': {'game2': 7, 'game3': 2},
          },
          remainingPoints: {'player1': 2, 'player2': 1},
          selectedGames: [],
          completed: false,
          createdAt: DateTime.now(),
        );

        final winner = session.getWinningGame();
        expect(winner, equals('game2')); // 3 + 7 = 10
      });

      test('should return null if no votes', () {
        final session = VotingSession(
          id: 'session1',
          lobbyId: 'lobby1',
          pointsPerPlayer: 10,
          totalRounds: 3,
          currentRound: 1,
          availableGames: ['game1', 'game2'],
          votes: {},
          remainingPoints: {'player1': 10, 'player2': 10},
          selectedGames: [],
          completed: false,
          createdAt: DateTime.now(),
        );

        final winner = session.getWinningGame();
        expect(winner, isNull);
      });

      test('should serialize and deserialize correctly', () {
        final session = VotingSession(
          id: 'session1',
          lobbyId: 'lobby1',
          pointsPerPlayer: 10,
          totalRounds: 3,
          currentRound: 2,
          availableGames: ['game1', 'game2'],
          votes: {
            'player1': {'game1': 5},
          },
          remainingPoints: {'player1': 5, 'player2': 10},
          selectedGames: ['game2'],
          completed: false,
          createdAt: DateTime.now(),
        );

        final json = session.toJson();
        final deserialized = VotingSession.fromJson(json);

        expect(deserialized.id, equals(session.id));
        expect(deserialized.lobbyId, equals(session.lobbyId));
        expect(deserialized.pointsPerPlayer, equals(session.pointsPerPlayer));
        expect(deserialized.totalRounds, equals(session.totalRounds));
        expect(deserialized.currentRound, equals(session.currentRound));
        expect(deserialized.availableGames, equals(session.availableGames));
        expect(deserialized.votes, equals(session.votes));
        expect(
            deserialized.remainingPoints, equals(session.remainingPoints));
        expect(deserialized.selectedGames, equals(session.selectedGames));
        expect(deserialized.completed, equals(session.completed));
      });
    });
  });
}
