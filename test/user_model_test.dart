/**
 * Tests for User model
 * Testing JSON serialization/deserialization and model properties
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_wars/models/models.dart';

void main() {
  group('User Model', () {
    test('creates User from valid JSON', () {
      final json = {
        'id': '123',
        'username': 'testuser',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'avatar': '🧠',
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      final user = User.fromJson(json);

      expect(user.id, equals('123'));
      expect(user.username, equals('testuser'));
      expect(user.email, equals('test@example.com'));
      expect(user.displayName, equals('Test User'));
      expect(user.avatar, equals('🧠'));
      expect(user.createdAt, isNotNull);
    });

    test('creates User from JSON with optional fields', () {
      final json = {
        'id': '123',
        'username': 'testuser',
        'email': 'test@example.com',
      };

      final user = User.fromJson(json);

      expect(user.id, equals('123'));
      expect(user.username, equals('testuser'));
      expect(user.email, equals('test@example.com'));
      expect(user.displayName, isNull);
      expect(user.avatar, isNull);
      expect(user.createdAt, isNull);
    });

    test('converts User to JSON', () {
      final user = User(
        id: '123',
        username: 'testuser',
        email: 'test@example.com',
        displayName: 'Test User',
        avatar: '🎮',
      );

      final json = user.toJson();

      expect(json['id'], equals('123'));
      expect(json['username'], equals('testuser'));
      expect(json['email'], equals('test@example.com'));
      expect(json['displayName'], equals('Test User'));
      expect(json['avatar'], equals('🎮'));
    });

    test('copyWith creates a new User with updated fields', () {
      final user = User(
        id: '123',
        username: 'testuser',
        email: 'test@example.com',
      );

      final updatedUser = user.copyWith(
        displayName: 'New Name',
        avatar: '🏆',
      );

      expect(updatedUser.id, equals('123'));
      expect(updatedUser.username, equals('testuser'));
      expect(updatedUser.email, equals('test@example.com'));
      expect(updatedUser.displayName, equals('New Name'));
      expect(updatedUser.avatar, equals('🏆'));
    });

    test('copyWith without arguments returns identical User', () {
      final user = User(
        id: '123',
        username: 'testuser',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      final copiedUser = user.copyWith();

      expect(copiedUser.id, equals(user.id));
      expect(copiedUser.username, equals(user.username));
      expect(copiedUser.email, equals(user.email));
      expect(copiedUser.displayName, equals(user.displayName));
    });
  });
}
