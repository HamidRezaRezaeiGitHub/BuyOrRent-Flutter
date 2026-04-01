---
description: "Use when reviewing the project to plan next steps. Reviews the full codebase, reference React app, and current state, then creates GitHub issues for all remaining work."
agent: "agent"
---

# Project Review & Next Steps

Review the BuyOrRent Flutter project and create GitHub issues for all remaining coding tasks.

## Process

1. **Read the project instructions** at `.github/copilot-instructions.md` to understand architecture, tech stack, and conventions.

2. **Audit current Flutter codebase** — scan `lib/`, `test/`, `pubspec.yaml`, and `analysis_options.yaml` to understand what's already built.

3. **Audit the reference React app** at `_reference_old_react_app/` — review:
   - `src/pages/` and `src/components/` for all features and UI flows
   - `src/services/` for all calculator logic and business rules
   - `src/config/` for field configs and validation rules
   - `src/contexts/` for state management patterns
   - The live app flow: Landing → Questionnaire (rent, purchase, investment) → Results dashboard

4. **Identify gaps** — compare what the React app has vs. what's implemented in Flutter. Focus only on **coding tasks** (not App Store submissions, developer account setup, or other non-code tasks).

5. **Create GitHub issues** using `gh issue create` in the terminal for each task. Each issue should:
   - Have a clear, specific title
   - Include a description with acceptance criteria
   - Use labels: `feature`, `bug`, `calculator`, `ui`, `testing`, `infra` (create labels first if they don't exist)
   - Be scoped to a single deliverable (not epics)
   - Reference the relevant React file(s) when porting logic

6. **Organize by priority** — create issues in this order:
   - Core data models and config
   - Financial calculators (mortgage amortization, rent projection, investment)
   - Questionnaire flow (forms, validation, navigation)
   - Results dashboard (charts, tables, comparison)
   - Theme and responsive layout polish
   - Testing coverage
   - Web-specific features (URL state sharing, SEO)

## Rules

- Only create issues for **code and test work**. Skip infrastructure, deployment, CI/CD, App Store, or any task requiring manual human steps outside the codebase.
- Don't create duplicate issues — check existing issues first with `gh issue list`.
- Keep each issue small enough to be completed in a single coding session.
- Include code snippets or pseudo-code in the description when helpful.
