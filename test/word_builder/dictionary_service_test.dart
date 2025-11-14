/**
 * Unit tests for DictionaryService
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_wars/games/word_builder/dictionary_service.dart';

void main() {
  group('DictionaryService', () {
    late DictionaryService dictionary;

    setUp(() {
      dictionary = DictionaryService();
    });

    group('Word Validation', () {
      test('should validate common words', () {
        expect(dictionary.isValidWord('THE'), isTrue);
        expect(dictionary.isValidWord('AND'), isTrue);
        expect(dictionary.isValidWord('CAT'), isTrue);
      });

      test('should be case insensitive', () {
        expect(dictionary.isValidWord('cat'), isTrue);
        expect(dictionary.isValidWord('Cat'), isTrue);
        expect(dictionary.isValidWord('CAT'), isTrue);
      });

      test('should reject invalid words', () {
        expect(dictionary.isValidWord('XYZ'), isFalse);
        expect(dictionary.isValidWord('QQQQ'), isFalse);
        expect(dictionary.isValidWord('NOTAWORD'), isFalse);
      });

      test('should handle empty strings', () {
        expect(dictionary.isValidWord(''), isFalse);
      });
    });

    group('Frequency Buckets', () {
      test('should return frequency bucket for valid words', () {
        final bucket = dictionary.getFrequencyBucket('THE');
        expect(bucket, isNotNull);
        expect(bucket, equals(1)); // Common word
      });

      test('should return null for invalid words', () {
        final bucket = dictionary.getFrequencyBucket('NOTAWORD');
        expect(bucket, isNull);
      });

      test('should assign different buckets based on word properties', () {
        final bucket3 = dictionary.getFrequencyBucket('THE'); // 3-letter common
        final bucket4 = dictionary.getFrequencyBucket('CATS'); // 4-letter
        
        expect(bucket3, isNotNull);
        expect(bucket4, isNotNull);
      });

      test('should give higher buckets for longer words', () {
        final bucket7 = dictionary.getFrequencyBucket('THROUGH');
        expect(bucket7, equals(5)); // 7+ letters = bucket 5
      });
    });

    group('Dictionary Properties', () {
      test('should report loaded status', () {
        expect(dictionary.isLoaded, isTrue);
      });

      test('should have non-zero dictionary size', () {
        expect(dictionary.dictionarySize, greaterThan(0));
      });

      test('should have reasonable dictionary size', () {
        // MVP should have at least 100 words
        expect(dictionary.dictionarySize, greaterThanOrEqualTo(100));
      });
    });

    group('Word Length Support', () {
      test('should support 3-letter words', () {
        expect(dictionary.isValidWord('CAT'), isTrue);
        expect(dictionary.isValidWord('DOG'), isTrue);
        expect(dictionary.isValidWord('RUN'), isTrue);
      });

      test('should support 4-letter words', () {
        expect(dictionary.isValidWord('CATS'), isTrue);
        expect(dictionary.isValidWord('DOGS'), isTrue);
        expect(dictionary.isValidWord('RUNS'), isTrue);
      });

      test('should support 5-letter words', () {
        expect(dictionary.isValidWord('ABOUT'), isTrue);
        expect(dictionary.isValidWord('WORLD'), isTrue);
      });

      test('should support longer words', () {
        expect(dictionary.isValidWord('THROUGH'), isTrue);
        expect(dictionary.isValidWord('ANOTHER'), isTrue);
      });
    });
  });
}
