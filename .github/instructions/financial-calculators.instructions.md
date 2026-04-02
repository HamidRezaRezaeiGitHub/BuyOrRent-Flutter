---
description: "Use when implementing financial calculators, mortgage amortization, rent projections, or any business logic involving money. Covers calculation patterns and Canada-specific rules."
---

# Financial Calculator Guidelines

## Reference Implementation

The old React app at `_reference_old_react_app/src/services/` contains the reference calculators:

- `MortgageAmortizationCalculator` — mortgage payment schedule
- `MonthlyRentCalculator` — rent projection over time

Always consult these for exact formulas before implementing or modifying calculators.

## Rules

1. **Pure functions** — no side effects, no I/O, no state mutation. Input → output.
2. **Decimal precision** — use `double` for calculations; round only for display (2 decimal places for currency, 4 for rates).
3. **Canada-specific defaults** — all min/max/default values come from `lib/shared/config/`. Don't hardcode financial constants in calculator files.
4. **Unit tests are mandatory** — every calculator function must have corresponding unit tests covering edge cases (zero values, max values, single-month period, etc.).

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
