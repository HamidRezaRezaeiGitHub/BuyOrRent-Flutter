# BuyOrRent — Flutter Project Instructions

## Project Overview

BuyOrRent is a **financial decision-support app** that helps Canadians compare renting vs. buying a home. It is a Flutter rewrite of an existing React web app. The old React codebase is available at `_reference_old_react_app/` for reference — consult it for business logic, feature specs, and UI patterns when needed.

### Target Platforms

- **iOS** (primary mobile)
- **Android** (primary mobile)
- **Web** (responsive, mirrors old React version)

All three platforms must be considered for every feature. Use platform-adaptive widgets where appropriate.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.41.x (stable) / Dart 3.11.x |
| State Management | Riverpod (flutter_riverpod + riverpod_annotation) |
| Routing | GoRouter (go_router) |
| Forms & Validation | reactive_forms or manual with Dart |
| Charting | fl_chart |
| Theming | Material 3 with custom color scheme |
| Testing | flutter_test + mocktail |

## Architecture

Follow **feature-first** folder structure:

```
lib/
├── app/                  # App-level: main app widget, router, theme
│   ├── app.dart
│   ├── router.dart
│   └── theme.dart
├── features/             # Feature modules (each self-contained)
│   ├── landing/          # Landing / hero page
│   ├── questionnaire/    # Questionnaire flow (rent, purchase, investment inputs)
│   └── results/          # Results dashboard with charts
├── shared/               # Cross-feature shared code
│   ├── models/           # Data classes / domain entities
│   ├── services/         # Business logic (calculators, formatters)
│   ├── widgets/          # Reusable UI components
│   └── config/           # App-wide configuration (Canada field limits, defaults)
└── main.dart             # Entry point
```

### Key Patterns

- **Immutable data models** — use `@freezed` or manual `copyWith` for data classes.
- **Pure calculation functions** — financial calculators must be pure functions with no side effects or I/O. Place them in `shared/services/`.
- **Separation of concerns** — widgets should not contain business logic. Use providers/notifiers for state.
- **Responsive layout** — use `LayoutBuilder` / `MediaQuery` to adapt for mobile vs. web. Breakpoints: mobile < 600, tablet < 1024, desktop >= 1024.
- **Const constructors** — use `const` wherever possible for widget constructors.

## Code Style

- Follow [Effective Dart](https://dart.dev/effective-dart) conventions.
- Use `final` for local variables when possible.
- Prefer named parameters for widgets with more than 2 parameters.
- Use trailing commas for better formatting/diffing.
- Keep files under 300 lines — split larger files into sub-widgets.
- File naming: `snake_case.dart` (Dart convention).

## Testing

- Write widget tests for UI components.
- Write unit tests for all financial calculator functions — these are the core business logic.
- Test files mirror source: `test/features/results/results_test.dart` matches `lib/features/results/`.
- Run: `flutter test`

## Build & Run

```bash
flutter run -d chrome         # Web
flutter run -d <ios_device>   # iOS (requires Xcode)
flutter run -d <android_device>  # Android (requires Android SDK)
flutter test                  # Run all tests
flutter analyze               # Lint check
```

## Reference App

The old React codebase at `_reference_old_react_app/` contains:
- **Business logic** in `src/services/` — mortgage amortization, rent projection calculators
- **Config values** in `src/config/` — Canada-specific min/max/default values for all fields
- **UI flow** in `src/pages/` and `src/components/` — questionnaire steps, results panels
- **Data models** — TypeScript interfaces for all data structures

When implementing features, consult the reference app for exact formulas, validation rules, and UX flow.
