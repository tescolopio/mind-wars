/**
 * Progression Service - Handles leaderboards, badges, streaks, and scoring
 */

import 'dart:math';
import '../models/models.dart';
import 'api_service.dart';

class ProgressionService {
  final ApiService apiService;

  ProgressionService({required this.apiService});

  /// Available badges
  static final Map<String, Map<String, String>> badges = {
    'first_win': {
      'name': 'First Victory',
      'description': 'Win your first game',
      'icon': '🏆',
    },
    'streak_3': {
      'name': 'On Fire',
      'description': 'Maintain a 3-day streak',
      'icon': '🔥',
    },
    'streak_7': {
      'name': 'Weekly Warrior',
      'description': 'Maintain a 7-day streak',
      'icon': '⚔️',
    },
    'streak_30': {
      'name': 'Monthly Master',
      'description': 'Maintain a 30-day streak',
      'icon': '👑',
    },
    'games_10': {
      'name': 'Getting Started',
      'description': 'Play 10 games',
      'icon': '🎮',
    },
    'games_50': {
      'name': 'Regular Player',
      'description': 'Play 50 games',
      'icon': '🎯',
    },
    'games_100': {
      'name': 'Dedicated Gamer',
      'description': 'Play 100 games',
      'icon': '⭐',
    },
    'perfect_game': {
      'name': 'Flawless',
      'description': 'Complete a game with a perfect score',
      'icon': '💎',
    },
    'social_butterfly': {
      'name': 'Social Butterfly',
      'description': 'Play with 10 different players',
      'icon': '🦋',
    },
    'master_memory': {
      'name': 'Memory Master',
      'description': 'Excel in memory games',
      'icon': '🧠',
    },
    'master_logic': {
      'name': 'Logic Legend',
      'description': 'Excel in logic games',
      'icon': '🔍',
    },
    'master_attention': {
      'name': 'Attention Ace',
      'description': 'Excel in attention games',
      'icon': '👁️',
    },
    'master_spatial': {
      'name': 'Spatial Savant',
      'description': 'Excel in spatial games',
      'icon': '🧩',
    },
    'master_language': {
      'name': 'Language Lord',
      'description': 'Excel in language games',
      'icon': '📚',
    },
  };

  /// Calculate unified score based on game performance
  int calculateScore({
    required int baseScore,
    required int timeBonus,
    required int accuracyBonus,
    required double streakMultiplier,
  }) {
    final total = (baseScore + timeBonus + accuracyBonus) * streakMultiplier;
    return total.round();
  }

  /// Update user progress after a game
  UserProgress updateProgress(
    UserProgress currentProgress,
    Map<String, int> gameScores,
    bool isWin,
  ) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    final lastPlayed = currentProgress.lastPlayedDate;
    final lastPlayedDate = DateTime(
      lastPlayed.year,
      lastPlayed.month,
      lastPlayed.day,
    );
    
    final daysDiff = todayDate.difference(lastPlayedDate).inDays;

    // Update streak
    int newStreak = currentProgress.currentStreak;
    if (daysDiff == 0) {
      // Same day, streak continues
    } else if (daysDiff == 1) {
      // Next day, increment streak
      newStreak++;
    } else {
      // Streak broken
      newStreak = 1;
    }

    final playerScore = gameScores[currentProgress.userId] ?? 0;

    final updatedProgress = UserProgress(
      userId: currentProgress.userId,
      level: calculateLevel(currentProgress.totalScore + playerScore),
      totalScore: currentProgress.totalScore + playerScore,
      gamesPlayed: currentProgress.gamesPlayed + 1,
      currentStreak: newStreak,
      longestStreak: currentProgress.longestStreak > newStreak
          ? currentProgress.longestStreak
          : newStreak,
      badges: [
        ...currentProgress.badges,
        ...checkNewBadges(currentProgress, isWin),
      ],
      lastPlayedDate: DateTime.now(),
    );

    return updatedProgress;
  }

  /// Check for newly earned badges
  List<Badge> checkNewBadges(UserProgress progress, bool isWin) {
    final earnedBadgeIds = progress.badges.map((b) => b.id).toSet();
    final newBadges = <Badge>[];
    final now = DateTime.now();

    // First win
    if (isWin && !earnedBadgeIds.contains('first_win')) {
      newBadges.add(Badge(
        id: 'first_win',
        name: badges['first_win']!['name']!,
        description: badges['first_win']!['description']!,
        icon: badges['first_win']!['icon']!,
        earnedAt: now,
      ));
    }

    // Streak badges
    if (progress.currentStreak >= 3 && !earnedBadgeIds.contains('streak_3')) {
      newBadges.add(Badge(
        id: 'streak_3',
        name: badges['streak_3']!['name']!,
        description: badges['streak_3']!['description']!,
        icon: badges['streak_3']!['icon']!,
        earnedAt: now,
      ));
    }
    if (progress.currentStreak >= 7 && !earnedBadgeIds.contains('streak_7')) {
      newBadges.add(Badge(
        id: 'streak_7',
        name: badges['streak_7']!['name']!,
        description: badges['streak_7']!['description']!,
        icon: badges['streak_7']!['icon']!,
        earnedAt: now,
      ));
    }
    if (progress.currentStreak >= 30 && !earnedBadgeIds.contains('streak_30')) {
      newBadges.add(Badge(
        id: 'streak_30',
        name: badges['streak_30']!['name']!,
        description: badges['streak_30']!['description']!,
        icon: badges['streak_30']!['icon']!,
        earnedAt: now,
      ));
    }

    // Games played badges
    if (progress.gamesPlayed >= 10 && !earnedBadgeIds.contains('games_10')) {
      newBadges.add(Badge(
        id: 'games_10',
        name: badges['games_10']!['name']!,
        description: badges['games_10']!['description']!,
        icon: badges['games_10']!['icon']!,
        earnedAt: now,
      ));
    }
    if (progress.gamesPlayed >= 50 && !earnedBadgeIds.contains('games_50')) {
      newBadges.add(Badge(
        id: 'games_50',
        name: badges['games_50']!['name']!,
        description: badges['games_50']!['description']!,
        icon: badges['games_50']!['icon']!,
        earnedAt: now,
      ));
    }
    if (progress.gamesPlayed >= 100 && !earnedBadgeIds.contains('games_100')) {
      newBadges.add(Badge(
        id: 'games_100',
        name: badges['games_100']!['name']!,
        description: badges['games_100']!['description']!,
        icon: badges['games_100']!['icon']!,
        earnedAt: now,
      ));
    }

    return newBadges;
  }

  /// Get weekly leaderboard
  Future<List<LeaderboardEntry>> getWeeklyLeaderboard() async {
    try {
      return await apiService.getWeeklyLeaderboard();
    } catch (error) {
      print('Error fetching leaderboard: $error');
      return [];
    }
  }

  /// Get all badges
  List<Map<String, String>> getAllBadges() {
    return badges.values.toList();
  }

  /// Calculate streak multiplier
  double getStreakMultiplier(int streak) {
    if (streak >= 30) return 2.0;
    if (streak >= 14) return 1.75;
    if (streak >= 7) return 1.5;
    if (streak >= 3) return 1.25;
    return 1.0;
  }

  /// Get player rank from leaderboard
  int getPlayerRank(List<LeaderboardEntry> leaderboard, String playerId) {
    final entry = leaderboard.firstWhere(
      (e) => e.playerId == playerId,
      orElse: () => LeaderboardEntry(
        playerId: '',
        username: '',
        totalScore: 0,
        gamesPlayed: 0,
        wins: 0,
        rank: -1,
        weekStartDate: DateTime.now(),
      ),
    );
    return entry.rank;
  }

  /// Calculate level from total score
  int calculateLevel(int totalScore) {
    // Each level requires 1000 more points than the previous
    return (sqrt(totalScore / 500)).floor() + 1;
  }

  /// Get points needed for next level
  int getPointsForNextLevel(int currentLevel) {
    return (currentLevel * currentLevel * 500).round();
  }
}
