# Tests

## Running Tests

To run all tests:

```bash
flutter test
```

To run tests with coverage:

```bash
flutter test --coverage
```

## Generating Mocks

The auth_service_test.dart uses mockito for mocking. Before running these tests, you need to generate the mock files:

```bash
flutter pub run build_runner build
```

Or for continuous generation during development:

```bash
flutter pub run build_runner watch
```

This will generate `*.mocks.dart` files for the tests that use the `@GenerateMocks` annotation.

## Test Structure

- `validators_test.dart` - Tests for form validation utilities
- `auth_service_test.dart` - Tests for authentication service
- `user_model_test.dart` - Tests for User model
- `voting_service_test.dart` - Tests for voting service
- `progression_service_test.dart` - Tests for progression service  
- `game_catalog_test.dart` - Tests for game catalog

## Coverage

After running tests with coverage, you can generate an HTML report:

```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```
