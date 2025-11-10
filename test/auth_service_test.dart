/**
 * Tests for AuthService
 * Testing registration, login, logout, and session management
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mind_wars/services/auth_service.dart';
import 'package:mind_wars/services/api_service.dart';

@GenerateMocks([ApiService])
import 'auth_service_test.mocks.dart';

void main() {
  late AuthService authService;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    authService = AuthService(apiService: mockApiService);
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService - Registration', () {
    test('successful registration returns AuthResult with user', () async {
      // Arrange
      final mockResponse = {
        'token': 'test_token',
        'user': {
          'id': '123',
          'username': 'testuser',
          'email': 'test@example.com',
        },
      };
      when(mockApiService.register(any, any, any))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await authService.register(
        username: 'testuser',
        email: 'test@example.com',
        password: 'Password123',
      );

      // Assert
      expect(result.success, isTrue);
      expect(result.user, isNotNull);
      expect(result.user?.username, equals('testuser'));
      expect(authService.isAuthenticated, isTrue);
    });

    test('registration fails with invalid email', () async {
      // Act
      final result = await authService.register(
        username: 'testuser',
        email: 'invalid-email',
        password: 'Password123',
      );

      // Assert
      expect(result.success, isFalse);
      expect(result.error, isNotNull);
      expect(result.error, contains('valid email'));
    });

    test('registration fails with weak password', () async {
      // Act
      final result = await authService.register(
        username: 'testuser',
        email: 'test@example.com',
        password: 'weak',
      );

      // Assert
      expect(result.success, isFalse);
      expect(result.error, isNotNull);
    });

    test('registration fails with short username', () async {
      // Act
      final result = await authService.register(
        username: 'ab',
        email: 'test@example.com',
        password: 'Password123',
      );

      // Assert
      expect(result.success, isFalse);
      expect(result.error, isNotNull);
      expect(result.error, contains('3 characters'));
    });
  });

  group('AuthService - Login', () {
    test('successful login returns AuthResult with user', () async {
      // Arrange
      final mockResponse = {
        'token': 'test_token',
        'user': {
          'id': '123',
          'username': 'testuser',
          'email': 'test@example.com',
        },
      };
      when(mockApiService.login(any, any))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await authService.login(
        email: 'test@example.com',
        password: 'Password123',
      );

      // Assert
      expect(result.success, isTrue);
      expect(result.user, isNotNull);
      expect(result.user?.email, equals('test@example.com'));
      expect(authService.isAuthenticated, isTrue);
    });

    test('login with autoLogin stores preference', () async {
      // Arrange
      final mockResponse = {
        'token': 'test_token',
        'user': {
          'id': '123',
          'username': 'testuser',
          'email': 'test@example.com',
        },
      };
      when(mockApiService.login(any, any))
          .thenAnswer((_) async => mockResponse);

      // Act
      await authService.login(
        email: 'test@example.com',
        password: 'Password123',
        autoLogin: true,
      );

      // Assert
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('auto_login'), isTrue);
    });

    test('login fails with API error', () async {
      // Arrange
      when(mockApiService.login(any, any))
          .thenThrow(Exception('Invalid credentials'));

      // Act
      final result = await authService.login(
        email: 'test@example.com',
        password: 'WrongPassword',
      );

      // Assert
      expect(result.success, isFalse);
      expect(result.error, isNotNull);
    });
  });

  group('AuthService - Logout', () {
    test('logout clears user data and auth state', () async {
      // Arrange - first login
      final mockResponse = {
        'token': 'test_token',
        'user': {
          'id': '123',
          'username': 'testuser',
          'email': 'test@example.com',
        },
      };
      when(mockApiService.login(any, any))
          .thenAnswer((_) async => mockResponse);
      when(mockApiService.logout()).thenAnswer((_) async => {});

      await authService.login(
        email: 'test@example.com',
        password: 'Password123',
      );

      expect(authService.isAuthenticated, isTrue);

      // Act
      await authService.logout();

      // Assert
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentUser, isNull);
    });

    test('logout clears stored preferences', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'test_token');
      await prefs.setString('user_id', '123');
      when(mockApiService.logout()).thenAnswer((_) async => {});

      // Act
      await authService.logout();

      // Assert
      expect(prefs.getString('auth_token'), isNull);
      expect(prefs.getString('user_id'), isNull);
    });
  });

  group('AuthService - Session Restoration', () {
    test('restoreSession returns true when valid session exists', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_login', true);
      await prefs.setString('auth_token', 'test_token');
      await prefs.setString('user_id', '123');
      await prefs.setString('username', 'testuser');
      await prefs.setString('email', 'test@example.com');

      // Act
      final result = await authService.restoreSession();

      // Assert
      expect(result, isTrue);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.currentUser, isNotNull);
    });

    test('restoreSession returns false when auto_login is disabled', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_login', false);
      await prefs.setString('auth_token', 'test_token');

      // Act
      final result = await authService.restoreSession();

      // Assert
      expect(result, isFalse);
      expect(authService.isAuthenticated, isFalse);
    });

    test('restoreSession returns false when no token exists', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_login', true);

      // Act
      final result = await authService.restoreSession();

      // Assert
      expect(result, isFalse);
    });
  });
}
