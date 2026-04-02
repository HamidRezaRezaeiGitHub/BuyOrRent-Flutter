---
description: "Use when implementing financial calculators, mortgage amortization, rent projections, or any business logic involving money. Covers calculation patterns and Canada-specific rules."
---

# Financial Calculator Guidelines

## Reference Implementation

The old React app at `_reference_old_react_app/src/services/` contains the reference calculators:

- `MortgageAmortizationCalculator` — mortgage payment schedule
- `MonthlyRentCalculator` — rent projection over time

Always consult these for exact formulas before implementing or modifying calculators.

## Architecture

### Layered approach (generic → domain)

```
financial_math.dart          Pure math: compoundGrowth(), calculatePeriodicPayment()
         ↓
projection_calculator.dart   Generic engine: projectGroupedValues(amountForPeriod: ...)
                             + factory helpers: constantAmount(), compoundPerGroup(), etc.
         ↓
rent_calculator.dart         Thin domain wrapper: validation + callback selection
mortgage_calculator.dart     Domain calculator (different shape: principal/interest split)
```

### Generic models

| Model                  | Purpose                                                         |
| ---------------------- | --------------------------------------------------------------- |
| `PeriodicValue`        | One atomic period: periodNumber, periodAmount, cumulativeAmount |
| `GroupedPeriodicValue` | A group of periods with groupTotal and cumulativeTotal          |
| `ProjectionResult`     | List of groups + grand totalAmount                              |
| `CompressedGroup`      | Display-compressed range of groups                              |

### Projection engine pattern

All "value over time" projections go through `projectGroupedValues()`. It takes a callback:

```dart
typedef AmountForPeriod = double Function(
  int periodNumber,   // 1-based, global
  int groupNumber,    // 1-based
  int indexInGroup,   // 0-based within group
);
```

**Use factory helpers** for common patterns:

- `constantAmount(amount)` — flat, no growth
- `compoundPerGroup(firstPeriodAmount, groupChangeRatePercent)` — flat within group, compound across groups (e.g. rent with annual increases)
- `compoundPerGroupAndPeriod(...)` — compound both dimensions

**Write a custom closure** only when no factory fits (e.g. mid-group splits, step functions).

### Domain wrappers

Domain calculators (`rent_calculator.dart`, etc.) are **thin wrappers** that:

1. Validate domain constraints (return `null` for invalid inputs)
2. Choose the right `AmountForPeriod` callback (factory or custom)
3. Delegate to `projectGroupedValues()`

They must **never duplicate the projection loop**. If a new domain pattern doesn't fit existing factories, write a new `AmountForPeriod` factory or closure — not a new loop.

### Mortgage amortization

`mortgage_calculator.dart` is kept separate — it produces a fundamentally different shape (principal/interest split per period with a declining balance). It uses `calculatePeriodicPayment()` from `financial_math.dart`.

## Rules

1. **Pure functions** — no side effects, no I/O, no state mutation. Input → output.
2. **Decimal precision** — use `double` for calculations; round only for display (2 decimal places for currency, 4 for rates). Use `RoundMode` enum.
3. **Canada-specific defaults** — all min/max/default values come from `lib/shared/config/`. Don't hardcode financial constants in calculator files.
4. **Abstract naming** — generic utilities use "period", "group", "rate". Domain terms ("month", "year", "rent", "annual") only in domain wrappers. Doc comment examples with "e.g." are fine.
5. **Unit tests are mandatory** — every calculator function must have corresponding unit tests covering edge cases (zero values, max values, single-period groups, etc.).

## Config Values (Canada)

Reference: `_reference_old_react_app/src/config/`

| Field              | Min   | Max     | Default |
| ------------------ | ----- | ------- | ------- |
| Monthly Rent       | $0    | $10,000 | $2,000  |
| Rent Increase Rate | 0%    | 20%     | 2.5%    |
| Purchase Price     | $100K | $3M     | $600K   |
| Mortgage Rate      | 0%    | 15%     | 5.5%    |
| Mortgage Length    | 1yr   | 40yr    | 25yr    |
| Down Payment       | 0%    | 100%    | 20%     |
| Closing Costs      | 0%    | 5%      | 1.5%    |
| Property Tax       | 0%    | 5%      | 0.75%   |
| Maintenance        | 0%    | 10%     | 1%      |
| Asset Appreciation | -5%   | 20%     | 3%      |
| Investment Return  | -20%  | 100%    | 7.5%    |
