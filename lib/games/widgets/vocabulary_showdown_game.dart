/**
 * Vocabulary Showdown Game Widget - Production Implementation
 * Test vocabulary knowledge in rapid-fire rounds with adaptive difficulty
 * 
 * Category: Language
 * Players: 2-10
 * 
 * Features:
 * - Hybrid scoring (accuracy 70% / speed 30%)
 * - Adaptive difficulty targeting ~70% success rate
 * - Deterministic question generation for multiplayer fairness
 * - Streak bonuses with caps
 * - Per-question timers
 */

import 'package:flutter/material.dart';
import 'dart:math';
import 'base_game_widget.dart';
import '../../services/vocabulary_game_service.dart';
import '../../models/vocabulary_models.dart';
import '../../utils/vocabulary_scoring_utility.dart';

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
  // Use single Random instance for reproducible behavior
  final _rng = Random();
  
  late VocabularyGameService _gameService;
  late VocabularyGameSession _session;
  VocabularyQuestion? _currentQuestion;
  DateTime? _questionStartTime;
  bool _answerProcessing = false;

  @override
  void initState() {
    super.initState();
    _gameService = VocabularyGameService(random: _rng);
    _initializeSession();
  }

  void _initializeSession() {
    _session = _gameService.createSession(
      gameId: 'game_${DateTime.now().millisecondsSinceEpoch}',
      playerId: 'player_local',
      questionCount: 10, // Default 10 questions per match
    );
    _loadNextQuestion();
  }

  void _loadNextQuestion() {
    _currentQuestion = _gameService.getCurrentQuestion(_session);
    _questionStartTime = DateTime.now();
    setState(() {});
  }

  void _selectAnswer(int index) {
    if (_answerProcessing || _currentQuestion == null) return;
    
    setState(() {
      _answerProcessing = true;
    });

    // Calculate time taken
    final timeTaken = DateTime.now().difference(_questionStartTime!).inMilliseconds.toDouble();
    
    // Process answer through service
    _session = _gameService.processAnswer(
      session: _session,
      selectedOptionIndex: index,
      timeTakenMs: timeTaken,
    );

    // Get the answer that was just added
    final answer = _session.answers.last;
    final correct = answer.correct;
    
    // Update score in base game state
    updateScore(_session.totalScore);

    // Get score breakdown for feedback
    final breakdown = VocabularyScoringUtility.getScoreBreakdown(
      correct: correct,
      timeTaken: timeTaken / 1000.0,
      maxTime: _currentQuestion!.maxTime,
      difficultyTier: _currentQuestion!.difficultyTier,
      streak: _session.streak,
    );

    // Show feedback
    if (correct) {
      showMessage(
        'Correct! +${answer.scoreEarned} points (${_session.streak}x streak)',
        success: true,
      );
    } else {
      showMessage(
        'Wrong! The correct answer was: ${_currentQuestion!.options[_currentQuestion!.correctIndex]}',
      );
    }

    // Check if game is complete
    if (_session.completed) {
      // Update difficulty for next game
      _gameService.updateDifficulty();
      
      // Complete the game after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          completeGame();
        }
      });
    } else {
      // Load next question after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _answerProcessing = false;
          });
          _loadNextQuestion();
        }
      });
    }
  }

  @override
  Widget buildGame(BuildContext context) {
    if (_currentQuestion == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final question = _currentQuestion!;
    final questionNumber = _session.currentQuestionIndex + 1;
    final totalQuestions = _session.questions.length;

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
                      'Question $questionNumber of $totalQuestions',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Streak: ${_session.streak}x',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _session.streak > 0 ? Colors.purple : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Difficulty: Tier ${question.difficultyTier}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
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
                question.word.word,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ...List.generate(question.options.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: FilledButton(
                  onPressed: _answerProcessing ? null : () => _selectAnswer(index),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                    disabledBackgroundColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
                  ),
                  child: Text(
                    question.options[index],
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
