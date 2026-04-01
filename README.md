# BuyOrRent — Flutter

A financial decision-support app that helps Canadians compare **renting vs. buying** a home. Flutter rewrite of the [original React app](https://github.com/HamidRezaRezaeiGitHub/BuyOrRent).

## Platforms

- iOS
- Android
- Web

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.41 / Dart 3.11 |
| State Management | Riverpod |
| Routing | GoRouter |
| Charting | fl_chart |
| Theming | Material 3 |
| Testing | flutter_test + mocktail |

## Quick Start

```bash
flutter pub get          # Install dependencies
flutter run -d chrome    # Run on web
flutter test             # Run tests
flutter analyze          # Lint check
```

## Project Structure

```
lib/
├── app/           # App widget, router, theme
├── features/      # Feature modules (landing, questionnaire, results)
└── shared/        # Models, services, widgets, config
```

## Reference

The original React codebase is cloned at `_reference_old_react_app/` (git-ignored) for formula and UX reference.
