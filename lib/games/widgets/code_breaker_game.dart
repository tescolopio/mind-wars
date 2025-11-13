/**
 * Code Breaker Game Widget
 * Deduce secret codes using logical reasoning
 */

import 'package:flutter/material.dart';
import 'dart:math';
import 'base_game_widget.dart';

class CodeBreakerGame extends BaseGameWidget {
  const CodeBreakerGame({
    Key? key,
    required OnGameComplete onGameComplete,
    required OnScoreUpdate onScoreUpdate,
  }) : super(
          key: key,
          onGameComplete: onGameComplete,
          onScoreUpdate: onScoreUpdate,
        );

  @override
  State<CodeBreakerGame> createState() => _CodeBreakerGameState();
}

class _CodeBreakerGameState extends BaseGameState<CodeBreakerGame> {
  late List<int> _secretCode;
  late List<List<int>> _guesses;
  late List<Map<String, int>> _feedback;
  final int _codeLength = 4;
  List<int> _currentGuess = [];

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _secretCode = List.generate(_codeLength, (_) => Random().nextInt(6) + 1);
    _guesses = [];
    _feedback = [];
    _currentGuess = [];
  }

  void _addDigit(int digit) {
    if (_currentGuess.length < _codeLength) {
      setState(() {
        _currentGuess.add(digit);
      });

      if (_currentGuess.length == _codeLength) {
        _checkCode();
      }
    }
  }

  void _checkCode() {
    final correct = _currentGuess
        .asMap()
        .entries
        .where((e) => e.value == _secretCode[e.key])
        .length;

    if (correct == _codeLength) {
      setState(() {
        _guesses.add(List.from(_currentGuess));
        _feedback.add({'correct': correct, 'wrongPosition': 0});
      });
      addScore(50);
      showMessage('Code cracked! +50 points', success: true);
      completeGame();
      return;
    }

    // Calculate wrong position
    final codeDigitCounts = <int, int>{};
    final guessDigitCounts = <int, int>{};

    for (var i = 0; i < _codeLength; i++) {
      if (_currentGuess[i] != _secretCode[i]) {
        codeDigitCounts[_secretCode[i]] =
            (codeDigitCounts[_secretCode[i]] ?? 0) + 1;
        guessDigitCounts[_currentGuess[i]] =
            (guessDigitCounts[_currentGuess[i]] ?? 0) + 1;
      }
    }

    var wrongPosition = 0;
    for (var digit in guessDigitCounts.keys) {
      wrongPosition +=
          min(guessDigitCounts[digit]!, codeDigitCounts[digit] ?? 0);
    }

    setState(() {
      _guesses.add(List.from(_currentGuess));
      _feedback.add({'correct': correct, 'wrongPosition': wrongPosition});
      _currentGuess = [];
    });

    showMessage('$correct correct, $wrongPosition wrong position');
  }

  @override
  Widget buildGame(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Break the Code!',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Guess the $_codeLength-digit code (1-6)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        Text(' = Correct position   '),
                        Icon(Icons.circle, color: Colors.amber, size: 16),
                        Text(' = Wrong position'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Previous guesses
            if (_guesses.isNotEmpty) ...[
              Text(
                'Previous Guesses',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ..._guesses.asMap().entries.map((entry) {
                final idx = entry.key;
                final guess = entry.value;
                final feedback = _feedback[idx];

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: guess
                              .map((digit) => Container(
                                    width: 48,
                                    height: 48,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        digit.toString(),
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        Row(
                          children: [
                            ...List.generate(
                              feedback['correct']!,
                              (_) => const Icon(Icons.check_circle,
                                  color: Colors.green, size: 24),
                            ),
                            ...List.generate(
                              feedback['wrongPosition']!,
                              (_) => const Icon(Icons.circle,
                                  color: Colors.amber, size: 24),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
            // Current guess display
            if (_currentGuess.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Current Guess',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ..._currentGuess
                              .map((digit) => Container(
                                    width: 48,
                                    height: 48,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        digit.toString(),
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onTertiary,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                          ...List.generate(
                            _codeLength - _currentGuess.length,
                            (_) => Container(
                              width: 48,
                              height: 48,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '?',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentGuess = [];
                  });
                },
                icon: const Icon(Icons.backspace),
                label: const Text('Clear'),
              ),
              const SizedBox(height: 16),
            ],
            // Number pad for input
            Text(
              'Make Your Guess',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: () => _addDigit(index + 1),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    (index + 1).toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
