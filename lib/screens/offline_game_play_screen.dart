/**
 * Offline Game Play Screen
 * Allows alpha testers to play games in offline/practice mode
 */

import 'package:flutter/material.dart';
import 'dart:math';
import '../games/game_catalog.dart';

class OfflineGamePlayScreen extends StatefulWidget {
  final GameTemplate gameTemplate;

  const OfflineGamePlayScreen({
    Key? key,
    required this.gameTemplate,
  }) : super(key: key);

  @override
  State<OfflineGamePlayScreen> createState() => _OfflineGamePlayScreenState();
}

class _OfflineGamePlayScreenState extends State<OfflineGamePlayScreen> {
  late DateTime _startTime;
  int _score = 0;
  int _hintsUsed = 0;
  bool _gameCompleted = false;
  bool _gameStarted = false;
  int _countdown = 0;
  
  // Memory Match game state
  List<String>? _memoryCards;
  List<bool>? _memoryRevealed;
  List<int>? _memoryMatched;
  int? _memoryFirstCard;
  bool _memoryLocked = false;
  
  // Word Builder game state
  List<String>? _wordLetters;
  String? _wordBuilt;
  Set<String>? _wordsFound;
  final TextEditingController _wordBuilderController = TextEditingController();
  
  // Sequence Recall game state
  List<int>? _sequence;
  List<int>? _userSequence;
  bool? _sequenceShowing;
  int? _sequenceLevel;
  int? _currentFlashingButton;
  
  // Anagram Attack game state
  String? _targetWord;
  String? _scrambledWord;
  String? _userAnswer;
  int? _anagramLevel;
  List<String>? _anagramWords;
  final TextEditingController _anagramController = TextEditingController();
  
  // Code Breaker game state
  List<int>? _secretCode;
  List<List<int>>? _guesses;
  List<Map<String, int>>? _feedback; // correct position and correct number
  int? _codeLength;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initializeGame();
  }

  @override
  void dispose() {
    _wordBuilderController.dispose();
    _anagramController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    switch (widget.gameTemplate.id) {
      case 'memory_match':
        _initializeMemoryMatch();
        break;
      case 'word_builder':
        _initializeWordBuilder();
        break;
      case 'sequence_recall':
        _initializeSequenceRecall();
        break;
      case 'anagram_attack':
        _initializeAnagramAttack();
        break;
      case 'code_breaker':
        _initializeCodeBreaker();
        break;
      default:
        // Generic initialization for other games
        break;
    }
  }

  void _initializeMemoryMatch() {
    final symbols = ['🌟', '🎨', '🎭', '🎪', '🎯', '🎲', '🎸', '🎹'];
    _memoryCards = [...symbols, ...symbols];
    _memoryCards!.shuffle(Random());
    _memoryRevealed = List.filled(_memoryCards!.length, false);
    _memoryMatched = [];
    _memoryFirstCard = null;
  }

  void _initializeWordBuilder() {
    final consonants = ['B', 'C', 'D', 'F', 'G', 'H', 'L', 'M', 'N', 'P', 'R', 'S', 'T'];
    final vowels = ['A', 'E', 'I', 'O', 'U'];
    
    _wordLetters = [];
    for (var i = 0; i < 5; i++) {
      _wordLetters!.add(consonants[Random().nextInt(consonants.length)]);
    }
    for (var i = 0; i < 4; i++) {
      _wordLetters!.add(vowels[Random().nextInt(vowels.length)]);
    }
    _wordLetters!.shuffle(Random());
    _wordBuilt = '';
    _wordsFound = {};
  }

  void _initializeSequenceRecall() {
    _sequenceLevel = 1;
    _sequence = [];
    _userSequence = [];
    _sequenceShowing = false;
    _currentFlashingButton = null;
    _generateSequence();
  }

  void _generateSequence() {
    _sequence = List.generate(
      3 + _sequenceLevel!,
      (index) => Random().nextInt(4),
    );
    _userSequence = [];
  }

  void _initializeAnagramAttack() {
    _anagramLevel = 1;
    _anagramWords = [
      'LISTEN', 'SILENT', 'GARDEN', 'DANGER', 'MASTER', 'STREAM',
      'CREATION', 'REACTION', 'TRIANGLE', 'INTEGRAL', 'HEART', 'EARTH',
      'BELOW', 'ELBOW', 'ANGLE', 'ANGEL', 'NIGHT', 'THING',
    ];
    _nextAnagram();
  }

  void _nextAnagram() {
    if (_anagramWords!.isEmpty) {
      _completeGame();
      return;
    }
    
    _targetWord = _anagramWords!.removeAt(Random().nextInt(_anagramWords!.length));
    _scrambledWord = _scrambleWord(_targetWord!);
    _userAnswer = '';
    _anagramController.clear();
  }

  String _scrambleWord(String word) {
    final chars = word.split('');
    var attempts = 0;
    do {
      chars.shuffle(Random());
      attempts++;
    } while (chars.join() == word && attempts < 10 && word.length > 1);
    
    // Final check - if still not scrambled, manually swap
    if (chars.join() == word && word.length > 1) {
      final temp = chars[0];
      chars[0] = chars[1];
      chars[1] = temp;
    }
    return chars.join();
  }

  void _initializeCodeBreaker() {
    _codeLength = 4;
    _secretCode = List.generate(_codeLength!, (_) => Random().nextInt(6) + 1);
    _guesses = [];
    _feedback = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameTemplate.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: _showHint,
            tooltip: 'Get Hint',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showRules,
            tooltip: 'Game Rules',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Score Header
            _buildScoreHeader(context),
            
            const Divider(height: 1),
            
            // Game Content
            Expanded(
              child: _buildGameContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreHeader(BuildContext context) {
    final elapsed = DateTime.now().difference(_startTime);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            Icons.timer,
            'Time',
            '$minutes:${seconds.toString().padLeft(2, '0')}',
          ),
          _buildStatItem(
            context,
            Icons.stars,
            'Score',
            _score.toString(),
          ),
          _buildStatItem(
            context,
            Icons.lightbulb,
            'Hints',
            _hintsUsed.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildGameContent(BuildContext context) {
    if (_gameCompleted) {
      return _buildCompletionScreen(context);
    }

    if (!_gameStarted) {
      return _buildStartScreen(context);
    }

    if (_countdown > 0) {
      return _buildCountdownScreen(context);
    }

    switch (widget.gameTemplate.id) {
      case 'memory_match':
        return _buildMemoryMatchGame(context);
      case 'word_builder':
        return _buildWordBuilderGame(context);
      case 'sequence_recall':
        return _buildSequenceRecallGame(context);
      case 'anagram_attack':
        return _buildAnagramAttackGame(context);
      case 'code_breaker':
        return _buildCodeBreakerGame(context);
      default:
        return _buildGenericGame(context);
    }
  }

  Widget _buildStartScreen(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.gameTemplate.icon,
              style: const TextStyle(fontSize: 100),
            ),
            const SizedBox(height: 32),
            Text(
              widget.gameTemplate.name,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              widget.gameTemplate.description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.gameTemplate.rules,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.play_arrow, size: 32),
              label: const Text('START GAME', style: TextStyle(fontSize: 20)),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Get Ready!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 48),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _countdown.toString(),
                style: TextStyle(
                  fontSize: 120,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _countdown = 3;
    });

    _runCountdown();
  }

  void _runCountdown() async {
    for (int i = 3; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _countdown = i - 1;
        });
      }
    }
    
    // After countdown, start sequence recall if it's that game
    if (mounted && widget.gameTemplate.id == 'sequence_recall') {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _showSequence();
      }
    }
  }

  Widget _buildMemoryMatchGame(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _memoryCards!.length,
        itemBuilder: (context, index) {
          final isRevealed = _memoryRevealed![index];
          final isMatched = _memoryMatched!.contains(index);
          
          return Card(
            elevation: isMatched ? 0 : 4,
            color: isMatched 
                ? Colors.green[100]
                : (isRevealed ? Colors.white : Theme.of(context).colorScheme.primary),
            child: InkWell(
              onTap: isMatched || isRevealed ? null : () => _onMemoryCardTap(index),
              child: Center(
                child: Text(
                  (isRevealed || isMatched) ? _memoryCards![index] : '?',
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

  void _onMemoryCardTap(int index) {
    if (_memoryLocked) return;
    
    setState(() {
      _memoryRevealed![index] = true;
      
      if (_memoryFirstCard == null) {
        _memoryFirstCard = index;
      } else {
        // Check for match
        if (_memoryCards![_memoryFirstCard!] == _memoryCards![index]) {
          _memoryMatched!.add(_memoryFirstCard!);
          _memoryMatched!.add(index);
          _score += 10;
          _memoryFirstCard = null;
          
          // Check if game is complete
          if (_memoryMatched!.length == _memoryCards!.length) {
            _completeGame();
          }
        } else {
          // No match - lock cards and hide after delay
          _memoryLocked = true;
          final firstCard = _memoryFirstCard!;
          _memoryFirstCard = null;
          
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              setState(() {
                _memoryRevealed![firstCard] = false;
                _memoryRevealed![index] = false;
                _memoryLocked = false;
              });
            }
          });
        }
      }
    });
  }

  Widget _buildWordBuilderGame(BuildContext context) {
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
                      children: _wordLetters!.map((letter) {
                        return Chip(
                          label: Text(
                            letter,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
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
                      controller: _wordBuilderController,
                      decoration: const InputDecoration(
                        labelText: 'Your Word',
                        hintText: 'Type a word...',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (value) {
                        setState(() {
                          _wordBuilt = value.toUpperCase();
                        });
                      },
                      onSubmitted: (value) => _submitWord(),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _wordBuilt!.isEmpty ? null : _submitWord,
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
            if (_wordsFound!.isNotEmpty) ...[
              Text(
                'Words Found (${_wordsFound!.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _wordsFound!.map((word) {
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

  void _submitWord() {
    if (_wordBuilt!.length < 3) {
      _showMessage('Word must be at least 3 letters');
      return;
    }

    // Check if letters are available
    final lettersUsed = <String>[];
    for (var i = 0; i < _wordBuilt!.length; i++) {
      lettersUsed.add(_wordBuilt![i]);
    }

    final availableLetters = List<String>.from(_wordLetters!);
    for (var letter in lettersUsed) {
      if (!availableLetters.remove(letter)) {
        _showMessage('Letter $letter not available');
        return;
      }
    }

    if (_wordsFound!.contains(_wordBuilt)) {
      _showMessage('Word already found');
      return;
    }

    // Simple validation - in production, check against dictionary
    final wordLength = _wordBuilt!.length;
    setState(() {
      _wordsFound!.add(_wordBuilt!);
      _score += wordLength * 2;
      _wordBuilt = '';
      _wordBuilderController.clear();
    });

    _showMessage('Word accepted! +${wordLength * 2} points', success: true);
  }

  Widget _buildSequenceRecallGame(BuildContext context) {
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
                    'Level $_sequenceLevel',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _sequenceShowing!
                        ? 'Watch the sequence...'
                        : 'Repeat the sequence',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                final colors = [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.yellow,
                ];
                
                final isFlashing = _currentFlashingButton == index;
                
                return Card(
                  color: colors[index],
                  elevation: isFlashing ? 12 : 4,
                  child: InkWell(
                    onTap: _sequenceShowing! ? null : () => _onSequenceButtonTap(index),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: isFlashing 
                            ? Border.all(color: Colors.white, width: 4)
                            : null,
                        boxShadow: isFlashing
                            ? [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          (index + 1).toString(),
                          style: TextStyle(
                            fontSize: isFlashing ? 56 : 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (!_sequenceShowing!)
            FilledButton.icon(
              onPressed: _showSequence,
              icon: const Icon(Icons.visibility),
              label: const Text('Show Sequence Again'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
        ],
      ),
    );
  }

  void _showSequence() async {
    setState(() {
      _sequenceShowing = true;
      _userSequence = [];
      _currentFlashingButton = null;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    for (var i = 0; i < _sequence!.length; i++) {
      if (!mounted) return;
      
      setState(() {
        _currentFlashingButton = _sequence![i];
      });
      
      await Future.delayed(const Duration(milliseconds: 600));
      
      if (!mounted) return;
      
      setState(() {
        _currentFlashingButton = null;
      });
      
      await Future.delayed(const Duration(milliseconds: 300));
    }

    await Future.delayed(const Duration(milliseconds: 200));
    
    if (mounted) {
      setState(() {
        _sequenceShowing = false;
      });
    }
  }

  void _onSequenceButtonTap(int index) {
    setState(() {
      _userSequence!.add(index);
      
      // Check if correct so far
      if (_userSequence!.length <= _sequence!.length) {
        if (_userSequence![_userSequence!.length - 1] != 
            _sequence![_userSequence!.length - 1]) {
          // Wrong!
          _showMessage('Wrong sequence! Try again');
          _userSequence = [];
          return;
        }
        
        // Check if complete
        if (_userSequence!.length == _sequence!.length) {
          _score += 10 * _sequenceLevel!;
          _sequenceLevel = _sequenceLevel! + 1;
          _showMessage('Correct! Moving to level $_sequenceLevel', success: true);
          _generateSequence();
          _showSequence();
        }
      }
    });
  }

  Widget _buildAnagramAttackGame(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Unscramble This Word',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _scrambledWord ?? '',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_targetWord!.length} letters',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _anagramController,
                      decoration: InputDecoration(
                        labelText: 'Your Answer',
                        hintText: 'Type the unscrambled word...',
                        border: const OutlineInputBorder(),
                        helperText: 'Enter ${_targetWord!.length} letters',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (value) {
                        setState(() {
                          _userAnswer = value.toUpperCase();
                        });
                      },
                      onSubmitted: (value) => _checkAnagram(),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _userAnswer!.isEmpty ? null : _checkAnagram,
                      icon: const Icon(Icons.check),
                      label: const Text('Submit Answer'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Words remaining: ${_anagramWords!.length}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkAnagram() {
    final cleanUserAnswer = _userAnswer!.trim().toUpperCase();
    final cleanTargetWord = _targetWord!.trim().toUpperCase();
    
    if (cleanUserAnswer.length != cleanTargetWord.length) {
      _showMessage('Your answer has ${cleanUserAnswer.length} letters, but the word has ${cleanTargetWord.length} letters');
      return;
    }
    
    if (cleanUserAnswer == cleanTargetWord) {
      setState(() {
        _score += 15;
        _anagramLevel = _anagramLevel! + 1;
      });
      _showMessage('Correct! +15 points', success: true);
      
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _nextAnagram();
          });
        }
      });
    } else {
      _showMessage('Try again! The word is ${cleanTargetWord.length} letters long');
    }
  }

  Widget _buildCodeBreakerGame(BuildContext context) {
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
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const Text(' = Correct position   '),
                        const Icon(Icons.circle, color: Colors.amber, size: 16),
                        const Text(' = Wrong position'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Previous guesses
            if (_guesses!.isNotEmpty) ...[
              Text(
                'Previous Guesses',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ..._guesses!.asMap().entries.map((entry) {
                final idx = entry.key;
                final guess = entry.value;
                final feedback = _feedback![idx];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: guess.map((digit) => Container(
                            width: 48,
                            height: 48,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                digit.toString(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          )).toList(),
                        ),
                        Row(
                          children: [
                            ...List.generate(
                              feedback['correct']!,
                              (_) => const Icon(Icons.check_circle, color: Colors.green, size: 24),
                            ),
                            ...List.generate(
                              feedback['wrongPosition']!,
                              (_) => const Icon(Icons.circle, color: Colors.amber, size: 24),
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
            if (_currentCodeGuess.isNotEmpty) ...[
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
                          ..._currentCodeGuess.map((digit) => Container(
                            width: 48,
                            height: 48,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                digit.toString(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onTertiary,
                                ),
                              ),
                            ),
                          )).toList(),
                          ...List.generate(
                            _codeLength! - _currentCodeGuess.length,
                            (_) => Container(
                              width: 48,
                              height: 48,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
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
                    _currentCodeGuess = [];
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
                  onPressed: () => _addCodeDigit(index + 1),
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

  List<int> _currentCodeGuess = [];

  void _addCodeDigit(int digit) {
    if (_currentCodeGuess.length < _codeLength!) {
      setState(() {
        _currentCodeGuess.add(digit);
      });

      if (_currentCodeGuess.length == _codeLength!) {
        _checkCode();
      }
    }
  }

  void _checkCode() {
    final correct = _currentCodeGuess
        .asMap()
        .entries
        .where((e) => e.value == _secretCode![e.key])
        .length;

    if (correct == _codeLength!) {
      setState(() {
        _score += 50;
        _guesses!.add(List.from(_currentCodeGuess));
        _feedback!.add({'correct': correct, 'wrongPosition': 0});
      });
      _showMessage('Code cracked! +50 points', success: true);
      _completeGame();
      return;
    }

    // Calculate wrong position
    final codeDigitCounts = <int, int>{};
    final guessDigitCounts = <int, int>{};
    
    for (var i = 0; i < _codeLength!; i++) {
      if (_currentCodeGuess[i] != _secretCode![i]) {
        codeDigitCounts[_secretCode![i]] = (codeDigitCounts[_secretCode![i]] ?? 0) + 1;
        guessDigitCounts[_currentCodeGuess[i]] = (guessDigitCounts[_currentCodeGuess[i]] ?? 0) + 1;
      }
    }

    var wrongPosition = 0;
    for (var digit in guessDigitCounts.keys) {
      wrongPosition += min(guessDigitCounts[digit]!, codeDigitCounts[digit] ?? 0);
    }

    setState(() {
      _guesses!.add(List.from(_currentCodeGuess));
      _feedback!.add({'correct': correct, 'wrongPosition': wrongPosition});
      _currentCodeGuess = [];
    });

    _showMessage('$correct correct, $wrongPosition wrong position');
  }

  Widget _buildGenericGame(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.gameTemplate.icon,
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 24),
            Text(
              widget.gameTemplate.name,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'This game is coming soon!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try these playable games: Memory Match, Word Builder, Sequence Recall, Anagram Attack, or Code Breaker.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Game Selection'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionScreen(BuildContext context) {
    final elapsed = DateTime.now().difference(_startTime);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;

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
              'Congratulations!',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'You completed ${widget.gameTemplate.name}',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildResultRow(context, 'Final Score', _score.toString()),
                    const Divider(height: 24),
                    _buildResultRow(
                      context,
                      'Time',
                      '$minutes:${seconds.toString().padLeft(2, '0')}',
                    ),
                    const Divider(height: 24),
                    _buildResultRow(context, 'Hints Used', _hintsUsed.toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.replay),
              label: const Text('Play Again'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Games'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }

  void _completeGame() {
    setState(() {
      _gameCompleted = true;
    });
  }

  void _showHint() {
    setState(() {
      _hintsUsed++;
      _score = max(0, _score - 5); // Penalty for using hint
    });

    String hintText = 'Hint: ';
    switch (widget.gameTemplate.id) {
      case 'memory_match':
        hintText += 'Try to remember the positions of matching pairs!';
        break;
      case 'word_builder':
        hintText += 'Look for common word patterns like -ING, -ED, or -ER';
        break;
      case 'sequence_recall':
        hintText += 'Break the sequence into smaller chunks to remember it better';
        break;
      case 'anagram_attack':
        hintText += 'Try rearranging common letter combinations like TH, ER, or ING';
        break;
      case 'code_breaker':
        hintText += 'Use the feedback from previous guesses to narrow down possibilities';
        break;
      default:
        hintText += 'Take your time and think carefully about each move';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.lightbulb, size: 48, color: Colors.amber),
        title: const Text('Hint'),
        content: Text(hintText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showRules() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.gameTemplate.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(widget.gameTemplate.description),
              const SizedBox(height: 16),
              Text(
                'How to Play',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(widget.gameTemplate.rules),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : null,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
