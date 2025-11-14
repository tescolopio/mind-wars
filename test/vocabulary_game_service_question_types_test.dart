/**
 * Tests for Multiple Question Types in Vocabulary Game Service
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_wars/services/vocabulary_game_service.dart';
import 'package:mind_wars/models/vocabulary_models.dart';
import 'dart:math';

void main() {
  group('VocabularyGameService - Question Types', () {
    late VocabularyGameService service;

    setUp(() {
      service = VocabularyGameService(random: Random(42));
    });

    test('should generate session with mixed question types', () {
      final session = service.createSession(
        gameId: 'test_game',
        playerId: 'test_player',
        questionCount: 10,
        seed: 12345,
      );

      expect(session.questions.length, equals(10));
      
      // Check that we have different question types
      final types = session.questions.map((q) => q.type).toSet();
      expect(types.length, greaterThan(1), reason: 'Should have multiple question types');
    });

    test('should handle fill-in-blank answers correctly', () {
      final session = service.createSession(
        gameId: 'test_game',
        playerId: 'test_player',
        questionCount: 10,
        seed: 12345,
      );

      // Find a fill-in-blank question
      final fillInQuestion = session.questions.firstWhere(
        (q) => q.type == QuestionType.fillInBlank,
        orElse: () => session.questions.first,
      );

      // Create a session with just this question for testing
      final testSession = VocabularyGameSession(
        gameId: 'test',
        playerId: 'player',
        seed: 123,
        questions: [fillInQuestion],
        answers: [],
        startTime: DateTime.now(),
      );

      // Test correct answer (case insensitive)
      final updatedSession = service.processAnswer(
        session: testSession,
        textAnswer: fillInQuestion.word.word.toLowerCase(),
        timeTakenMs: 5000,
      );

      expect(updatedSession.answers.length, equals(1));
      expect(updatedSession.answers.first.correct, isTrue);
      expect(updatedSession.answers.first.textAnswer, isNotNull);
    });

    test('should handle fill-in-blank wrong answer', () {
      final session = service.createSession(
        gameId: 'test_game',
        playerId: 'test_player',
        questionCount: 10,
        seed: 12345,
      );

      // Find a fill-in-blank question
      final fillInQuestion = session.questions.firstWhere(
        (q) => q.type == QuestionType.fillInBlank,
        orElse: () => session.questions.first,
      );

      final testSession = VocabularyGameSession(
        gameId: 'test',
        playerId: 'player',
        seed: 123,
        questions: [fillInQuestion],
        answers: [],
        startTime: DateTime.now(),
      );

      // Test wrong answer
      final updatedSession = service.processAnswer(
        session: testSession,
        textAnswer: 'WRONGANSWER',
        timeTakenMs: 5000,
      );

      expect(updatedSession.answers.first.correct, isFalse);
      expect(updatedSession.streak, equals(0));
    });

    test('should handle MCQ questions correctly', () {
      final session = service.createSession(
        gameId: 'test_game',
        playerId: 'test_player',
        questionCount: 10,
        seed: 12345,
      );

      final mcqQuestion = session.questions.firstWhere(
        (q) => q.type == QuestionType.multipleChoice,
        orElse: () => session.questions.first,
      );

      final testSession = VocabularyGameSession(
        gameId: 'test',
        playerId: 'player',
        seed: 123,
        questions: [mcqQuestion],
        answers: [],
        startTime: DateTime.now(),
      );

      // Test correct answer
      final updatedSession = service.processAnswer(
        session: testSession,
        selectedOptionIndex: mcqQuestion.correctIndex,
        timeTakenMs: 5000,
      );

      expect(updatedSession.answers.first.correct, isTrue);
      expect(updatedSession.answers.first.selectedOptionIndex, equals(mcqQuestion.correctIndex));
    });

    test('should handle synonym/antonym questions correctly', () {
      final session = service.createSession(
        gameId: 'test_game',
        playerId: 'test_player',
        questionCount: 10,
        seed: 12345,
      );

      // Check if we have synonym/antonym questions
      final synQuestions = session.questions.where(
        (q) => q.type == QuestionType.synonymAntonym,
      ).toList();

      if (synQuestions.isNotEmpty) {
        final synQuestion = synQuestions.first;

        final testSession = VocabularyGameSession(
          gameId: 'test',
          playerId: 'player',
          seed: 123,
          questions: [synQuestion],
          answers: [],
          startTime: DateTime.now(),
        );

        // Test correct answer
        final updatedSession = service.processAnswer(
          session: testSession,
          selectedOptionIndex: synQuestion.correctIndex,
          timeTakenMs: 5000,
        );

        expect(updatedSession.answers.first.correct, isTrue);
      }
    });

    test('fill-in-blank should have no options', () {
      final session = service.createSession(
        gameId: 'test_game',
        playerId: 'test_player',
        questionCount: 10,
        seed: 12345,
      );

      final fillInQuestions = session.questions.where(
        (q) => q.type == QuestionType.fillInBlank,
      ).toList();

      if (fillInQuestions.isNotEmpty) {
        expect(fillInQuestions.first.options.isEmpty, isTrue);
        expect(fillInQuestions.first.correctIndex, equals(-1));
      }
    });

    test('MCQ and synonym questions should have 4 options', () {
      final session = service.createSession(
        gameId: 'test_game',
        playerId: 'test_player',
        questionCount: 10,
        seed: 12345,
      );

      final optionQuestions = session.questions.where(
        (q) => q.type != QuestionType.fillInBlank,
      ).toList();

      for (final question in optionQuestions) {
        expect(question.options.length, equals(4));
        expect(question.correctIndex, greaterThanOrEqualTo(0));
        expect(question.correctIndex, lessThan(4));
      }
    });

    test('processAnswer should require either selectedOptionIndex or textAnswer', () {
      final session = service.createSession(
        gameId: 'test_game',
        playerId: 'test_player',
        questionCount: 1,
        seed: 12345,
      );

      // Both null should still work (will just be wrong)
      final updatedSession = service.processAnswer(
        session: session,
        selectedOptionIndex: null,
        textAnswer: null,
        timeTakenMs: 5000,
      );

      expect(updatedSession.answers.first.correct, isFalse);
    });

    test('should maintain determinism with seed across question types', () {
      final session1 = service.createSession(
        gameId: 'test_game',
        playerId: 'test_player',
        questionCount: 10,
        seed: 99999,
      );

      final service2 = VocabularyGameService(random: Random(42));
      final session2 = service2.createSession(
        gameId: 'test_game',
        playerId: 'test_player',
        questionCount: 10,
        seed: 99999,
      );

      // Same seed should produce same questions in same order
      for (int i = 0; i < session1.questions.length; i++) {
        expect(session1.questions[i].word.id, equals(session2.questions[i].word.id));
        expect(session1.questions[i].type, equals(session2.questions[i].type));
        expect(session1.questions[i].options, equals(session2.questions[i].options));
      }
    });
  });
}
