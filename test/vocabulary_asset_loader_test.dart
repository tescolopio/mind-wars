/**
 * Tests for Vocabulary Asset Loader
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_wars/utils/vocabulary_asset_loader.dart';

void main() {
  group('VocabularyAssetLoader', () {
    group('loadWordsFromJson', () {
      test('should parse valid JSON data', () {
        final jsonString = '''
        {
          "version": "1.0.0",
          "words": [
            {
              "id": "test",
              "word": "TEST",
              "definition": "A test word",
              "partOfSpeech": "noun",
              "difficulty": 2,
              "frequencyScore": 0.5
            }
          ]
        }
        ''';

        final words = VocabularyAssetLoader.loadWordsFromJson(jsonString);

        expect(words.length, equals(1));
        expect(words['test']?.word, equals('TEST'));
        expect(words['test']?.definition, equals('A test word'));
        expect(words['test']?.difficulty, equals(2));
      });

      test('should handle multiple words', () {
        final jsonString = '''
        {
          "words": [
            {
              "id": "word1",
              "word": "WORD1",
              "definition": "First word",
              "partOfSpeech": "noun",
              "difficulty": 1,
              "frequencyScore": 0.3
            },
            {
              "id": "word2",
              "word": "WORD2",
              "definition": "Second word",
              "partOfSpeech": "verb",
              "difficulty": 3,
              "frequencyScore": 0.7
            }
          ]
        }
        ''';

        final words = VocabularyAssetLoader.loadWordsFromJson(jsonString);

        expect(words.length, equals(2));
        expect(words['word1']?.word, equals('WORD1'));
        expect(words['word2']?.word, equals('WORD2'));
      });

      test('should handle optional fields', () {
        final jsonString = '''
        {
          "words": [
            {
              "id": "test",
              "word": "TEST",
              "definition": "A test word",
              "partOfSpeech": "noun",
              "difficulty": 2,
              "frequencyScore": 0.5,
              "example": "This is a test.",
              "synonyms": ["exam", "trial"],
              "cefr": "B1"
            }
          ]
        }
        ''';

        final words = VocabularyAssetLoader.loadWordsFromJson(jsonString);

        expect(words['test']?.example, equals('This is a test.'));
        expect(words['test']?.synonyms, contains('exam'));
        expect(words['test']?.cefr, equals('B1'));
      });

      test('should handle empty words list', () {
        final jsonString = '''
        {
          "words": []
        }
        ''';

        final words = VocabularyAssetLoader.loadWordsFromJson(jsonString);

        expect(words.length, equals(0));
      });

      test('should index words by id', () {
        final jsonString = '''
        {
          "words": [
            {
              "id": "benevolent",
              "word": "BENEVOLENT",
              "definition": "Kind and generous",
              "partOfSpeech": "adjective",
              "difficulty": 3,
              "frequencyScore": 0.5
            }
          ]
        }
        ''';

        final words = VocabularyAssetLoader.loadWordsFromJson(jsonString);

        expect(words.containsKey('benevolent'), isTrue);
        expect(words['benevolent']?.word, equals('BENEVOLENT'));
      });
    });
  });
}
