/**
 * Color Rush Game Widget
 * Match colors under time pressure
 * 
 * Category: Attention
 * Players: 2-10
 */

import 'package:flutter/material.dart';
import 'dart:math';
import 'base_game_widget.dart';

class ColorRushGame extends BaseGameWidget {
  const ColorRushGame({
    Key? key,
    required OnGameComplete onGameComplete,
    required OnScoreUpdate onScoreUpdate,
  }) : super(
          key: key,
          onGameComplete: onGameComplete,
          onScoreUpdate: onScoreUpdate,
        );

  @override
  State<ColorRushGame> createState() => _ColorRushGameState();
}

class _ColorRushGameState extends BaseGameState<ColorRushGame> {
  late Color _targetColor;
  late List<Color> _colorGrid;
  late int _level;
  int _combo = 0;
  int _timeRemaining = 3;
  bool _timerActive = false;

  final List<Color> _baseColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _level = 1;
    _combo = 0;
    _generateRound();
  }

  void _generateRound() {
    final random = Random();
    _targetColor = _baseColors[random.nextInt(_baseColors.length)];
    
    final gridSize = 16;
    // Ensure exactly 2 instances of the target color
    final nonTargetColors = _baseColors.where((c) => c != _targetColor).toList();
    final List<Color> gridColors = [];
    gridColors.addAll(List.filled(2, _targetColor));
    for (int i = 0; i < gridSize - 2; i++) {
      gridColors.add(nonTargetColors[random.nextInt(nonTargetColors.length)]);
    }
    gridColors.shuffle(random);
    _colorGrid = gridColors;
    
    setState(() {
      _timeRemaining = 3 - (_level ~/ 5).clamp(0, 1);
      _timerActive = true;
    });
    
    _startTimer();
  }

  void _startTimer() async {
    while (_timeRemaining > 0 && _timerActive) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_timerActive) {
        break;
      }
      setState(() {
        _timeRemaining--;
      });

      if (_timeRemaining == 0) {
        _timerActive = false;
        _handleTimeout();
        break;
      }
    }
  }

  void _selectColor(Color selectedColor) {
    _timerActive = false;
    
    // Compare color values to avoid issues with different Color object constructions.
    // Assumption: selectedColor and _targetColor are from _baseColors, but this is future-proof.
    if (selectedColor.value == _targetColor.value) {
      _combo++;
      final points = 5 + (_combo * 2);
      addScore(points);
      showMessage('Correct! +$points points (${_combo}x combo)', success: true);
      _level++;
      
      if (_level > 20) {
        completeGame();
      } else {
        _generateRound();
      }
    } else {
      _combo = 0;
      showMessage('Wrong color! Combo reset');
      _generateRound();
    }
  }

  void _handleTimeout() {
    _combo = 0;
    showMessage('Time\'s up! Combo reset');
    _generateRound();
  }

  @override
  Widget buildGame(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Level $_level',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Combo: ${_combo}x',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: _combo > 0 ? Colors.orange : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Time: $_timeRemaining sec',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Find this color:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _targetColor,
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _colorGrid.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _selectColor(_colorGrid[index]),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _colorGrid[index],
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
  // - Target color to match
  // - Grid of color options (multiple colors)
  // - Time limit per round (decreases with level)
  // - Current level/round
  // - Combo counter for consecutive correct answers
  // - Speed multiplier bonus

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // TODO: Initialize color rush game
    // 1. Set initial level (determines number of colors and time)
    // 2. Generate first target color and grid
    // 3. Set initial time limit (e.g., 3 seconds for easy)
    // 4. Initialize combo counter to 0
    // 5. Start round timer
  }

  void _generateRound() {
    // TODO: Generate new color matching round
    // 1. Select target color (random or from specific set)
    // 2. Generate grid of colors (4x4 or 5x5):
    //    - Include target color 1-3 times
    //    - Fill remaining with similar colors (harder) or different colors (easier)
    // 3. Difficulty variations:
    //    - Easy: Very different colors, 3 sec limit
    //    - Medium: Similar hues, 2 sec limit
    //    - Hard: Very similar shades, 1.5 sec limit
    // 4. Consider color blindness accessibility (add patterns/symbols)
  }

  void _selectColor(Color selectedColor) {
    // TODO: Handle color selection
    // 1. Check if selected color matches target
    // 2. If correct:
    //    - Increase combo counter
    //    - Award points (base + combo bonus)
    //    - Show success animation
    //    - Generate next round
    //    - Slightly reduce time limit
    // 3. If incorrect:
    //    - Reset combo counter
    //    - Apply small penalty or no points
    //    - Show error feedback
    //    - May show correct color briefly
  }

  void _handleTimeout() {
    // TODO: Handle round timeout
    // 1. Reset combo counter
    // 2. Show correct color location(s)
    // 3. Apply time penalty to score
    // 4. After brief pause, start next round
    // 5. Consider game over after multiple consecutive timeouts
  }

  @override
  Widget buildGame(BuildContext context) {
    // TODO: Build color rush game UI
    // 1. Display target color prominently at top:
    //    - Large color swatch
    //    - Optional color name (for accessibility)
    // 2. Show color grid (tappable color squares):
    //    - Clear separation between colors
    //    - Large enough for easy tapping (min 48dp)
    //    - Responsive to screen size
    // 3. Display timer:
    //    - Countdown bar or circular timer
    //    - Visual urgency (red when low)
    // 4. Show game statistics:
    //    - Current combo (with multiplier)
    //    - Level/round number
    //    - Score with combo bonus
    // 5. Add visual feedback:
    //    - Pulse animation for target color
    //    - Flash correct color on selection
    //    - Shake animation for incorrect selection
    // 6. Consider accessibility:
    //    - Add patterns/symbols to colors
    //    - Provide color name hints option
    //    - High contrast mode
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.palette, size: 80, color: Colors.pink),
            const SizedBox(height: 24),
            Text(
              'Color Rush',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'Coming Soon!',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            const Text(
              'TODO: Implement color matching game',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // TODO: Helper methods to implement
  // - _colorsMatch(color1, color2): Compare colors with tolerance
  // - _generateSimilarColor(base): Create similar but distinct color
  // - _getColorName(color): Get human-readable color name
  // - _calculateComboBonus(): Compute bonus based on combo
  // - _getTimeLimit(): Get time limit for current level
  // - _getGridSize(): Get grid dimensions for current level
  // - _addColorPattern(color): Add pattern/symbol for accessibility
  // - _showColorAnimation(position): Animate color selection
}
