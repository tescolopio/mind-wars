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
          gamesPerRound: 2,
          playerIds: ['player1', 'player2', 'player3'],
        );

        expect(session.lobbyId, equals('lobby123'));
        expect(session.pointsPerPlayer, equals(10));
        expect(session.totalRounds, equals(3));
        expect(session.gamesPerRound, equals(2));
        expect(session.currentRound, equals(1));
        expect(session.totalGames, equals(6)); // 3 rounds * 2 games per round
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
          gamesPerRound: 1,
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
            gamesPerRound: 2,
            playerIds: ['player1'],
          ),
          throwsException,
        );

        expect(
          () => votingService.createVotingSession(
            lobbyId: 'lobby123',
            pointsPerPlayer: -5,
            totalRounds: 3,
            gamesPerRound: 2,
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
            gamesPerRound: 2,
            playerIds: ['player1'],
          ),
          throwsException,
        );

        expect(
          () => votingService.createVotingSession(
            lobbyId: 'lobby123',
            pointsPerPlayer: 10,
            totalRounds: -3,
            gamesPerRound: 2,
            playerIds: ['player1'],
          ),
          throwsException,
        );
      });

      test('should throw exception if gamesPerRound is zero or negative', () {
        expect(
          () => votingService.createVotingSession(
            lobbyId: 'lobby123',
            pointsPerPlayer: 10,
            totalRounds: 3,
            gamesPerRound: 0,
            playerIds: ['player1'],
          ),
          throwsException,
        );

        expect(
          () => votingService.createVotingSession(
            lobbyId: 'lobby123',
            pointsPerPlayer: 10,
            totalRounds: 3,
            gamesPerRound: -2,
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
            gamesPerRound: 2,
            playerIds: [],
          ),
          throwsException,
        );
      });

      test('should throw exception if less than 3 games available', () {
        expect(
          () => votingService.createVotingSession(
            lobbyId: 'lobby123',
            pointsPerPlayer: 10,
            totalRounds: 3,
            gamesPerRound: 1,
            playerIds: ['player1', 'player2'],
            availableGames: ['game1', 'game2'],
          ),
          throwsException,
        );

        expect(
          () => votingService.createVotingSession(
            lobbyId: 'lobby123',
            pointsPerPlayer: 10,
            totalRounds: 3,
            gamesPerRound: 1,
            playerIds: ['player1', 'player2'],
            availableGames: ['game1'],
          ),
          throwsException,
        );
      });

      test('should succeed with exactly 3 games', () {
        final session = votingService.createVotingSession(
          lobbyId: 'lobby123',
          pointsPerPlayer: 10,
          totalRounds: 3,
          gamesPerRound: 1,
          playerIds: ['player1', 'player2'],
          availableGames: ['game1', 'game2', 'game3'],
        );

        expect(session.availableGames.length, equals(3));
      });

      test('should throw exception if not enough games for gamesPerRound', () {
        expect(
          () => votingService.createVotingSession(
            lobbyId: 'lobby123',
            pointsPerPlayer: 10,
            totalRounds: 2,
            gamesPerRound: 5,
            playerIds: ['player1', 'player2'],
            availableGames: ['game1', 'game2', 'game3'],
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
          gamesPerRound: 2,
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
          gamesPerRound: 2,
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
          gamesPerRound: 2,
          playerIds: ['player1', 'player2', 'player3'],
          availableGames: ['memory_match', 'sudoku_duel', 'word_builder', 'puzzle_race'],
        );
      });

      test('should select top N games based on gamesPerRound', () {
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
          points: 8,
        );
        votingService.castVote(
          playerId: 'player1',
          gameId: 'word_builder',
          points: 3,
        );

        final winners = votingService.endVotingRound();
        expect(winners.length, equals(2));
        expect(winners, contains('memory_match')); // 12 points
        expect(winners, contains('sudoku_duel')); // 8 points
        
        final session = votingService.currentSession!;
        expect(session.selectedGames.length, equals(1)); // One round complete
        expect(session.selectedGames[0], equals(winners));
      });

      test('should move to next round after voting', () {
        votingService.castVote(
          playerId: 'player1',
          gameId: 'memory_match',
          points: 5,
        );
        votingService.castVote(
          playerId: 'player2',
          gameId: 'sudoku_duel',
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
        votingService.castVote(
          playerId: 'player2',
          gameId: 'sudoku_duel',
          points: 5,
        );
        votingService.endVotingRound();

        // Round 2
        votingService.castVote(
          playerId: 'player1',
          gameId: 'word_builder',
          points: 5,
        );
        votingService.castVote(
          playerId: 'player2',
          gameId: 'puzzle_race',
          points: 5,
        );
        votingService.endVotingRound();

        // Round 3
        votingService.castVote(
          playerId: 'player1',
          gameId: 'memory_match',
          points: 5,
        );
        votingService.castVote(
          playerId: 'player2',
          gameId: 'sudoku_duel',
          points: 5,
        );
        votingService.endVotingRound();

        final session = votingService.currentSession!;
        expect(session.completed, isTrue);
        expect(session.isVotingOpen, isFalse);
        expect(session.selectedGames.length, equals(3)); // 3 rounds
        expect(session.totalGames, equals(6)); // 3 rounds * 2 games per round
        expect(session.allSelectedGames.length, equals(6));
      });

      test('should throw exception if no votes cast', () {
        expect(
          () => votingService.endVotingRound(),
          throwsException,
        );
      });

      test('should throw exception if not enough games voted on', () {
        // Only vote on 1 game when 2 games per round are required
        votingService.castVote(
          playerId: 'player1',
          gameId: 'memory_match',
          points: 10,
        );

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
          gamesPerRound: 2,
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
          gamesPerRound: 2,
          playerIds: ['player1', 'player2'],
          availableGames: ['memory_match', 'sudoku_duel', 'word_builder'],
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
          gamesPerRound: 2,
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

      test('should get top N games correctly', () {
        final session = VotingSession(
          id: 'session1',
          lobbyId: 'lobby1',
          pointsPerPlayer: 10,
          totalRounds: 3,
          gamesPerRound: 2,
          currentRound: 1,
          availableGames: ['game1', 'game2', 'game3', 'game4'],
          votes: {
            'player1': {'game1': 5, 'game2': 3, 'game3': 2},
            'player2': {'game2': 7, 'game3': 4, 'game4': 1},
          },
          remainingPoints: {'player1': 0, 'player2': 0},
          selectedGames: [],
          completed: false,
          createdAt: DateTime.now(),
        );

        final top2 = session.getTopGames(2);
        expect(top2.length, equals(2));
        expect(top2, contains('game2')); // 10 points
        expect(top2, contains('game3')); // 6 points
      });

      test('should calculate totalGames correctly', () {
        final session = VotingSession(
          id: 'session1',
          lobbyId: 'lobby1',
          pointsPerPlayer: 10,
          totalRounds: 4,
          gamesPerRound: 3,
          currentRound: 1,
          availableGames: ['game1', 'game2', 'game3'],
          votes: {},
          remainingPoints: {'player1': 10},
          selectedGames: [],
          completed: false,
          createdAt: DateTime.now(),
        );

        expect(session.totalGames, equals(12)); // 4 rounds * 3 games per round
      });

      test('should flatten selected games correctly', () {
        final session = VotingSession(
          id: 'session1',
          lobbyId: 'lobby1',
          pointsPerPlayer: 10,
          totalRounds: 2,
          gamesPerRound: 2,
          currentRound: 3,
          availableGames: ['game1', 'game2', 'game3', 'game4'],
          votes: {},
          remainingPoints: {'player1': 10},
          selectedGames: [
            ['game1', 'game2'],
            ['game3', 'game4'],
          ],
          completed: true,
          createdAt: DateTime.now(),
        );

        final allGames = session.allSelectedGames;
        expect(allGames.length, equals(4));
        expect(allGames, equals(['game1', 'game2', 'game3', 'game4']));
      });

      test('should serialize and deserialize correctly', () {
        final session = VotingSession(
          id: 'session1',
          lobbyId: 'lobby1',
          pointsPerPlayer: 10,
          totalRounds: 3,
          gamesPerRound: 2,
          currentRound: 2,
          availableGames: ['game1', 'game2', 'game3'],
          votes: {
            'player1': {'game1': 5},
          },
          remainingPoints: {'player1': 5, 'player2': 10},
          selectedGames: [
            ['game1', 'game2']
          ],
          completed: false,
          createdAt: DateTime.now(),
        );

        final json = session.toJson();
        final deserialized = VotingSession.fromJson(json);

        expect(deserialized.id, equals(session.id));
        expect(deserialized.lobbyId, equals(session.lobbyId));
        expect(deserialized.pointsPerPlayer, equals(session.pointsPerPlayer));
        expect(deserialized.totalRounds, equals(session.totalRounds));
        expect(deserialized.gamesPerRound, equals(session.gamesPerRound));
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
