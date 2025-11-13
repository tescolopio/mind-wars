/**
 * Vocabulary Showdown Game Widget - Alpha Implementation
 * Test vocabulary knowledge in rapid-fire rounds
 * 
 * Category: Language
 * Players: 2-10
 */

import 'package:flutter/material.dart';
import 'dart:math';
import 'base_game_widget.dart';

class VocabularyShowdownGame extends BaseGameWidget {
  const VocabularyShowdownGame({
    Key? key,
    required OnGameComplete onGameComplete,
    required OnScoreUpdate onScoreUpdate,
  }) : super(
          key: key,
          onGameComplete: onGameComplete,
          onScoreUpdate: onScoreUpdate,
        );

  @override
  State<VocabularyShowdownGame> createState() => _VocabularyShowdownGameState();
}

class _VocabularyShowdownGameState extends BaseGameState<VocabularyShowdownGame> {
  late String _currentWord;
  late String _correctDefinition;
  late List<String> _options;
  late int _correctIndex;
  int _streak = 0;
  int _round = 1;
  final Set<String> _usedWords = {}; // Track used words to prevent repetition

  final Map<String, String> _vocabulary = {
    'BENEVOLENT': 'Kind and generous',
    'ELOQUENT': 'Fluent and persuasive in speaking',
    'METICULOUS': 'Showing great attention to detail',
    'RESILIENT': 'Able to withstand or recover quickly',
    'VERSATILE': 'Able to adapt to many different functions',
    'PRAGMATIC': 'Dealing with things sensibly and realistically',
    'AMBIGUOUS': 'Open to more than one interpretation',
    'DILIGENT': 'Having or showing care in one\'s work',
    'INNOVATIVE': 'Featuring new methods; advanced and original',
    'COHESIVE': 'Forming a united whole',
    'ABUNDANT': 'Existing or available in large quantities',
    'CYNICAL': 'Believing that people are motivated by self-interest',
    'ELABORATE': 'Involving many carefully arranged parts',
    'FUNDAMENTAL': 'Forming a necessary base or core',
    'INEVITABLE': 'Certain to happen; unavoidable',
  };

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final random = Random();
    
    // Get available words (not yet used)
    final availableWords = _vocabulary.keys.where((word) => !_usedWords.contains(word)).toList();
    
    // If all words have been used, reset the pool
    if (availableWords.isEmpty) {
      _usedWords.clear();
      availableWords.addAll(_vocabulary.keys);
    }
    
    availableWords.shuffle(random);
    
    _currentWord = availableWords[0];
    _usedWords.add(_currentWord); // Mark word as used
    _correctDefinition = _vocabulary[_currentWord]!;
    
    // Ensure unique wrong definitions and remove the correct one
    final uniqueWrongDefinitions = Set<String>.from(_vocabulary.values)
        ..remove(_correctDefinition);

    // Ensure there are enough words to generate a question
    assert(_vocabulary.length >= 4, 'Vocabulary must have at least 4 entries.');

    final wrongDefinitions = uniqueWrongDefinitions.toList()
      ..shuffle(random);

    // Take the first 3 wrong definitions
    final options = wrongDefinitions.take(3).toList();

    // Insert the correct definition at a random index
    _correctIndex = random.nextInt(4);
    options.insert(_correctIndex, _correctDefinition);
    _options = options;
    setState(() {});
  }

  void _selectAnswer(int index) {
    if (index == _correctIndex) {
      _streak++;
      final points = 15 + (_streak * 3);
      addScore(points);
      showMessage('Correct! +$points points (${_streak}x streak)', success: true);
      _round++;
      
      if (_round > 15) {
        completeGame();
      } else {
        _generateQuestion();
      }
    } else {
      _streak = 0;
      showMessage('Wrong! The correct answer was: $_correctDefinition');
      _generateQuestion();
    }
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
                      'Round $_round',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Streak: ${_streak}x',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _streak > 0 ? Colors.purple : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'What does this word mean?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _currentWord,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ...List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: FilledButton(
                  onPressed: () => _selectAnswer(index),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  child: Text(
                    _options[index],
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
