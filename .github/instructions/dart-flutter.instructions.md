---
description: "Use when writing or editing Dart/Flutter source files. Covers Flutter coding standards, widget patterns, and Dart idioms."
applyTo: "**/*.dart"
---

# Flutter / Dart Code Standards

## Widget Guidelines

- Prefer `StatelessWidget` unless local mutable state is needed.
- Keep `build()` methods small — extract sub-widgets as private classes or separate files.
- Always use `const` constructors when all fields are final/immutable.
- Use `Key` parameters in lists and dynamic widget trees.

## State Management (Riverpod)

- Define providers in the same feature folder they belong to.
- Use `ref.watch()` in build methods, `ref.read()` for event handlers.
- Prefer `NotifierProvider` / `AsyncNotifierProvider` over raw `StateProvider` for complex state.
- Never access providers outside the widget tree or provider scope (no global access).

## Routing (GoRouter)

- Define routes in `lib/app/router.dart`.
- Use named routes with path parameters for shareable URLs (important for web platform).
- Use `context.go()` for navigation, `context.push()` for stacking.

## Error Handling

- Validate user inputs at the form/widget level before passing to calculators.
- Financial calculators should assert preconditions rather than returning error types — they receive already-validated data.
- Use `try/catch` only at I/O boundaries (no I/O in this app currently, but future-proof).

## Formatting

- Run `dart format .` before committing.
- Line length: 80 characters (Dart default).
- Trailing commas on all multi-line parameter lists.
