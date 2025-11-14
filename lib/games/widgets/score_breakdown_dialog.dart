/**
 * Score Breakdown Dialog
 * Shows detailed scoring breakdown after each question
 */

import 'package:flutter/material.dart';

class ScoreBreakdownDialog extends StatelessWidget {
  final bool correct;
  final int scoreEarned;
  final Map<String, dynamic> breakdown;
  final String correctAnswer;
  final String? userAnswer;
  final String? exampleSentence;

  const ScoreBreakdownDialog({
    Key? key,
    required this.correct,
    required this.scoreEarned,
    required this.breakdown,
    required this.correctAnswer,
    this.userAnswer,
    this.exampleSentence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Result Icon
            Icon(
              correct ? Icons.check_circle : Icons.cancel,
              size: 64,
              color: correct ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),
            
            // Result Text
            Text(
              correct ? 'Correct!' : 'Incorrect',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: correct ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Score Breakdown
            Card(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score Breakdown',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBreakdownRow(
                      'Accuracy Points',
                      '${breakdown['accuracyPoints']}',
                    ),
                    _buildBreakdownRow(
                      'Speed Points',
                      '${breakdown['speedPoints']}',
                    ),
                    _buildBreakdownRow(
                      'Difficulty Multiplier',
                      '×${breakdown['difficultyMultiplier'].toStringAsFixed(1)}',
                    ),
                    if (breakdown['streakBonus'] > 0)
                      _buildBreakdownRow(
                        'Streak Bonus',
                        '+${breakdown['streakBonus']}',
                        highlight: true,
                      ),
                    const Divider(height: 24),
                    _buildBreakdownRow(
                      'Total Score',
                      '$scoreEarned',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            
            // Show correct answer if wrong
            if (!correct) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Correct Answer',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        correctAnswer,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            // Show example sentence if available
            if (exampleSentence != null && exampleSentence!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.blue.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 20, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Example',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exampleSentence!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Continue Button
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, {bool isTotal = false, bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: highlight ? Colors.purple : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: highlight ? Colors.purple : (isTotal ? Colors.green : null),
            ),
          ),
        ],
      ),
    );
  }
}
