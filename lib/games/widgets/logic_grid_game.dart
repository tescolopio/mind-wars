/**
 * Logic Grid Game Widget - Alpha Implementation
 * Simple deduction puzzle
 * 
 * Category: Logic
 * Players: 2-6
 */

import 'package:flutter/material.dart';
import 'dart:math';
import 'base_game_widget.dart';

class LogicGridGame extends BaseGameWidget {
  const LogicGridGame({
    Key? key,
    required OnGameComplete onGameComplete,
    required OnScoreUpdate onScoreUpdate,
  }) : super(
          key: key,
          onGameComplete: onGameComplete,
          onScoreUpdate: onScoreUpdate,
        );

  @override
  State<LogicGridGame> createState() => _LogicGridGameState();
}

class _LogicGridGameState extends BaseGameState<LogicGridGame> {
  late Map<String, String> _solution;
  late Map<String, String?> _userAnswers;
  late List<String> _clues;
  int _level = 1;

  final List<String> _people = ['Anna', 'Bob', 'Carol'];
  final List<String> _colors = ['Red', 'Blue', 'Green'];

  @override
  void initState() {
    super.initState();
    _generatePuzzle();
  }

  void _generatePuzzle() {
    final random = Random();
    final shuffledColors = List.from(_colors)..shuffle(random);
    
    _solution = {};
    for (var i = 0; i < _people.length; i++) {
      _solution[_people[i]] = shuffledColors[i];
    }
    
    _userAnswers = {for (var person in _people) person: null};
    
    // Generate clues
    _clues = ['Match each person with their color'];

    // Build a pool of possible clues
    List<String> possibleClues = [];
    // Positive clues: "X has Y"
    for (var person in _people) {
      possibleClues.add('$person has ${_solution[person]}');
    }
    // Negative clues: "X does not have Y" (for all incorrect color assignments)
    for (var person in _people) {
      for (var color in _colors) {
        if (_solution[person] != color) {
          possibleClues.add('$person does not have $color');
        }
      }
    }
    // Negative clues: "Y is not X's color"
    for (var color in _colors) {
      for (var person in _people) {
        if (_solution[person] != color) {
          possibleClues.add('$color is not $person\'s color');
        }
      }
    }

    // Shuffle and pick 2 random clues (in addition to the instruction)
    possibleClues.shuffle(random);
    _clues.addAll(possibleClues.take(2));
    
    setState(() {});
  }

  void _setAnswer(String person, String color) {
    setState(() {
      _userAnswers[person] = color;
    });
  }

  void _checkAnswers() {
    bool allCorrect = true;
    for (var person in _people) {
      if (_userAnswers[person] != _solution[person]) {
        allCorrect = false;
        break;
      }
    }
    
    if (allCorrect) {
      addScore(40);
      showMessage('Correct! +40 points', success: true);
      _level++;
      
      if (_level > 3) {
        completeGame();
      } else {
        _generatePuzzle();
      }
    } else {
      showMessage('Not quite right. Try again!');
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
                      'Level $_level',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Clues:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ..._clues.map((clue) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text('• $clue'),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ..._people.map((person) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _colors.map((color) {
                          final isSelected = _userAnswers[person] == color;
                          return FilterChip(
                            label: Text(color),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                _setAnswer(person, color);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _checkAnswers,
              icon: const Icon(Icons.check),
              label: const Text('Check Solution'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
