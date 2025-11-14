/**
 * Vocabulary Game Service
 * Manages game logic, question pool, scoring, and state
 * Keeps UI thin and testable
 */

import 'dart:math';
import '../models/vocabulary_models.dart';
import '../utils/vocabulary_scoring_utility.dart';
import '../utils/vocabulary_game_utilities.dart';

class VocabularyGameService {
  final Random _rng;
  final Map<String, VocabularyWord> _wordPool;
  final Set<String> _usedWordIds = {};
  
  // Adaptive difficulty tracking
  final List<bool> _recentResults = [];
  static const int _rollingWindowSize = 10;
  int _currentDifficulty = 5; // Start at medium difficulty

  VocabularyGameService({
    Random? random,
    Map<String, VocabularyWord>? wordPool,
  })  : _rng = random ?? Random(),
        _wordPool = wordPool ?? _getDefaultWordPool();

  /// Get default word pool (static vocabulary for alpha)
  static Map<String, VocabularyWord> _getDefaultWordPool() {
    final words = <String, VocabularyWord>{};
    
    final staticWords = {
      'BENEVOLENT': {'def': 'Kind and generous', 'diff': 3},
      'ELOQUENT': {'def': 'Fluent and persuasive in speaking', 'diff': 3},
      'METICULOUS': {'def': 'Showing great attention to detail', 'diff': 4},
      'RESILIENT': {'def': 'Able to withstand or recover quickly', 'diff': 3},
      'VERSATILE': {'def': 'Able to adapt to many different functions', 'diff': 3},
      'PRAGMATIC': {'def': 'Dealing with things sensibly and realistically', 'diff': 4},
      'AMBIGUOUS': {'def': 'Open to more than one interpretation', 'diff': 4},
      'DILIGENT': {'def': 'Having or showing care in one\'s work', 'diff': 2},
      'INNOVATIVE': {'def': 'Featuring new methods; advanced and original', 'diff': 3},
      'COHESIVE': {'def': 'Forming a united whole', 'diff': 4},
      'ABUNDANT': {'def': 'Existing or available in large quantities', 'diff': 2},
      'CYNICAL': {'def': 'Believing that people are motivated by self-interest', 'diff': 3},
      'ELABORATE': {'def': 'Involving many carefully arranged parts', 'diff': 3},
      'FUNDAMENTAL': {'def': 'Forming a necessary base or core', 'diff': 2},
      'INEVITABLE': {'def': 'Certain to happen; unavoidable', 'diff': 3},
    };

    staticWords.forEach((word, data) {
      final id = word.toLowerCase();
      words[id] = VocabularyWord(
        id: id,
        word: word,
        definition: data['def'] as String,
        partOfSpeech: 'adjective',
        difficulty: data['diff'] as int,
        frequencyScore: 0.5,
      );
    });

    return words;
  }

  /// Create a new game session
  VocabularyGameSession createSession({
    required String gameId,
    required String playerId,
    int questionCount = 10,
    int? seed,
  }) {
    final sessionSeed = seed ?? DateTime.now().millisecondsSinceEpoch;
    final questions = _generateQuestions(
      count: questionCount,
      seed: sessionSeed,
    );

    return VocabularyGameSession(
      gameId: gameId,
      playerId: playerId,
      seed: sessionSeed,
      questions: questions,
      answers: [],
      startTime: DateTime.now(),
    );
  }

  /// Generate questions for a session
  List<VocabularyQuestion> _generateQuestions({
    required int count,
    required int seed,
  }) {
    final questions = <VocabularyQuestion>[];
    
    // Generate question type mix
    final types = VocabularyGameUtilities.generateQuestionTypeMix(count);
    
    // Generate difficulty distribution
    final difficulties = VocabularyGameUtilities.generateDifficultyDistribution(
      questionCount: count,
      baseDifficulty: _currentDifficulty,
    );

    // Get available words
    final availableWords = _wordPool.values
        .where((w) => !_usedWordIds.contains(w.id))
        .toList();
    
    // Reset pool if exhausted
    if (availableWords.length < count) {
      _usedWordIds.clear();
      availableWords.addAll(_wordPool.values);
    }

    // Shuffle with seed for deterministic order
    final shuffledWords = VocabularyGameUtilities.seededShuffle(
      availableWords,
      seed,
    );

    for (int i = 0; i < count && i < shuffledWords.length; i++) {
      final word = shuffledWords[i];
      _usedWordIds.add(word.id);
      
      final question = _createQuestion(
        word: word,
        type: _parseQuestionType(types[i]),
        difficulty: difficulties[i],
        seed: seed + i,
      );
      
      questions.add(question);
    }

    return questions;
  }

  /// Create a single question
  VocabularyQuestion _createQuestion({
    required VocabularyWord word,
    required QuestionType type,
    required int difficulty,
    required int seed,
  }) {
    final tier = VocabularyGameUtilities.difficultyToTier(difficulty);
    final maxTime = VocabularyGameUtilities.getMaxTimeForQuestion(
      questionType: type.toString().split('.').last,
      difficulty: difficulty,
    );

    List<String> options;
    int correctIndex;

    switch (type) {
      case QuestionType.multipleChoice:
        options = _generateMCQOptions(word, seed);
        correctIndex = options.indexOf(word.definition);
        break;
      case QuestionType.fillInBlank:
        // Fill-in-blank has no options, answer is the word itself
        options = [];
        correctIndex = -1;
        break;
      case QuestionType.synonymAntonym:
        options = _generateSynonymAntonymOptions(word, seed);
        correctIndex = options.indexOf(word.synonyms.isNotEmpty ? word.synonyms.first : word.definition);
        break;
    }

    return VocabularyQuestion(
      id: 'q_${word.id}_$seed',
      word: word,
      type: type,
      options: options,
      correctIndex: correctIndex,
      maxTime: maxTime,
      difficultyTier: tier,
    );
  }

  /// Generate multiple choice options
  List<String> _generateMCQOptions(VocabularyWord correctWord, int seed) {
    final options = <String>[correctWord.definition];
    
    // Get wrong definitions
    final wrongDefs = _wordPool.values
        .where((w) => w.id != correctWord.id)
        .map((w) => w.definition)
        .toSet()
        .toList();

    // Shuffle with seed
    final shuffled = VocabularyGameUtilities.seededShuffle(wrongDefs, seed);
    
    // Take first 3 wrong definitions
    options.addAll(shuffled.take(3));

    // Shuffle all options with seed to get deterministic order
    return VocabularyGameUtilities.seededShuffle(options, seed + 1);
  }

  /// Generate synonym/antonym options
  List<String> _generateSynonymAntonymOptions(VocabularyWord correctWord, int seed) {
    final options = <String>[];
    
    // Add correct synonym if available
    if (correctWord.synonyms.isNotEmpty) {
      options.add(correctWord.synonyms.first);
    } else {
      // Fallback to definition if no synonyms
      options.add(correctWord.definition);
    }
    
    // Get wrong synonyms from other words
    final wrongSynonyms = _wordPool.values
        .where((w) => w.id != correctWord.id && w.synonyms.isNotEmpty)
        .expand((w) => w.synonyms)
        .toSet()
        .toList();

    // Shuffle with seed
    final shuffled = VocabularyGameUtilities.seededShuffle(wrongSynonyms, seed);
    
    // Take first 3 wrong synonyms
    options.addAll(shuffled.take(3));

    // Shuffle all options with seed to get deterministic order
    return VocabularyGameUtilities.seededShuffle(options, seed + 1);
  }

  /// Process an answer and update session
  VocabularyGameSession processAnswer({
    required VocabularyGameSession session,
    int? selectedOptionIndex,
    String? textAnswer,
    required double timeTakenMs,
  }) {
    if (session.completed) {
      throw StateError('Session is already completed');
    }
    if (session.currentQuestionIndex >= session.questions.length) {
      throw StateError('No more questions available');
    }

    final question = session.questions[session.currentQuestionIndex];
    bool correct;
    
    // Determine correctness based on question type
    if (question.type == QuestionType.fillInBlank) {
      // For fill-in-blank, check if text answer matches the word
      correct = VocabularyGameUtilities.validateAnswer(
        correctAnswer: question.word.word,
        userAnswer: textAnswer,
        caseSensitive: false,
      );
    } else {
      // For MCQ and synonym/antonym, check option index
      correct = selectedOptionIndex == question.correctIndex;
    }
    
    // Calculate score
    final score = VocabularyScoringUtility.computeQuestionScore(
      correct: correct,
      timeTaken: timeTakenMs / 1000.0, // Convert to seconds
      maxTime: question.maxTime,
      difficultyTier: question.difficultyTier,
      streak: session.streak,
    );

    // Create answer record
    final answer = VocabularyAnswer(
      questionId: question.id,
      selectedOptionIndex: selectedOptionIndex,
      textAnswer: textAnswer,
      timeTakenMs: timeTakenMs,
      correct: correct,
      scoreEarned: score,
    );

    // Update session state
    final newAnswers = List<VocabularyAnswer>.from(session.answers)..add(answer);
    final newStreak = correct ? session.streak + 1 : 0;
    final newScore = session.totalScore + score;
    final newIndex = session.currentQuestionIndex + 1;
    final isCompleted = newIndex >= session.questions.length;

    // Update adaptive difficulty tracking
    _recentResults.add(correct);
    if (_recentResults.length > _rollingWindowSize) {
      _recentResults.removeAt(0);
    }

    return session.copyWith(
      answers: newAnswers,
      streak: newStreak,
      totalScore: newScore,
      currentQuestionIndex: newIndex,
      completed: isCompleted,
    );
  }

  /// Get current question from session
  VocabularyQuestion? getCurrentQuestion(VocabularyGameSession session) {
    if (session.currentQuestionIndex >= session.questions.length) {
      return null;
    }
    return session.questions[session.currentQuestionIndex];
  }

  /// Update difficulty based on recent performance
  void updateDifficulty() {
    if (_recentResults.length >= 5) {
      final successRate = VocabularyGameUtilities.calculateSuccessRate(_recentResults);
      _currentDifficulty = VocabularyGameUtilities.adjustDifficulty(
        _currentDifficulty,
        successRate,
      );
    }
  }

  /// Get current difficulty level
  int get currentDifficulty => _currentDifficulty;

  /// Set difficulty level
  set currentDifficulty(int value) {
    if (value < 1 || value > 10) {
      throw ArgumentError('Difficulty must be between 1 and 10');
    }
    _currentDifficulty = value;
  }

  /// Reset used words pool
  void resetWordPool() {
    _usedWordIds.clear();
  }

  /// Get statistics for session
  Map<String, dynamic> getSessionStats(VocabularyGameSession session) {
    final correctCount = session.answers.where((a) => a.correct).length;
    final totalQuestions = session.answers.length;
    final accuracy = totalQuestions > 0 ? correctCount / totalQuestions : 0.0;
    
    final avgTime = totalQuestions > 0
        ? session.answers.map((a) => a.timeTakenMs).reduce((a, b) => a + b) / totalQuestions
        : 0.0;

    return {
      'totalQuestions': totalQuestions,
      'correctAnswers': correctCount,
      'accuracy': accuracy,
      'currentStreak': session.streak,
      'maxStreak': _calculateMaxStreak(session.answers),
      'totalScore': session.totalScore,
      'averageTimeMs': avgTime,
    };
  }

  /// Calculate maximum streak achieved
  int _calculateMaxStreak(List<VocabularyAnswer> answers) {
    int maxStreak = 0;
    int currentStreak = 0;
    
    for (final answer in answers) {
      if (answer.correct) {
        currentStreak++;
        maxStreak = max(maxStreak, currentStreak);
      } else {
        currentStreak = 0;
      }
    }
    
    return maxStreak;
  }

  /// Parse question type from string
  QuestionType _parseQuestionType(String typeStr) {
    switch (typeStr) {
      case 'multipleChoice':
        return QuestionType.multipleChoice;
      case 'fillInBlank':
        return QuestionType.fillInBlank;
      case 'synonymAntonym':
        return QuestionType.synonymAntonym;
      default:
        return QuestionType.multipleChoice;
    }
  }
}
