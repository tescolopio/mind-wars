/**
 * Base Game Widget
 * Abstract class that all game widgets extend
 */

import 'package:flutter/material.dart';

/// Callback for game completion
typedef OnGameComplete = void Function(int finalScore);

/// Callback for score updates
typedef OnScoreUpdate = void Function(int newScore);

/// Base class for all game widgets
abstract class BaseGameWidget extends StatefulWidget {
  final OnGameComplete onGameComplete;
  final OnScoreUpdate onScoreUpdate;

  const BaseGameWidget({
    Key? key,
    required this.onGameComplete,
    required this.onScoreUpdate,
  }) : super(key: key);
}

/// Base state class for all game widgets
abstract class BaseGameState<T extends BaseGameWidget> extends State<T> {
  int _score = 0;
  bool _gameCompleted = false;

  int get score => _score;
  bool get isCompleted => _gameCompleted;

  /// Update score and notify parent
  void updateScore(int newScore) {
    setState(() {
      _score = newScore;
    });
    widget.onScoreUpdate(_score);
  }

  /// Add to score
  void addScore(int points) {
    updateScore(_score + points);
  }

  /// Complete the game
  void completeGame() {
    if (_gameCompleted) return;
    
    setState(() {
      _gameCompleted = true;
    });
    widget.onGameComplete(_score);
  }

  /// Show a message to the user
  void showMessage(String message, {bool success = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : null,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Build the game UI
  Widget buildGame(BuildContext context);

  @override
  Widget build(BuildContext context) {
    if (_gameCompleted) {
      return buildCompletionScreen(context);
    }
    return buildGame(context);
  }

  /// Build the completion screen (can be overridden)
  Widget buildCompletionScreen(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events,
              size: 100,
              color: Colors.amber,
            ),
            const SizedBox(height: 24),
            Text(
              'Game Complete!',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Final Score: $_score',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
