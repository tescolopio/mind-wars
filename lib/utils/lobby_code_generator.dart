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
  /// Ensures minimum length of 6 characters
  static String generate() {
    final prefix = _prefixes[_random.nextInt(_prefixes.length)];
    final number = _random.nextInt(100); // 0-99
    final code = '$prefix${number.toString().padLeft(2, '0')}';
    
    // Ensure minimum length of 6 characters by padding if needed
    if (code.length < 6) {
      final padding = '0' * (6 - code.length);
      return '$code$padding';
    }
    
    return code;
  }
  
  /// Generate a custom lobby code with specific prefix
  static String generateWithPrefix(String prefix) {
    final number = _random.nextInt(100);
    return '${prefix.toUpperCase()}${number.toString().padLeft(2, '0')}';
  }
  
  /// Validate lobby code format
  static bool isValidCode(String code) {
    // Code should be 6-10 characters, alphanumeric, and uppercase only
    if (code.length < 6 || code.length > 10) return false;
    
    // Check if code contains only uppercase letters and numbers (reject lowercase)
    if (code != code.toUpperCase()) return false;
    
    return RegExp(r'^[A-Z0-9]+$').hasMatch(code);
  }
  
  /// Normalize lobby code (uppercase, trim)
  static String normalize(String code) {
    return code.trim().toUpperCase();
  }
}
