/**
 * Vocabulary Asset Loader
 * Loads vocabulary words from JSON assets
 */

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/vocabulary_models.dart';

class VocabularyAssetLoader {
  /// Load words from JSON asset file
  static Future<Map<String, VocabularyWord>> loadWords({
    String assetPath = 'assets/words_small.json',
  }) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> data = json.decode(jsonString);
      
      final words = <String, VocabularyWord>{};
      final wordsList = data['words'] as List;
      
      for (var wordData in wordsList) {
        final word = VocabularyWord.fromJson(wordData);
        words[word.id] = word;
      }
      
      return words;
    } catch (e) {
      // If asset loading fails, return empty map
      // The service will fall back to default words
      return {};
    }
  }

  /// Load words synchronously from JSON string (for testing)
  static Map<String, VocabularyWord> loadWordsFromJson(String jsonString) {
    final Map<String, dynamic> data = json.decode(jsonString);
    final words = <String, VocabularyWord>{};
    final wordsList = data['words'] as List;
    
    for (var wordData in wordsList) {
      final word = VocabularyWord.fromJson(wordData);
      words[word.id] = word;
    }
    
    return words;
  }

  /// Get metadata from the asset file
  static Future<Map<String, dynamic>?> loadMetadata({
    String assetPath = 'assets/words_small.json',
  }) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> data = json.decode(jsonString);
      return data['metadata'] as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }
}
