/**
 * Word Builder Game Widget
 * Enhanced cascade-chain word building game
 * 
 * This is now a wrapper around the enhanced Word Builder implementation
 * which provides:
 * - 3×3 Cascade-chain grid (Boggle-style adjacency)
 * - Deterministic tile generation with seeded PRNG
 * - Gravity and refill mechanics
 * - Comprehensive scoring (length², rarity, patterns, pangrams)
 * - Touch-optimized mobile-first UI
 * - Special tile variants (anchor, golden, locked)
 * - Difficulty levels and chain rule enforcement
 */

import 'package:flutter/material.dart';
import 'base_game_widget.dart';
import '../word_builder/word_builder_game_enhanced.dart';

class WordBuilderGame extends BaseGameWidget {
  const WordBuilderGame({
    Key? key,
    required OnGameComplete onGameComplete,
    required OnScoreUpdate onScoreUpdate,
  }) : super(
          key: key,
          onGameComplete: onGameComplete,
          onScoreUpdate: onScoreUpdate,
        );

  @override
  State<WordBuilderGame> createState() => _WordBuilderGameState();
}

class _WordBuilderGameState extends BaseGameState<WordBuilderGame> {
  @override
  Widget buildGame(BuildContext context) {
    // Delegate to the enhanced implementation
    return WordBuilderGameEnhanced(
      onGameComplete: widget.onGameComplete,
      onScoreUpdate: widget.onScoreUpdate,
    );
  }
}
