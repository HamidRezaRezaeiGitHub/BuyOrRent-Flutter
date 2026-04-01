---
description: "Review the entire project codebase and create GitHub issues for the next development tasks."
---

# Project Review & Next-Steps Issue Creation

You are a senior Flutter engineer performing a full project review of BuyOrRent — a financial decision-support Flutter app for Canadians comparing renting vs. buying a home.

## Your Task

1. **Explore the entire codebase** — read every file under `lib/`, `test/`, `.github/`, `pubspec.yaml`, and `analysis_options.yaml`.
2. **Understand the intent** — the app is a Flutter rewrite of an existing React app in `_reference_old_react_app/` (consult it for business logic, UX flow, and data models).
3. **Identify missing or incomplete code-level work** — features not yet built, tests missing, architectural gaps, configuration that needs to be done inside the codebase. **Do not create tickets for things the developer must do outside the codebase** (e.g., App Store submissions, keystore management, Apple Developer Portal registration).
4. **Create one GitHub issue per task** using the `create_issue` tool (or the GitHub API).

## Issue Format

Each issue must follow this structure:

```
Title: [Area] Short imperative description
Body:
## Context
Why this matters for the project.

## Acceptance Criteria
- [ ] Concrete, testable criterion 1
- [ ] Criterion 2

## References
- Link to relevant file/section in this repo or the reference React app if applicable.

Labels: one of [feature, enhancement, bug, test, chore, architecture]
```

## Scope of Review — Areas to Cover

Go through each area below and create an issue for every gap you find:

### 1. Features — `lib/features/`
- `landing/` — Is the landing screen implemented with correct hero copy, CTA button, and navigation?
- `questionnaire/` — Is the multi-step questionnaire flow implemented (rent inputs, purchase inputs, investment inputs)?
- `results/` — Is the results dashboard with charts implemented?

### 2. Shared Services — `lib/shared/services/`
- Is `MortgageAmortizationCalculator` implemented (matching the React reference)?
- Is `MonthlyRentCalculator` implemented (matching the React reference)?
- Are there any other missing calculators (e.g., investment opportunity cost, net worth comparison)?

### 3. Shared Models — `lib/shared/models/`
- Are all data models defined (e.g., `RentInputs`, `PurchaseInputs`, `InvestmentInputs`, `AmortizationSchedule`, `ResultsSummary`)?

### 4. Config — `lib/shared/config/`
- Are Canada-specific field limits and defaults defined (min/max/default for all financial fields)?

### 5. State Management — Riverpod providers
- Are providers defined for questionnaire state, calculator results?

### 6. Routing — `lib/app/router.dart`
- Are all routes defined (landing, questionnaire steps, results)?
- Is deep-linking / named route support in place (important for web)?

### 7. Tests — `test/`
- Are unit tests present for all financial calculators?
- Are widget tests present for all screens?

### 8. CI/CD — `.github/workflows/`
- Is a CI workflow present to run `flutter test` and `flutter analyze` on PRs?
- Is there a build workflow for Android (AAB) and iOS (IPA)?

### 9. Theming & UX
- Is the Material 3 theme configured with the app's colour palette?
- Is the responsive layout (mobile < 600, tablet < 1024, desktop >= 1024) applied?
- Are app icons and splash screen configured?

### 10. Web
- Is the `web/manifest.json` configured with the correct app name/icons?
- Is there a deployment pipeline for the web build?

## Important Constraints

- Only create issues for **code-level** work (writing Dart/Flutter code, adding tests, creating CI workflows, updating config files).
- Do **not** create issues for: App Store / Play Store submissions, certificate management, Apple/Google account setup, or Firebase project creation.
- Keep issues focused and independently actionable.
- Prioritise issues logically (core features before polish).
