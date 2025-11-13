/**
 * Word Builder Game Widget
 * Create words from letter tiles competitively
 */

import 'package:flutter/material.dart';
import 'dart:math';
import 'base_game_widget.dart';

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
  late List<String> _letters;
  String _currentWord = '';
  late Set<String> _wordsFound;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeGame() {
    final consonants = [
      'B',
      'C',
      'D',
      'F',
      'G',
      'H',
      'L',
      'M',
      'N',
      'P',
      'R',
      'S',
      'T'
    ];
    final vowels = ['A', 'E', 'I', 'O', 'U'];

    _letters = [];
    for (var i = 0; i < 5; i++) {
      _letters.add(consonants[Random().nextInt(consonants.length)]);
    }
    for (var i = 0; i < 4; i++) {
      _letters.add(vowels[Random().nextInt(vowels.length)]);
    }
    _letters.shuffle(Random());
    _currentWord = '';
    _wordsFound = {};
  }

  void _submitWord() {
    if (_currentWord.length < 3) {
      showMessage('Word must be at least 3 letters');
      return;
    }

    // Check if letters are available
    final lettersUsed = <String>[];
    for (var i = 0; i < _currentWord.length; i++) {
      lettersUsed.add(_currentWord[i]);
    }

    final availableLetters = List<String>.from(_letters);
    for (var letter in lettersUsed) {
      if (!availableLetters.remove(letter)) {
        showMessage('Letter $letter not available');
        return;
      }
    }

    if (_wordsFound.contains(_currentWord)) {
      showMessage('Word already found');
      return;
    }

    // Simple validation - in production, check against dictionary
    final wordLength = _currentWord.length;
    setState(() {
      _wordsFound.add(_currentWord);
      _currentWord = '';
      _controller.clear();
    });
    addScore(wordLength * 2);

    showMessage('Word accepted! +${wordLength * 2} points', success: true);
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
                      'Build words from these letters:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _letters.map((letter) {
                        return Chip(
                          label: Text(
                            letter,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Your Word',
                        hintText: 'Type a word...',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (value) {
                        setState(() {
                          _currentWord = value.toUpperCase();
                        });
                      },
                      onSubmitted: (value) => _submitWord(),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _currentWord.isEmpty ? null : _submitWord,
                      icon: const Icon(Icons.check),
                      label: const Text('Submit Word'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_wordsFound.isNotEmpty) ...[
              Text(
                'Words Found (${_wordsFound.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _wordsFound.map((word) {
                  return Chip(
                    label: Text(word),
                    backgroundColor: Colors.green[100],
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
