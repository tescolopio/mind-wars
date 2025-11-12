/**
 * Local Authentication Service Tests
 * Tests for local-only authentication during alpha testing
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mind_wars/services/local_auth_service.dart';
import 'package:mind_wars/services/offline_service.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('LocalAuthService Tests', () {
    late Database database;
    late LocalAuthService authService;

    setUp(() async {
      // Create in-memory database for testing
      database = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (db, version) async {
          // Create local_users table
          await db.execute('''
            CREATE TABLE local_users (
              id TEXT PRIMARY KEY,
              username TEXT NOT NULL UNIQUE,
              email TEXT NOT NULL UNIQUE,
              password_hash TEXT NOT NULL,
              created_at TEXT NOT NULL,
              synced INTEGER DEFAULT 0
            )
          ''');
        },
      );
      
      authService = LocalAuthService(database: database);
    });

    tearDown(() async {
      await database.close();
    });

    test('register - creates new user successfully', () async {
      final result = await authService.register(
        username: 'testuser',
        email: 'test@example.com',
        password: 'Password123',
      );

      expect(result.success, true);
      expect(result.user, isNotNull);
      expect(result.user?.username, 'testuser');
      expect(result.user?.email, 'test@example.com');
      expect(result.error, isNull);
    });

    test('register - fails with short username', () async {
      final result = await authService.register(
        username: 'ab',
        email: 'test@example.com',
        password: 'Password123',
      );

      expect(result.success, false);
      expect(result.error, contains('at least 3 characters'));
    });

    test('register - fails with invalid email', () async {
      final result = await authService.register(
        username: 'testuser',
        email: 'invalid-email',
        password: 'Password123',
      );

      expect(result.success, false);
      expect(result.error, contains('valid email'));
    });

    test('register - fails with weak password', () async {
      final result = await authService.register(
        username: 'testuser',
        email: 'test@example.com',
        password: 'weak',
      );

      expect(result.success, false);
      expect(result.error, isNotNull);
    });

    test('register - fails with duplicate email', () async {
      // Register first user
      await authService.register(
        username: 'user1',
        email: 'test@example.com',
        password: 'Password123',
      );

      // Try to register with same email
      final result = await authService.register(
        username: 'user2',
        email: 'test@example.com',
        password: 'Password456',
      );

      expect(result.success, false);
      expect(result.error, contains('already registered'));
    });

    test('register - fails with duplicate username', () async {
      // Register first user
      await authService.register(
        username: 'testuser',
        email: 'test1@example.com',
        password: 'Password123',
      );

      // Try to register with same username
      final result = await authService.register(
        username: 'testuser',
        email: 'test2@example.com',
        password: 'Password456',
      );

      expect(result.success, false);
      expect(result.error, contains('already taken'));
    });

    test('login - succeeds with correct credentials', () async {
      // Register a user
      await authService.register(
        username: 'testuser',
        email: 'test@example.com',
        password: 'Password123',
      );

      // Logout to clear session
      await authService.logout();

      // Login
      final result = await authService.login(
        email: 'test@example.com',
        password: 'Password123',
      );

      expect(result.success, true);
      expect(result.user, isNotNull);
      expect(result.user?.email, 'test@example.com');
    });

    test('login - fails with incorrect password', () async {
      // Register a user
      await authService.register(
        username: 'testuser',
        email: 'test@example.com',
        password: 'Password123',
      );

      // Logout
      await authService.logout();

      // Try to login with wrong password
      final result = await authService.login(
        email: 'test@example.com',
        password: 'WrongPassword',
      );

      expect(result.success, false);
      expect(result.error, contains('Invalid'));
    });

    test('login - fails with non-existent email', () async {
      final result = await authService.login(
        email: 'nonexistent@example.com',
        password: 'Password123',
      );

      expect(result.success, false);
      expect(result.error, contains('Invalid'));
    });

    test('isAuthenticated - returns true when logged in', () async {
      await authService.register(
        username: 'testuser',
        email: 'test@example.com',
        password: 'Password123',
      );

      expect(authService.isAuthenticated, true);
    });

    test('isAuthenticated - returns false when logged out', () async {
      await authService.register(
        username: 'testuser',
        email: 'test@example.com',
        password: 'Password123',
      );

      await authService.logout();

      expect(authService.isAuthenticated, false);
    });

    test('currentUser - returns user when logged in', () async {
      await authService.register(
        username: 'testuser',
        email: 'test@example.com',
        password: 'Password123',
      );

      expect(authService.currentUser, isNotNull);
      expect(authService.currentUser?.username, 'testuser');
    });

    test('currentUser - returns null when logged out', () async {
      await authService.register(
        username: 'testuser',
        email: 'test@example.com',
        password: 'Password123',
      );

      await authService.logout();

      expect(authService.currentUser, isNull);
    });

    test('getUnsyncedUsers - returns users with synced = 0', () async {
      // Register multiple users
      await authService.register(
        username: 'user1',
        email: 'user1@example.com',
        password: 'Password123',
      );
      
      await authService.logout();
      
      await authService.register(
        username: 'user2',
        email: 'user2@example.com',
        password: 'Password456',
      );

      final unsyncedUsers = await authService.getUnsyncedUsers();

      expect(unsyncedUsers.length, 2);
      expect(unsyncedUsers[0]['synced'], 0);
      expect(unsyncedUsers[1]['synced'], 0);
    });

    test('markUserAsSynced - updates synced flag', () async {
      // Register a user
      final result = await authService.register(
        username: 'testuser',
        email: 'test@example.com',
        password: 'Password123',
      );

      final userId = result.user!.id;

      // Mark as synced
      await authService.markUserAsSynced(userId);

      // Check unsynced users
      final unsyncedUsers = await authService.getUnsyncedUsers();

      expect(unsyncedUsers.length, 0);
    });

    test('password validation - requires minimum length', () async {
      final result = await authService.register(
        username: 'testuser',
        email: 'test@example.com',
        password: 'Pass1',
      );

      expect(result.success, false);
      expect(result.error, contains('8 characters'));
    });

    test('password validation - requires uppercase letter', () async {
      final result = await authService.register(
        username: 'testuser',
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result.success, false);
      expect(result.error, contains('uppercase'));
    });

    test('password validation - requires lowercase letter', () async {
      final result = await authService.register(
        username: 'testuser',
        email: 'test@example.com',
        password: 'PASSWORD123',
      );

      expect(result.success, false);
      expect(result.error, contains('lowercase'));
    });

    test('password validation - requires number', () async {
      final result = await authService.register(
        username: 'testuser',
        email: 'test@example.com',
        password: 'Password',
      );

      expect(result.success, false);
      expect(result.error, contains('number'));
    });

    test('email validation - requires valid format', () async {
      final invalidEmails = [
        'notanemail',
        '@example.com',
        'test@',
        'test@@example.com',
        'test@example',
      ];

      for (final email in invalidEmails) {
        final result = await authService.register(
          username: 'testuser',
          email: email,
          password: 'Password123',
        );

        expect(result.success, false, reason: 'Should fail for email: $email');
        expect(result.error, contains('valid email'), reason: 'Error for email: $email');
      }
    });

    test('username validation - requires minimum length', () async {
      final result = await authService.register(
        username: 'ab',
        email: 'test@example.com',
        password: 'Password123',
      );

      expect(result.success, false);
      expect(result.error, contains('3 characters'));
    });
  });
}
