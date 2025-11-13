/**
 * Memory Match Game Widget
 * Match pairs of cards by remembering their positions
 */

import 'package:flutter/material.dart';
import 'dart:math';
import 'base_game_widget.dart';

class MemoryMatchGame extends BaseGameWidget {
  const MemoryMatchGame({
    Key? key,
    required OnGameComplete onGameComplete,
    required OnScoreUpdate onScoreUpdate,
  }) : super(
          key: key,
          onGameComplete: onGameComplete,
          onScoreUpdate: onScoreUpdate,
        );

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends BaseGameState<MemoryMatchGame> {
  late List<String> _cards;
  late List<bool> _revealed;
  late List<int> _matched;
  int? _firstCard;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    final symbols = ['🌟', '🎨', '🎭', '🎪', '🎯', '🎲', '🎸', '🎹'];
    _cards = [...symbols, ...symbols];
    _cards.shuffle(Random());
    _revealed = List.filled(_cards.length, false);
    _matched = [];
    _firstCard = null;
    _locked = false;
  }

  void _onCardTap(int index) {
    if (_locked) return;

    setState(() {
      _revealed[index] = true;

      if (_firstCard == null) {
        _firstCard = index;
      } else {
        // Check for match
        if (_cards[_firstCard!] == _cards[index]) {
          _matched.add(_firstCard!);
          _matched.add(index);
          addScore(10);
          _firstCard = null;

          // Check if game is complete
          if (_matched.length == _cards.length) {
            completeGame();
          }
        } else {
          // No match - lock cards and hide after delay
          _locked = true;
          final firstCard = _firstCard!;
          _firstCard = null;

          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              setState(() {
                _revealed[firstCard] = false;
                _revealed[index] = false;
                _locked = false;
              });
            }
          });
        }
      }
    });
  }

  @override
  Widget buildGame(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final isRevealed = _revealed[index];
          final isMatched = _matched.contains(index);

          return Card(
            elevation: isMatched ? 0 : 4,
            color: isMatched
                ? Colors.green[100]
                : (isRevealed
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary),
            child: InkWell(
              onTap: isMatched || isRevealed ? null : () => _onCardTap(index),
              child: Center(
                child: Text(
                  (isRevealed || isMatched) ? _cards[index] : '?',
                  style: TextStyle(
                    fontSize: 32,
                    color: isMatched
                        ? Colors.green[700]
                        : (isRevealed ? Colors.black : Colors.white),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
