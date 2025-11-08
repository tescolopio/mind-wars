/**
 * Tests for Progression Service
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_wars/services/progression_service.dart';
import 'package:mind_wars/services/api_service.dart';
import 'package:mind_wars/models/models.dart';

void main() {
  group('ProgressionService', () {
    late ProgressionService service;
    late ApiService apiService;

    setUp(() {
      apiService = ApiService(baseUrl: 'https://test.api.com');
      service = ProgressionService(apiService: apiService);
    });

    test('should calculate unified score correctly', () {
      final score = service.calculateScore(
        baseScore: 100,
        timeBonus: 50,
        accuracyBonus: 30,
        streakMultiplier: 1.5,
      );
      
      expect(score, equals(270)); // (100 + 50 + 30) * 1.5 = 270
    });

    test('should calculate score with no multiplier', () {
      final score = service.calculateScore(
        baseScore: 100,
        timeBonus: 50,
        accuracyBonus: 30,
        streakMultiplier: 1.0,
      );
      
      expect(score, equals(180)); // (100 + 50 + 30) * 1.0 = 180
    });

    test('should return correct streak multiplier for 30+ days', () {
      final multiplier = service.getStreakMultiplier(30);
      expect(multiplier, equals(2.0));
    });

    test('should return correct streak multiplier for 14-29 days', () {
      final multiplier = service.getStreakMultiplier(20);
      expect(multiplier, equals(1.75));
    });

    test('should return correct streak multiplier for 7-13 days', () {
      final multiplier = service.getStreakMultiplier(10);
      expect(multiplier, equals(1.5));
    });

    test('should return correct streak multiplier for 3-6 days', () {
      final multiplier = service.getStreakMultiplier(5);
      expect(multiplier, equals(1.25));
    });

    test('should return 1.0 multiplier for streak < 3 days', () {
      final multiplier = service.getStreakMultiplier(2);
      expect(multiplier, equals(1.0));
    });

    test('should calculate level from total score', () {
      expect(service.calculateLevel(0), equals(1));
      expect(service.calculateLevel(500), equals(2));
      expect(service.calculateLevel(2000), equals(3));
      expect(service.calculateLevel(4500), equals(4));
    });

    test('should calculate points for next level', () {
      expect(service.getPointsForNextLevel(1), equals(500));
      expect(service.getPointsForNextLevel(2), equals(2000));
      expect(service.getPointsForNextLevel(3), equals(4500));
    });

    test('should update progress correctly for same day', () {
      final currentProgress = UserProgress(
        userId: 'user123',
        level: 1,
        totalScore: 1000,
        gamesPlayed: 5,
        currentStreak: 3,
        longestStreak: 5,
        badges: [],
        lastPlayedDate: DateTime.now(),
      );
      
      final gameScores = {'user123': 200};
      
      final updated = service.updateProgress(currentProgress, gameScores, false);
      
      expect(updated.totalScore, equals(1200));
      expect(updated.gamesPlayed, equals(6));
      expect(updated.currentStreak, equals(3)); // Same day
      expect(updated.longestStreak, equals(5));
    });

    test('should increment streak for consecutive day', () {
      final yesterday = DateTime.now().subtract(Duration(days: 1));
      
      final currentProgress = UserProgress(
        userId: 'user123',
        level: 1,
        totalScore: 1000,
        gamesPlayed: 5,
        currentStreak: 3,
        longestStreak: 5,
        badges: [],
        lastPlayedDate: yesterday,
      );
      
      final gameScores = {'user123': 200};
      
      final updated = service.updateProgress(currentProgress, gameScores, false);
      
      expect(updated.currentStreak, equals(4)); // Incremented
      expect(updated.longestStreak, equals(5));
    });

    test('should reset streak for non-consecutive day', () {
      final threeDaysAgo = DateTime.now().subtract(Duration(days: 3));
      
      final currentProgress = UserProgress(
        userId: 'user123',
        level: 1,
        totalScore: 1000,
        gamesPlayed: 5,
        currentStreak: 3,
        longestStreak: 5,
        badges: [],
        lastPlayedDate: threeDaysAgo,
      );
      
      final gameScores = {'user123': 200};
      
      final updated = service.updateProgress(currentProgress, gameScores, false);
      
      expect(updated.currentStreak, equals(1)); // Reset
      expect(updated.longestStreak, equals(5)); // Unchanged
    });

    test('should update longest streak', () {
      final yesterday = DateTime.now().subtract(Duration(days: 1));
      
      final currentProgress = UserProgress(
        userId: 'user123',
        level: 1,
        totalScore: 1000,
        gamesPlayed: 5,
        currentStreak: 5,
        longestStreak: 5,
        badges: [],
        lastPlayedDate: yesterday,
      );
      
      final gameScores = {'user123': 200};
      
      final updated = service.updateProgress(currentProgress, gameScores, false);
      
      expect(updated.currentStreak, equals(6)); // Incremented
      expect(updated.longestStreak, equals(6)); // Updated
    });

    test('should award first win badge', () {
      final currentProgress = UserProgress(
        userId: 'user123',
        level: 1,
        totalScore: 1000,
        gamesPlayed: 0,
        currentStreak: 1,
        longestStreak: 1,
        badges: [],
        lastPlayedDate: DateTime.now(),
      );
      
      final gameScores = {'user123': 200};
      
      final updated = service.updateProgress(currentProgress, gameScores, true);
      
      expect(updated.badges.any((b) => b.id == 'first_win'), isTrue);
    });

    test('should award streak badges', () {
      final yesterday = DateTime.now().subtract(Duration(days: 1));
      
      final currentProgress = UserProgress(
        userId: 'user123',
        level: 1,
        totalScore: 1000,
        gamesPlayed: 5,
        currentStreak: 2, // Will become 3
        longestStreak: 2,
        badges: [],
        lastPlayedDate: yesterday,
      );
      
      final gameScores = {'user123': 200};
      
      final updated = service.updateProgress(currentProgress, gameScores, false);
      
      expect(updated.currentStreak, equals(3));
      expect(updated.badges.any((b) => b.id == 'streak_3'), isTrue);
    });

    test('should award games played badges', () {
      final currentProgress = UserProgress(
        userId: 'user123',
        level: 1,
        totalScore: 1000,
        gamesPlayed: 9, // Will become 10
        currentStreak: 1,
        longestStreak: 1,
        badges: [],
        lastPlayedDate: DateTime.now(),
      );
      
      final gameScores = {'user123': 200};
      
      final updated = service.updateProgress(currentProgress, gameScores, false);
      
      expect(updated.gamesPlayed, equals(10));
      expect(updated.badges.any((b) => b.id == 'games_10'), isTrue);
    });

    test('should have 15 total badges available', () {
      final badges = service.getAllBadges();
      expect(badges.length, equals(15));
    });

    test('should get player rank from leaderboard', () {
      final leaderboard = [
        LeaderboardEntry(
          playerId: 'player1',
          username: 'Player 1',
          totalScore: 1000,
          gamesPlayed: 10,
          wins: 5,
          rank: 1,
          weekStartDate: DateTime.now(),
        ),
        LeaderboardEntry(
          playerId: 'player2',
          username: 'Player 2',
          totalScore: 800,
          gamesPlayed: 8,
          wins: 4,
          rank: 2,
          weekStartDate: DateTime.now(),
        ),
        LeaderboardEntry(
          playerId: 'player3',
          username: 'Player 3',
          totalScore: 600,
          gamesPlayed: 6,
          wins: 3,
          rank: 3,
          weekStartDate: DateTime.now(),
        ),
      ];
      
      expect(service.getPlayerRank(leaderboard, 'player1'), equals(1));
      expect(service.getPlayerRank(leaderboard, 'player2'), equals(2));
      expect(service.getPlayerRank(leaderboard, 'player3'), equals(3));
      expect(service.getPlayerRank(leaderboard, 'player999'), equals(-1));
    });
  });
}
