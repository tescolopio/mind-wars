/**
 * Tests for Lobby Code Generator
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_wars/utils/lobby_code_generator.dart';

void main() {
  group('LobbyCodeGenerator', () {
    group('generate', () {
      test('generates code with correct format', () {
        final code = LobbyCodeGenerator.generate();
        
        // Should be 6-10 characters
        expect(code.length, greaterThanOrEqualTo(6));
        expect(code.length, lessThanOrEqualTo(10));
        
        // Should be uppercase alphanumeric
        expect(RegExp(r'^[A-Z0-9]+$').hasMatch(code), true);
      });
      
      test('generates different codes', () {
        final codes = <String>{};
        
        for (int i = 0; i < 50; i++) {
          codes.add(LobbyCodeGenerator.generate());
        }
        
        // Should generate at least some variety
        expect(codes.length, greaterThan(10));
      });
      
      test('includes 2-digit number at end', () {
        for (int i = 0; i < 10; i++) {
          final code = LobbyCodeGenerator.generate();
          // Last 2 characters should be digits
          final lastTwo = code.substring(code.length - 2);
          expect(RegExp(r'^\d{2}$').hasMatch(lastTwo), true);
        }
      });
    });
    
    group('generateWithPrefix', () {
      test('uses custom prefix', () {
        final code = LobbyCodeGenerator.generateWithPrefix('TEST');
        expect(code.startsWith('TEST'), true);
      });
      
      test('converts prefix to uppercase', () {
        final code = LobbyCodeGenerator.generateWithPrefix('test');
        expect(code.startsWith('TEST'), true);
      });
      
      test('includes 2-digit number', () {
        final code = LobbyCodeGenerator.generateWithPrefix('FAM');
        final lastTwo = code.substring(code.length - 2);
        expect(RegExp(r'^\d{2}$').hasMatch(lastTwo), true);
      });
    });
    
    group('isValidCode', () {
      test('accepts valid codes', () {
        expect(LobbyCodeGenerator.isValidCode('FAMILY42'), true);
        expect(LobbyCodeGenerator.isValidCode('TEAM99'), true);
        expect(LobbyCodeGenerator.isValidCode('GAME17'), true);
        expect(LobbyCodeGenerator.isValidCode('ABC123'), true);
      });
      
      test('rejects codes that are too short', () {
        expect(LobbyCodeGenerator.isValidCode('ABC12'), false);
        expect(LobbyCodeGenerator.isValidCode('AB1'), false);
      });
      
      test('rejects codes that are too long', () {
        expect(LobbyCodeGenerator.isValidCode('VERYLONGCODE123'), false);
      });
      
      test('rejects codes with lowercase', () {
        expect(LobbyCodeGenerator.isValidCode('family42'), false);
      });
      
      test('rejects codes with special characters', () {
        expect(LobbyCodeGenerator.isValidCode('TEAM-99'), false);
        expect(LobbyCodeGenerator.isValidCode('GAME_17'), false);
        expect(LobbyCodeGenerator.isValidCode('FAM#42'), false);
      });
      
      test('rejects empty string', () {
        expect(LobbyCodeGenerator.isValidCode(''), false);
      });
    });
    
    group('normalize', () {
      test('converts to uppercase', () {
        expect(LobbyCodeGenerator.normalize('family42'), 'FAMILY42');
        expect(LobbyCodeGenerator.normalize('Team99'), 'TEAM99');
      });
      
      test('trims whitespace', () {
        expect(LobbyCodeGenerator.normalize('  FAMILY42  '), 'FAMILY42');
        expect(LobbyCodeGenerator.normalize('TEAM99 '), 'TEAM99');
      });
      
      test('handles mixed case and whitespace', () {
        expect(LobbyCodeGenerator.normalize(' FaMiLy42 '), 'FAMILY42');
      });
    });
  });
}
