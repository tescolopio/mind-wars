/**
 * Vocabulary Game Models
 * Data models for Vocabulary Showdown game
 */

/// Vocabulary word with metadata
class VocabularyWord {
  final String id;
  final String word;
  final String definition;
  final String partOfSpeech; // noun, verb, adjective, etc.
  final int difficulty; // 1-5 scale
  final double frequencyScore; // 0.0-1.0, higher = more common
  final String? example;
  final String? audioUrl;
  final List<String> synonyms;
  final String? cefr; // A1, A2, B1, B2, C1, C2

  // Spaced repetition fields
  final int timesSeen;
  final int timesCorrect;
  final DateTime? nextReview;
  final double easeFactor;
  final int intervalDays;

  VocabularyWord({
    required this.id,
    required this.word,
    required this.definition,
    required this.partOfSpeech,
    required this.difficulty,
    required this.frequencyScore,
    this.example,
    this.audioUrl,
    this.synonyms = const [],
    this.cefr,
    this.timesSeen = 0,
    this.timesCorrect = 0,
    this.nextReview,
    this.easeFactor = 2.5,
    this.intervalDays = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'word': word,
        'definition': definition,
        'partOfSpeech': partOfSpeech,
        'difficulty': difficulty,
        'frequencyScore': frequencyScore,
        'example': example,
        'audioUrl': audioUrl,
        'synonyms': synonyms,
        'cefr': cefr,
        'timesSeen': timesSeen,
        'timesCorrect': timesCorrect,
        'nextReview': nextReview?.toIso8601String(),
        'easeFactor': easeFactor,
        'intervalDays': intervalDays,
      };

  factory VocabularyWord.fromJson(Map<String, dynamic> json) => VocabularyWord(
        id: json['id'],
        word: json['word'],
        definition: json['definition'],
        partOfSpeech: json['partOfSpeech'],
        difficulty: json['difficulty'],
        frequencyScore: json['frequencyScore'].toDouble(),
        example: json['example'],
        audioUrl: json['audioUrl'],
        synonyms: json['synonyms'] != null
            ? List<String>.from(json['synonyms'])
            : [],
        cefr: json['cefr'],
        timesSeen: json['timesSeen'] ?? 0,
        timesCorrect: json['timesCorrect'] ?? 0,
        nextReview: json['nextReview'] != null
            ? DateTime.parse(json['nextReview'])
            : null,
        easeFactor: json['easeFactor']?.toDouble() ?? 2.5,
        intervalDays: json['intervalDays'] ?? 0,
      );

  VocabularyWord copyWith({
    String? id,
    String? word,
    String? definition,
    String? partOfSpeech,
    int? difficulty,
    double? frequencyScore,
    String? example,
    String? audioUrl,
    List<String>? synonyms,
    String? cefr,
    int? timesSeen,
    int? timesCorrect,
    DateTime? nextReview,
    double? easeFactor,
    int? intervalDays,
  }) {
    return VocabularyWord(
      id: id ?? this.id,
      word: word ?? this.word,
      definition: definition ?? this.definition,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      difficulty: difficulty ?? this.difficulty,
      frequencyScore: frequencyScore ?? this.frequencyScore,
      example: example ?? this.example,
      audioUrl: audioUrl ?? this.audioUrl,
      synonyms: synonyms ?? this.synonyms,
      cefr: cefr ?? this.cefr,
      timesSeen: timesSeen ?? this.timesSeen,
      timesCorrect: timesCorrect ?? this.timesCorrect,
      nextReview: nextReview ?? this.nextReview,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
    );
  }
}

/// Question type enum
enum QuestionType {
  multipleChoice,
  fillInBlank,
  synonymAntonym,
}

/// Vocabulary question
class VocabularyQuestion {
  final String id;
  final VocabularyWord word;
  final QuestionType type;
  final List<String> options; // For MCQ
  final int correctIndex; // Index of correct answer in options
  final double maxTime; // seconds
  final int difficultyTier; // 1-4

  VocabularyQuestion({
    required this.id,
    required this.word,
    required this.type,
    required this.options,
    required this.correctIndex,
    required this.maxTime,
    required this.difficultyTier,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'word': word.toJson(),
        'type': type.toString(),
        'options': options,
        'correctIndex': correctIndex,
        'maxTime': maxTime,
        'difficultyTier': difficultyTier,
      };

  factory VocabularyQuestion.fromJson(Map<String, dynamic> json) =>
      VocabularyQuestion(
        id: json['id'],
        word: VocabularyWord.fromJson(json['word']),
        type: QuestionType.values.firstWhere(
          (e) => e.toString() == json['type'],
        ),
        options: List<String>.from(json['options']),
        correctIndex: json['correctIndex'],
        maxTime: json['maxTime'].toDouble(),
        difficultyTier: json['difficultyTier'],
      );
}

/// Player answer for a question
class VocabularyAnswer {
  final String questionId;
  final int? selectedOptionIndex; // null for fill-in-blank
  final String? textAnswer; // for fill-in-blank
  final double timeTakenMs;
  final bool correct;
  final int scoreEarned;

  VocabularyAnswer({
    required this.questionId,
    this.selectedOptionIndex,
    this.textAnswer,
    required this.timeTakenMs,
    required this.correct,
    required this.scoreEarned,
  });

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'selectedOptionIndex': selectedOptionIndex,
        'textAnswer': textAnswer,
        'timeTakenMs': timeTakenMs,
        'correct': correct,
        'scoreEarned': scoreEarned,
      };

  factory VocabularyAnswer.fromJson(Map<String, dynamic> json) =>
      VocabularyAnswer(
        questionId: json['questionId'],
        selectedOptionIndex: json['selectedOptionIndex'],
        textAnswer: json['textAnswer'],
        timeTakenMs: json['timeTakenMs'].toDouble(),
        correct: json['correct'],
        scoreEarned: json['scoreEarned'],
      );
}

/// Game session state
class VocabularyGameSession {
  final String gameId;
  final String playerId;
  final int seed;
  final List<VocabularyQuestion> questions;
  final List<VocabularyAnswer> answers;
  final int currentQuestionIndex;
  final int streak;
  final int totalScore;
  final DateTime startTime;
  final bool completed;

  VocabularyGameSession({
    required this.gameId,
    required this.playerId,
    required this.seed,
    required this.questions,
    required this.answers,
    this.currentQuestionIndex = 0,
    this.streak = 0,
    this.totalScore = 0,
    required this.startTime,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
        'gameId': gameId,
        'playerId': playerId,
        'seed': seed,
        'questions': questions.map((q) => q.toJson()).toList(),
        'answers': answers.map((a) => a.toJson()).toList(),
        'currentQuestionIndex': currentQuestionIndex,
        'streak': streak,
        'totalScore': totalScore,
        'startTime': startTime.toIso8601String(),
        'completed': completed,
      };

  factory VocabularyGameSession.fromJson(Map<String, dynamic> json) =>
      VocabularyGameSession(
        gameId: json['gameId'],
        playerId: json['playerId'],
        seed: json['seed'],
        questions: (json['questions'] as List)
            .map((q) => VocabularyQuestion.fromJson(q))
            .toList(),
        answers: (json['answers'] as List)
            .map((a) => VocabularyAnswer.fromJson(a))
            .toList(),
        currentQuestionIndex: json['currentQuestionIndex'] ?? 0,
        streak: json['streak'] ?? 0,
        totalScore: json['totalScore'] ?? 0,
        startTime: DateTime.parse(json['startTime']),
        completed: json['completed'] ?? false,
      );

  VocabularyGameSession copyWith({
    String? gameId,
    String? playerId,
    int? seed,
    List<VocabularyQuestion>? questions,
    List<VocabularyAnswer>? answers,
    int? currentQuestionIndex,
    int? streak,
    int? totalScore,
    DateTime? startTime,
    bool? completed,
  }) {
    return VocabularyGameSession(
      gameId: gameId ?? this.gameId,
      playerId: playerId ?? this.playerId,
      seed: seed ?? this.seed,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      streak: streak ?? this.streak,
      totalScore: totalScore ?? this.totalScore,
      startTime: startTime ?? this.startTime,
      completed: completed ?? this.completed,
    );
  }
}
