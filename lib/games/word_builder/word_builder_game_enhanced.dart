/**
 * Word Builder Game Widget - Enhanced Version
 * Cascade-chain, mobile-first word building game
 */

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../widgets/base_game_widget.dart';
import 'models.dart';
import 'grid_engine.dart';
import 'tile_stream.dart';
import 'scorer.dart';
import 'dictionary_service.dart';

class WordBuilderGameEnhanced extends BaseGameWidget {
  const WordBuilderGameEnhanced({
    Key? key,
    required OnGameComplete onGameComplete,
    required OnScoreUpdate onScoreUpdate,
  }) : super(
          key: key,
          onGameComplete: onGameComplete,
          onScoreUpdate: onScoreUpdate,
        );

  @override
  State<WordBuilderGameEnhanced> createState() => _WordBuilderGameEnhancedState();
}

class _WordBuilderGameEnhancedState extends BaseGameState<WordBuilderGameEnhanced> {
  late GameSession _session;
  late GridEngine _gridEngine;
  late Scorer _scorer;
  late DictionaryService _dictionary;
  
  List<int> _selectedPath = [];
  String _currentWord = '';
  int? _previewScore;
  Set<String> _wordsFound = {};

  @override
  void initState() {
    super.initState();
    _dictionary = DictionaryService();
    _scorer = Scorer();
    _initializeGame();
  }

  void _initializeGame() {
    // Generate random seed
    final seed = DateTime.now().millisecondsSinceEpoch % 2147483647;
    
    // Create configuration (MVP: beginner difficulty)
    final config = PuzzleConfig(
      seed: seed,
      difficulty: DifficultyLevel.beginner,
      chainRuleEnabled: false,
      targetWordCount: 10,
    );

    // Initialize grid
    final initialGrid = GridEngine.initializeGrid(
      config.seed,
      config.difficulty,
    );

    // Create tile stream and engine
    final tileStream = TileStream(config.seed);
    // Consume initial grid generation from stream
    tileStream.generateInitialGrid();
    _gridEngine = GridEngine(tileStream);

    // Create session
    _session = GameSession(
      sessionId: const Uuid().v4(),
      config: config,
      currentGrid: initialGrid,
      moves: [],
      totalScore: 0,
      startTime: DateTime.now(),
    );

    _selectedPath = [];
    _currentWord = '';
    _previewScore = null;
    _wordsFound = {};
  }

  void _onTileTap(int index) {
    setState(() {
      final tile = _session.currentGrid.getTile(index);
      
      // Check if tile is locked
      if (tile.isLocked) {
        showMessage('This tile is locked', success: false);
        return;
      }

      // If already in path, ignore (can't reuse)
      if (_selectedPath.contains(index)) {
        return;
      }

      // Check adjacency if not first tile
      if (_selectedPath.isNotEmpty) {
        final lastIndex = _selectedPath.last;
        final adjacentIndices = _session.currentGrid.getAdjacentIndices(lastIndex);
        if (!adjacentIndices.contains(index)) {
          showMessage('Tiles must be adjacent', success: false);
          return;
        }
      }

      // Add to path
      _selectedPath.add(index);
      _currentWord = _selectedPath
          .map((i) => _session.currentGrid.getTile(i).letter)
          .join();

      // Calculate preview score
      if (_currentWord.length >= 3) {
        final uniqueLetters = _selectedPath
            .map((i) => _session.currentGrid.getTile(i).letter)
            .toSet();
        final hasGolden = _selectedPath.any((i) => _session.currentGrid.getTile(i).isGolden);
        final breakdown = _scorer.calculateScore(
          _currentWord,
          false, // Not checking pangram in preview
          hasGolden,
          uniqueLetters,
        );
        _previewScore = breakdown.finalScore;
      } else {
        _previewScore = null;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedPath = [];
      _currentWord = '';
      _previewScore = null;
    });
  }

  void _submitWord() {
    if (_currentWord.length < 3) {
      showMessage('Word must be at least 3 letters', success: false);
      return;
    }

    // Check if word already found
    if (_wordsFound.contains(_currentWord.toUpperCase())) {
      showMessage('Word already found', success: false);
      _clearSelection();
      return;
    }

    // Validate word in dictionary
    if (!_dictionary.isValidWord(_currentWord)) {
      showMessage('Not a valid word', success: false);
      _clearSelection();
      return;
    }

    // Submit to grid engine
    final result = _gridEngine.submitWord(
      _currentWord,
      _selectedPath,
      _session.currentGrid,
      _session.config.chainRuleEnabled,
    );

    if (!result.isValid) {
      showMessage(result.errorMessage ?? 'Invalid word', success: false);
      _clearSelection();
      return;
    }

    // Calculate score
    final hasGolden = _selectedPath.any((i) => _session.currentGrid.getTile(i).isGolden);
    final breakdown = _scorer.calculateScore(
      _currentWord,
      result.isPangram,
      hasGolden,
      result.uniqueLetters,
    );

    // Create move record
    final move = MoveRecord(
      word: _currentWord.toUpperCase(),
      pathIndices: List.from(_selectedPath),
      score: breakdown.finalScore,
      timestamp: DateTime.now(),
      isPangram: result.isPangram,
      usedGoldenTile: hasGolden,
      breakdown: breakdown,
    );

    // Update session
    setState(() {
      _session = _session.copyWith(
        currentGrid: result.newGrid!,
        moves: [..._session.moves, move],
        totalScore: _session.totalScore + breakdown.finalScore,
      );
      _wordsFound.add(_currentWord.toUpperCase());
      
      // Update parent score
      addScore(breakdown.finalScore);

      // Clear selection
      _selectedPath = [];
      _currentWord = '';
      _previewScore = null;
    });

    // Show success message
    String message = '${move.word} +${breakdown.finalScore}';
    if (result.isPangram) {
      message += ' PANGRAM! 🎉';
    }
    showMessage(message, success: true);

    // Check if target reached
    if (_session.moves.length >= _session.config.targetWordCount) {
      _completeRound();
    }
  }

  void _completeRound() {
    setState(() {
      _session = _session.copyWith(
        isComplete: true,
        endTime: DateTime.now(),
      );
    });
    completeGame();
  }

  @override
  Widget buildGame(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Progress indicator
            _buildProgressCard(context),
            const SizedBox(height: 16),
            
            // 3x3 Grid
            _buildGrid(context),
            const SizedBox(height: 16),
            
            // Current word display
            _buildCurrentWordCard(context),
            const SizedBox(height: 16),
            
            // Action buttons
            _buildActionButtons(context),
            const SizedBox(height: 16),
            
            // Words found
            if (_wordsFound.isNotEmpty) _buildWordsFound(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final progress = _session.moves.length / _session.config.targetWordCount;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Words: ${_session.moves.length}/${_session.config.targetWordCount}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Score: ${_session.totalScore}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final tile = _session.currentGrid.getTile(index);
          final isSelected = _selectedPath.contains(index);
          
          return _buildTile(context, tile, isSelected);
        },
      ),
    );
  }

  Widget _buildTile(BuildContext context, TileData tile, bool isSelected) {
    Color backgroundColor;
    Color textColor = Colors.white;
    
    if (tile.isLocked) {
      backgroundColor = Colors.grey;
    } else if (tile.isGolden) {
      backgroundColor = Colors.amber;
      textColor = Colors.black87;
    } else if (tile.isAnchor) {
      backgroundColor = Colors.brown;
    } else if (isSelected) {
      backgroundColor = Theme.of(context).colorScheme.primary;
    } else {
      backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
      textColor = Theme.of(context).colorScheme.onSecondaryContainer;
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _onTileTap(tile.index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                tile.letter,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_selectedPath.indexOf(tile.index) + 1}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: backgroundColor,
                      ),
                    ),
                  ),
                ),
              if (tile.isLocked)
                const Positioned(
                  bottom: 4,
                  child: Icon(Icons.lock, size: 16, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentWordCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _currentWord.isEmpty ? 'Tap tiles to build a word' : _currentWord,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (_previewScore != null) ...[
              const SizedBox(height: 8),
              Text(
                'Preview: $_previewScore points',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _selectedPath.isEmpty ? null : _clearSelection,
            icon: const Icon(Icons.clear),
            label: const Text('Clear'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: _currentWord.length >= 3 ? _submitWord : null,
            icon: const Icon(Icons.check),
            label: const Text('Submit Word'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWordsFound(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
        ),
      ),
    );
  }

  @override
  Widget buildCompletionScreen(BuildContext context) {
    final duration = _session.endTime!.difference(_session.startTime);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

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
              'Round Complete!',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Final Score: ${_session.totalScore}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Words Found: ${_session.moves.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Time: ${minutes}m ${seconds}s',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_session.moves.any((m) => m.isPangram)) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '🎉 PANGRAM ACHIEVED! 🎉',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
