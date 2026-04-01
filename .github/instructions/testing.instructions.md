---
description: "Use when writing or editing Flutter widget tests, unit tests, or integration tests."
applyTo: "test/**"
---

# Testing Guidelines

## Structure

- Mirror the source tree: `lib/features/foo/bar.dart` → `test/features/foo/bar_test.dart`
- Group related tests with `group()`.
- Use descriptive test names: `'calculates monthly payment for 25-year mortgage at 5.5%'`.

## Unit Tests (Calculators & Services)

- Test happy paths, edge cases (0 values, max values, 1-month periods), and boundary conditions.
- Financial calculations must match the React reference implementation outputs.
- No mocking needed — calculators are pure functions.

## Widget Tests

- Use `pumpWidget()` with necessary providers (Riverpod `ProviderScope`).
- Test user interactions: tap, enter text, scroll.
- Verify rendered text, not implementation details.
- Use `mocktail` for mocking dependencies.

## Running

```bash
flutter test                    # All tests
flutter test test/path/file.dart  # Single file
flutter test --coverage         # With coverage
```
