/**
 * Score Display Widgets - Feature 3.4.3
 * UI components for displaying scores with breakdowns
 */

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/scoring_service.dart';

/// Score display card with breakdown
class ScoreCard extends StatelessWidget {
  final ScoreRecord score;
  final ScoringService? scoringService;
  final bool showBreakdown;

  const ScoreCard({
    Key? key,
    required this.score,
    this.scoringService,
    this.showBreakdown = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final breakdown = scoringService?.getScoreBreakdown(score) ?? {};

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade400,
              Colors.deepPurple.shade700,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Final score - big display
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    'Score: ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${score.finalScore}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (score.validated)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.verified,
                        color: Colors.greenAccent,
                        size: 24,
                      ),
                    ),
                ],
              ),

              if (showBreakdown && breakdown.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),

                // Breakdown
                _buildBreakdownRow(
                  'Base Score',
                  score.baseScore,
                  Colors.white,
                ),
                const SizedBox(height: 8),
                _buildBreakdownRow(
                  'Time Bonus',
                  score.timeBonus,
                  Colors.amberAccent,
                ),
                const SizedBox(height: 8),
                _buildBreakdownRow(
                  'Accuracy Bonus',
                  score.accuracyBonus,
                  Colors.lightBlueAccent,
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white24),
                const SizedBox(height: 12),

                // Streak multiplier
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orangeAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Streak Multiplier: ${score.streakMultiplier.toStringAsFixed(1)}x',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Text(
          '+$value',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Compact score badge
class ScoreBadge extends StatelessWidget {
  final int score;
  final Color? backgroundColor;
  final Color? textColor;

  const ScoreBadge({
    Key? key,
    required this.score,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.deepPurple.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        score.toString(),
        style: TextStyle(
          color: textColor ?? Colors.deepPurple.shade900,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Leaderboard row widget
class LeaderboardRow extends StatelessWidget {
  final int rank;
  final String playerName;
  final int score;
  final bool isCurrentPlayer;

  const LeaderboardRow({
    Key: key,
    required this.rank,
    required this.playerName,
    required this.score,
    this.isCurrentPlayer = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentPlayer ? Colors.blue.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: _buildRankBadge(),
          ),
          const SizedBox(width: 12),

          // Player name
          Expanded(
            child: Text(
              playerName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),

          // Score
          ScoreBadge(score: score),
        ],
      ),
    );
  }

  Widget _buildRankBadge() {
    if (rank <= 3) {
      // Trophy for top 3
      final colors = [
        Colors.amber,
        Colors.grey,
        Colors.brown,
      ];
      final icons = [
        Icons.emoji_events,
        Icons.emoji_events,
        Icons.emoji_events,
      ];

      return Icon(
        icons[rank - 1],
        color: colors[rank - 1],
        size: 32,
      );
    }

    return Text(
      '$rank',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// Score animation widget
class ScoreRevealAnimation extends StatefulWidget {
  final ScoreRecord score;
  final VoidCallback? onComplete;

  const ScoreRevealAnimation({
    Key? key,
    required this.score,
    this.onComplete,
  }) : super(key: key);

  @override
  State<ScoreRevealAnimation> createState() => _ScoreRevealAnimationState();
}

class _ScoreRevealAnimationState extends State<ScoreRevealAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _scoreAnimation;
  bool _showBreakdown = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scoreAnimation = IntTween(
      begin: 0,
      end: widget.score.finalScore,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showBreakdown = true;
        });
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your Score',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _scoreAnimation.value.toString(),
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            if (_showBreakdown) ...[
              const SizedBox(height: 32),
              _buildBreakdownItem(
                'Base Score',
                widget.score.baseScore,
                Icons.stars,
              ),
              _buildBreakdownItem(
                'Time Bonus',
                widget.score.timeBonus,
                Icons.timer,
              ),
              _buildBreakdownItem(
                'Accuracy Bonus',
                widget.score.accuracyBonus,
                Icons.target,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'x${widget.score.streakMultiplier.toStringAsFixed(1)} Streak',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildBreakdownItem(String label, int value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            '+$value',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
