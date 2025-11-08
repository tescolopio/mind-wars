/**
 * Tests for Validators utility class
 * Testing email validation, password strength, username validation
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_wars/utils/validators.dart';

void main() {
  group('Validators - Email', () {
    test('validateEmail returns null for valid emails', () {
      expect(Validators.validateEmail('test@example.com'), isNull);
      expect(Validators.validateEmail('user.name@domain.co.uk'), isNull);
      expect(Validators.validateEmail('first+last@test.org'), isNull);
    });

    test('validateEmail returns error for invalid emails', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('invalid'), isNotNull);
      expect(Validators.validateEmail('@example.com'), isNotNull);
      expect(Validators.validateEmail('user@'), isNotNull);
      expect(Validators.validateEmail('user@domain'), isNotNull);
    });

    test('validateEmail returns error for null', () {
      expect(Validators.validateEmail(null), isNotNull);
    });
  });

  group('Validators - Password', () {
    test('validatePassword returns null for valid passwords', () {
      expect(Validators.validatePassword('Password1'), isNull);
      expect(Validators.validatePassword('SecurePass123'), isNull);
      expect(Validators.validatePassword('MyP@ssw0rd'), isNull);
    });

    test('validatePassword returns error for short passwords', () {
      expect(Validators.validatePassword('Pass1'), isNotNull);
      expect(Validators.validatePassword('abc123'), isNotNull);
    });

    test('validatePassword returns error for missing uppercase', () {
      expect(Validators.validatePassword('password123'), isNotNull);
    });

    test('validatePassword returns error for missing lowercase', () {
      expect(Validators.validatePassword('PASSWORD123'), isNotNull);
    });

    test('validatePassword returns error for missing numbers', () {
      expect(Validators.validatePassword('Password'), isNotNull);
    });

    test('validatePassword returns error for empty password', () {
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword(null), isNotNull);
    });
  });

  group('Validators - Confirm Password', () {
    test('validateConfirmPassword returns null when passwords match', () {
      expect(
        Validators.validateConfirmPassword('Password1', 'Password1'),
        isNull,
      );
    });

    test('validateConfirmPassword returns error when passwords do not match', () {
      expect(
        Validators.validateConfirmPassword('Password1', 'Password2'),
        isNotNull,
      );
    });

    test('validateConfirmPassword returns error for empty confirm password', () {
      expect(
        Validators.validateConfirmPassword('', 'Password1'),
        isNotNull,
      );
      expect(
        Validators.validateConfirmPassword(null, 'Password1'),
        isNotNull,
      );
    });
  });

  group('Validators - Username', () {
    test('validateUsername returns null for valid usernames', () {
      expect(Validators.validateUsername('user123'), isNull);
      expect(Validators.validateUsername('john_doe'), isNull);
      expect(Validators.validateUsername('Player1'), isNull);
    });

    test('validateUsername returns error for short usernames', () {
      expect(Validators.validateUsername('ab'), isNotNull);
      expect(Validators.validateUsername('x'), isNotNull);
    });

    test('validateUsername returns error for long usernames', () {
      expect(
        Validators.validateUsername('a' * 21),
        isNotNull,
      );
    });

    test('validateUsername returns error for invalid characters', () {
      expect(Validators.validateUsername('user name'), isNotNull);
      expect(Validators.validateUsername('user@123'), isNotNull);
      expect(Validators.validateUsername('user-name'), isNotNull);
    });

    test('validateUsername returns error for empty username', () {
      expect(Validators.validateUsername(''), isNotNull);
      expect(Validators.validateUsername(null), isNotNull);
    });
  });

  group('Validators - Password Strength', () {
    test('calculatePasswordStrength returns 0 for empty password', () {
      expect(Validators.calculatePasswordStrength(''), equals(0));
    });

    test('calculatePasswordStrength returns low values for weak passwords', () {
      expect(
        Validators.calculatePasswordStrength('abc'),
        lessThan(2),
      );
      expect(
        Validators.calculatePasswordStrength('12345'),
        lessThan(2),
      );
    });

    test('calculatePasswordStrength returns higher values for stronger passwords', () {
      expect(
        Validators.calculatePasswordStrength('Password1'),
        greaterThanOrEqualTo(3),
      );
      expect(
        Validators.calculatePasswordStrength('P@ssw0rd123'),
        greaterThanOrEqualTo(4),
      );
    });

    test('calculatePasswordStrength caps at 4', () {
      expect(
        Validators.calculatePasswordStrength('VeryStr0ng!P@ssw0rd123'),
        equals(4),
      );
    });
  });

  group('Validators - Password Strength Labels', () {
    test('getPasswordStrengthLabel returns correct labels', () {
      expect(Validators.getPasswordStrengthLabel(0), equals('Very Weak'));
      expect(Validators.getPasswordStrengthLabel(1), equals('Weak'));
      expect(Validators.getPasswordStrengthLabel(2), equals('Fair'));
      expect(Validators.getPasswordStrengthLabel(3), equals('Good'));
      expect(Validators.getPasswordStrengthLabel(4), equals('Strong'));
    });
  });

  group('Validators - Password Strength Colors', () {
    test('getPasswordStrengthColor returns correct color codes', () {
      expect(Validators.getPasswordStrengthColor(0), equals(0xFFE53935)); // Red
      expect(Validators.getPasswordStrengthColor(1), equals(0xFFE53935)); // Red
      expect(Validators.getPasswordStrengthColor(2), equals(0xFFFB8C00)); // Orange
      expect(Validators.getPasswordStrengthColor(3), equals(0xFFFDD835)); // Yellow
      expect(Validators.getPasswordStrengthColor(4), equals(0xFF43A047)); // Green
    });
  });
}
