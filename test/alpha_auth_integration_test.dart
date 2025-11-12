/**
 * Alpha Mode Authentication Integration Tests
 * Tests the complete authentication flow in alpha mode
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mind_wars/services/auth_service.dart';
import 'package:mind_wars/services/local_auth_service.dart';
import 'package:mind_wars/services/api_service.dart';
import 'package:mind_wars/services/offline_service.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Alpha Mode Authentication Integration Tests', () {
    late Database database;
    late LocalAuthService localAuthService;
    late ApiService apiService;
    late AuthService authService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      
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
      
      localAuthService = LocalAuthService(database: database);
      apiService = ApiService(baseUrl: 'https://api.mindwars.app');
      
      // Create AuthService in alpha mode
      authService = AuthService(
        apiService: apiService,
        localAuthService: localAuthService,
        isAlphaMode: true,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('alpha mode flag is set correctly', () {
      expect(authService.isAlphaMode, true);
    });

    test('complete registration flow in alpha mode', () async {
      // Register a new user
      final result = await authService.register(
        username: 'alphauser',
        email: 'alpha@example.com',
        password: 'TestPass123',
      );

      // Verify registration succeeded
      expect(result.success, true);
      expect(result.user, isNotNull);
      expect(result.user?.username, 'alphauser');
      expect(result.user?.email, 'alpha@example.com');
      
      // Verify user is authenticated
      expect(authService.isAuthenticated, true);
      expect(authService.currentUser, isNotNull);
    });

    test('complete login flow in alpha mode', () async {
      // First, register a user
      await authService.register(
        username: 'loginuser',
        email: 'login@example.com',
        password: 'TestPass123',
      );

      // Logout
      await authService.logout();
      expect(authService.isAuthenticated, false);

      // Login with the same credentials
      final result = await authService.login(
        email: 'login@example.com',
        password: 'TestPass123',
        autoLogin: true,
      );

      // Verify login succeeded
      expect(result.success, true);
      expect(result.user, isNotNull);
      expect(result.user?.email, 'login@example.com');
      expect(authService.isAuthenticated, true);
    });

    test('auto-login flow with session restoration', () async {
      // Register with auto-login enabled
      await authService.register(
        username: 'autouser',
        email: 'auto@example.com',
        password: 'TestPass123',
      );

      // Login with remember me
      await authService.logout();
      await authService.login(
        email: 'auto@example.com',
        password: 'TestPass123',
        autoLogin: true,
      );

      // Simulate app restart - create new auth service
      final newAuthService = AuthService(
        apiService: apiService,
        localAuthService: localAuthService,
        isAlphaMode: true,
      );

      // Attempt to restore session
      final restored = await newAuthService.restoreSession();

      // Verify session was restored
      expect(restored, true);
      expect(newAuthService.isAuthenticated, true);
      expect(newAuthService.currentUser, isNotNull);
      expect(newAuthService.currentUser?.email, 'auto@example.com');
    });

    test('logout clears authentication state', () async {
      // Register and login
      await authService.register(
        username: 'logoutuser',
        email: 'logout@example.com',
        password: 'TestPass123',
      );

      expect(authService.isAuthenticated, true);

      // Logout
      await authService.logout();

      // Verify state is cleared
      expect(authService.isAuthenticated, false);
      expect(authService.currentUser, isNull);
    });

    test('multiple users can be registered on same device', () async {
      // Register first user
      final result1 = await authService.register(
        username: 'user1',
        email: 'user1@example.com',
        password: 'TestPass123',
      );
      expect(result1.success, true);

      // Logout
      await authService.logout();

      // Register second user
      final result2 = await authService.register(
        username: 'user2',
        email: 'user2@example.com',
        password: 'TestPass456',
      );
      expect(result2.success, true);

      // Verify both users exist in database
      final users = await localAuthService.getUnsyncedUsers();
      expect(users.length, 2);
    });

    test('cannot register duplicate email', () async {
      // Register first user
      await authService.register(
        username: 'user1',
        email: 'duplicate@example.com',
        password: 'TestPass123',
      );

      // Logout
      await authService.logout();

      // Try to register with same email
      final result = await authService.register(
        username: 'user2',
        email: 'duplicate@example.com',
        password: 'TestPass456',
      );

      expect(result.success, false);
      expect(result.error, contains('already registered'));
    });

    test('cannot register duplicate username', () async {
      // Register first user
      await authService.register(
        username: 'duplicateuser',
        email: 'user1@example.com',
        password: 'TestPass123',
      );

      // Logout
      await authService.logout();

      // Try to register with same username
      final result = await authService.register(
        username: 'duplicateuser',
        email: 'user2@example.com',
        password: 'TestPass456',
      );

      expect(result.success, false);
      expect(result.error, contains('already taken'));
    });

    test('login fails with incorrect password', () async {
      // Register a user
      await authService.register(
        username: 'testuser',
        email: 'test@example.com',
        password: 'CorrectPass123',
      );

      // Logout
      await authService.logout();

      // Try to login with wrong password
      final result = await authService.login(
        email: 'test@example.com',
        password: 'WrongPass123',
      );

      expect(result.success, false);
      expect(result.error, contains('Invalid'));
    });

    test('password validation enforced in alpha mode', () async {
      final weakPasswords = [
        'short',          // Too short
        'nouppercase1',   // No uppercase
        'NOLOWERCASE1',   // No lowercase
        'NoNumbers',      // No numbers
      ];

      for (final password in weakPasswords) {
        final result = await authService.register(
          username: 'testuser',
          email: 'test@example.com',
          password: password,
        );

        expect(result.success, false, reason: 'Should fail for: $password');
        expect(result.error, isNotNull, reason: 'Should have error for: $password');
      }
    });

    test('users are marked as unsynced by default', () async {
      // Register a user
      await authService.register(
        username: 'syncuser',
        email: 'sync@example.com',
        password: 'TestPass123',
      );

      // Check unsynced users
      final unsyncedUsers = await localAuthService.getUnsyncedUsers();
      
      expect(unsyncedUsers.length, 1);
      expect(unsyncedUsers[0]['synced'], 0);
      expect(unsyncedUsers[0]['email'], 'sync@example.com');
    });

    test('user can be marked as synced', () async {
      // Register a user
      final result = await authService.register(
        username: 'syncuser',
        email: 'sync@example.com',
        password: 'TestPass123',
      );

      final userId = result.user!.id;

      // Mark as synced
      await localAuthService.markUserAsSynced(userId);

      // Check unsynced users
      final unsyncedUsers = await localAuthService.getUnsyncedUsers();
      
      expect(unsyncedUsers.length, 0);
    });
  });

  group('Production Mode (Non-Alpha) Tests', () {
    test('production mode flag is set correctly', () {
      final apiService = ApiService(baseUrl: 'https://api.mindwars.app');
      final authService = AuthService(
        apiService: apiService,
        isAlphaMode: false,
      );

      expect(authService.isAlphaMode, false);
    });

    // Note: Production mode tests would require mocking API calls
    // These are covered in the existing auth_service_test.dart
  });
}
