/**
 * Lobby Code Generator - Generates memorable lobby codes
 * Formats: FAMILY42, TEAM99, GAME17, etc.
 */

import 'dart:math';

class LobbyCodeGenerator {
  static final Random _random = Random();
  
  static final List<String> _prefixes = [
    'FAMILY',
    'FRIEND',
    'TEAM',
    'SQUAD',
    'CREW',
    'GANG',
    'GROUP',
    'CLUB',
    'GAME',
    'BRAIN',
    'MIND',
    'SMART',
    'THINK',
    'PLAY',
    'WIN',
    'FUN',
  ];
  
  /// Generate a memorable lobby code
  /// Format: PREFIX + 2-digit number (e.g., "FAMILY42", "TEAM99")
  static String generate() {
    final prefix = _prefixes[_random.nextInt(_prefixes.length)];
    final number = _random.nextInt(100); // 0-99
    return '$prefix${number.toString().padLeft(2, '0')}';
  }
  
  /// Generate a custom lobby code with specific prefix
  static String generateWithPrefix(String prefix) {
    final number = _random.nextInt(100);
    return '${prefix.toUpperCase()}${number.toString().padLeft(2, '0')}';
  }
  
  /// Validate lobby code format
  static bool isValidCode(String code) {
    // Code should be 6-10 characters, alphanumeric
    if (code.length < 6 || code.length > 10) return false;
    return RegExp(r'^[A-Z0-9]+$').hasMatch(code.toUpperCase());
  }
  
  /// Normalize lobby code (uppercase, trim)
  static String normalize(String code) {
    return code.trim().toUpperCase();
  }
}
