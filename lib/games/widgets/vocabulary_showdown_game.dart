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
 * - Per-question timers with visual countdown
 * - Multiple question types (MCQ, fill-in-blank, synonym/antonym)
 * - Detailed score breakdown display
 * - Example sentences for learning
 */

import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'base_game_widget.dart';
import '../../services/vocabulary_game_service.dart';
import '../../models/vocabulary_models.dart';
import '../../utils/vocabulary_scoring_utility.dart';
import 'question_timer.dart';
import 'score_breakdown_dialog.dart';

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
  bool _timerPaused = false;
  
  // For fill-in-blank questions
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _gameService = VocabularyGameService(random: _rng);
    _initializeSession();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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
    _answerProcessing = false;
    _timerPaused = false;
    _textController.clear();
    setState(() {});
  }

  void _onTimeUp() {
    if (!_answerProcessing) {
      // Auto-submit with wrong answer when time runs out
      if (_currentQuestion?.type == QuestionType.fillInBlank) {
        _submitFillInBlank();
      } else {
        _selectAnswer(-1); // Invalid index = wrong answer
      }
    }
  }

  void _selectAnswer(int index) {
    if (_answerProcessing || _currentQuestion == null) return;
    
    setState(() {
      _answerProcessing = true;
      _timerPaused = true;
    });

    _processAnswer(selectedOptionIndex: index);
  }

  void _submitFillInBlank() {
    if (_answerProcessing || _currentQuestion == null) return;
    
    setState(() {
      _answerProcessing = true;
      _timerPaused = true;
    });

    _processAnswer(textAnswer: _textController.text.trim());
  }

  void _processAnswer({int? selectedOptionIndex, String? textAnswer}) async {
    // Calculate time taken
    final timeTaken = DateTime.now().difference(_questionStartTime!).inMilliseconds.toDouble();
    
    // Process answer through service
    _session = _gameService.processAnswer(
      session: _session,
      selectedOptionIndex: selectedOptionIndex,
      textAnswer: textAnswer,
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

    // Get correct answer text
    String correctAnswerText;
    if (_currentQuestion!.type == QuestionType.fillInBlank) {
      correctAnswerText = _currentQuestion!.word.word;
    } else {
      correctAnswerText = _currentQuestion!.options[_currentQuestion!.correctIndex];
    }

    // Show score breakdown dialog
    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ScoreBreakdownDialog(
          correct: correct,
          scoreEarned: answer.scoreEarned,
          breakdown: breakdown,
          correctAnswer: correctAnswerText,
          userAnswer: textAnswer ?? (selectedOptionIndex != null && selectedOptionIndex >= 0 
              ? _currentQuestion!.options[selectedOptionIndex] 
              : null),
          exampleSentence: !correct ? _currentQuestion!.word.example : null,
        ),
      );
    }

    // Check if game is complete
    if (_session.completed) {
      // Update difficulty for next game
      _gameService.updateDifficulty();
      
      // Complete the game
      if (mounted) {
        completeGame();
      }
    } else {
      // Load next question
      if (mounted) {
        _loadNextQuestion();
      }
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
            // Header Card
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
            const SizedBox(height: 16),
            
            // Timer
            QuestionTimer(
              maxTime: question.maxTime,
              onTimeUp: _onTimeUp,
              isPaused: _timerPaused,
            ),
            const SizedBox(height: 24),
            
            // Question prompt based on type
            Text(
              _getQuestionPrompt(question.type),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Word display
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
            
            // Question type specific UI
            if (question.type == QuestionType.multipleChoice)
              _buildMultipleChoiceOptions(question)
            else if (question.type == QuestionType.fillInBlank)
              _buildFillInBlankInput()
            else if (question.type == QuestionType.synonymAntonym)
              _buildSynonymAntonymOptions(question),
          ],
        ),
      ),
    );
  }

  String _getQuestionPrompt(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'What does this word mean?';
      case QuestionType.fillInBlank:
        return 'Type the word that matches this definition:';
      case QuestionType.synonymAntonym:
        return 'Which word is a synonym?';
    }
  }

  Widget _buildMultipleChoiceOptions(VocabularyQuestion question) {
    return Column(
      children: List.generate(question.options.length, (index) {
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
    );
  }

  Widget _buildFillInBlankInput() {
    return Column(
      children: [
        TextField(
          controller: _textController,
          enabled: !_answerProcessing,
          decoration: InputDecoration(
            hintText: 'Type your answer here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.characters,
          onSubmitted: (_) => _submitFillInBlank(),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _answerProcessing ? null : _submitFillInBlank,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 60),
          ),
          child: const Text(
            'Submit Answer',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildSynonymAntonymOptions(VocabularyQuestion question) {
    return Column(
      children: List.generate(question.options.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: FilledButton(
            onPressed: _answerProcessing ? null : () => _selectAnswer(index),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 60),
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
              disabledBackgroundColor: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.5),
            ),
            child: Text(
              question.options[index],
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }),
    );
  }
}
