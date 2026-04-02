import 'package:flutter_test/flutter_test.dart';

import 'package:buy_or_rent/shared/services/projection_calculator.dart';
import 'package:buy_or_rent/shared/services/round_mode.dart';

void main() {
  // ---------------------------------------------------------------
  // Basic structure
  // ---------------------------------------------------------------
  group('projectGroupedValues — structure', () {
    test('12 periods / 12 per group = 1 group with 12 periods', () {
      final result = projectGroupedValues(
        totalPeriods: 12,
        periodsPerGroup: 12,
        amountForPeriod: constantAmount(1000),
      );

      expect(result.groups.length, 1);
      expect(result.groups.first.periods.length, 12);
      expect(result.groups.first.groupNumber, 1);
    });

    test('36 periods / 12 per group = 3 groups', () {
      final result = projectGroupedValues(
        totalPeriods: 36,
        periodsPerGroup: 12,
        amountForPeriod: constantAmount(1000),
      );

      expect(result.groups.length, 3);
      for (var i = 0; i < 3; i++) {
        expect(result.groups[i].groupNumber, i + 1);
        expect(result.groups[i].periods.length, 12);
      }
    });

    test('partial last group: 14 periods / 12 per group', () {
      final result = projectGroupedValues(
        totalPeriods: 14,
        periodsPerGroup: 12,
        amountForPeriod: constantAmount(1000),
      );

      expect(result.groups.length, 2);
      expect(result.groups[0].periods.length, 12);
      expect(result.groups[1].periods.length, 2);
    });

    test('period numbers are sequential across groups', () {
      final result = projectGroupedValues(
        totalPeriods: 24,
        periodsPerGroup: 12,
        amountForPeriod: constantAmount(500),
      );

      var expected = 1;
      for (final group in result.groups) {
        for (final period in group.periods) {
          expect(period.periodNumber, expected);
          expected++;
        }
      }
      expect(expected, 25); // 24 periods counted
    });
  });

  // ---------------------------------------------------------------
  // Flat projection (no change rates)
  // ---------------------------------------------------------------
  group('projectGroupedValues — flat (no growth)', () {
    test('all periods have the same amount', () {
      final result = projectGroupedValues(
        totalPeriods: 24,
        periodsPerGroup: 12,
        amountForPeriod: constantAmount(2000),
      );

      for (final group in result.groups) {
        for (final period in group.periods) {
          expect(period.periodAmount, 2000.0);
        }
      }
    });

    test('group totals = periodsPerGroup × amount', () {
      final result = projectGroupedValues(
        totalPeriods: 24,
        periodsPerGroup: 12,
        amountForPeriod: constantAmount(2000),
      );

      expect(result.groups[0].groupTotal, 24000.0);
      expect(result.groups[1].groupTotal, 24000.0);
      expect(result.totalAmount, 48000.0);
    });

    test('cumulative totals increase monotonically', () {
      final result = projectGroupedValues(
        totalPeriods: 60,
        periodsPerGroup: 12,
        amountForPeriod: constantAmount(1000),
      );

      for (var i = 1; i < result.groups.length; i++) {
        expect(
          result.groups[i].cumulativeTotal,
          greaterThan(result.groups[i - 1].cumulativeTotal),
        );
      }
    });

    test('totalAmount matches last group cumulativeTotal', () {
      final result = projectGroupedValues(
        totalPeriods: 36,
        periodsPerGroup: 12,
        amountForPeriod: constantAmount(1500),
      );

      expect(result.totalAmount, result.groups.last.cumulativeTotal);
    });
  });

  // ---------------------------------------------------------------
  // Group change rate (cross-group growth)
  // ---------------------------------------------------------------
  group('projectGroupedValues — group change rate', () {
    test('2.5% group change: groups grow over time', () {
      final result = projectGroupedValues(
        totalPeriods: 36,
        periodsPerGroup: 12,
        amountForPeriod: compoundPerGroup(
          firstPeriodAmount: 2000,
          groupChangeRatePercent: 2.5,
        ),
      );

      expect(result.groups[0].groupTotal, closeTo(24000.0, 0.01));
      expect(
        result.groups[1].groupTotal,
        greaterThan(result.groups[0].groupTotal),
      );
      expect(
        result.groups[2].groupTotal,
        greaterThan(result.groups[1].groupTotal),
      );
    });

    test('group 2 amount = firstAmount × 1.025', () {
      final result = projectGroupedValues(
        totalPeriods: 24,
        periodsPerGroup: 12,
        amountForPeriod: compoundPerGroup(
          firstPeriodAmount: 1000,
          groupChangeRatePercent: 2.5,
        ),
      );

      // All periods in group 2 should be 1000 × 1.025 = 1025
      for (final p in result.groups[1].periods) {
        expect(p.periodAmount, closeTo(1025.0, 0.001));
      }
    });

    test('negative group change rate: groups shrink', () {
      final result = projectGroupedValues(
        totalPeriods: 24,
        periodsPerGroup: 12,
        amountForPeriod: compoundPerGroup(
          firstPeriodAmount: 2000,
          groupChangeRatePercent: -5,
        ),
      );

      expect(
        result.groups[1].groupTotal,
        lessThan(result.groups[0].groupTotal),
      );
    });
  });

  // ---------------------------------------------------------------
  // Periodic change rate (within-group growth)
  // ---------------------------------------------------------------
  group('projectGroupedValues — periodic change rate', () {
    test('periods within a group grow when rate > 0', () {
      final result = projectGroupedValues(
        totalPeriods: 12,
        periodsPerGroup: 12,
        amountForPeriod: compoundPerGroupAndPeriod(
          firstPeriodAmount: 1000,
          groupChangeRatePercent: 0,
          periodicChangeRatePercent: 1,
        ),
      );

      final periods = result.groups.first.periods;
      // period 1 = 1000, period 2 = 1000 × 1.01, etc.
      expect(periods.first.periodAmount, 1000.0);
      expect(
        periods.last.periodAmount,
        greaterThan(periods.first.periodAmount),
      );
    });

    test('combined group + periodic rates', () {
      final result = projectGroupedValues(
        totalPeriods: 24,
        periodsPerGroup: 12,
        amountForPeriod: compoundPerGroupAndPeriod(
          firstPeriodAmount: 1000,
          groupChangeRatePercent: 10,
          periodicChangeRatePercent: 1,
        ),
      );

      // Group 2 base = 1000 × 1.10 = 1100
      // First period of group 2 should be ~1100
      expect(
        result.groups[1].periods.first.periodAmount,
        closeTo(1100.0, 0.01),
      );
      // Last period of group 2 should be > 1100 (periodic growth)
      expect(result.groups[1].periods.last.periodAmount, greaterThan(1100.0));
    });
  });

  // ---------------------------------------------------------------
  // Rounding
  // ---------------------------------------------------------------
  group('projectGroupedValues — rounding', () {
    test('cents mode rounds period amounts', () {
      final result = projectGroupedValues(
        totalPeriods: 24,
        periodsPerGroup: 12,
        amountForPeriod: compoundPerGroup(
          firstPeriodAmount: 1000,
          groupChangeRatePercent: 2.5,
          roundMode: RoundMode.cents,
        ),
        roundMode: RoundMode.cents,
      );

      for (final p in result.groups[1].periods) {
        final str = p.periodAmount.toString();
        final decimals = str.contains('.') ? str.split('.').last.length : 0;
        expect(decimals, lessThanOrEqualTo(2));
      }
    });
  });

  // ---------------------------------------------------------------
  // Single-period groups
  // ---------------------------------------------------------------
  group('projectGroupedValues — 1 period per group', () {
    test('each group has exactly 1 period', () {
      final result = projectGroupedValues(
        totalPeriods: 5,
        periodsPerGroup: 1,
        amountForPeriod: compoundPerGroup(
          firstPeriodAmount: 10000,
          groupChangeRatePercent: 3,
        ),
      );

      expect(result.groups.length, 5);
      for (final g in result.groups) {
        expect(g.periods.length, 1);
        expect(g.groupTotal, g.periods.first.periodAmount);
      }
    });

    test('3% group growth: group 4 = 10000 × 1.03^3', () {
      final result = projectGroupedValues(
        totalPeriods: 5,
        periodsPerGroup: 1,
        amountForPeriod: compoundPerGroup(
          firstPeriodAmount: 10000,
          groupChangeRatePercent: 3,
        ),
      );

      expect(
        result.groups[3].periods.first.periodAmount,
        closeTo(10927.27, 0.01),
      );
    });
  });

  // ---------------------------------------------------------------
  // Custom AmountForPeriod callback
  // ---------------------------------------------------------------
  group('projectGroupedValues — custom callback', () {
    test('step function: amount doubles after group 2', () {
      final result = projectGroupedValues(
        totalPeriods: 36,
        periodsPerGroup: 12,
        amountForPeriod: (_, groupNumber, _) =>
            groupNumber <= 2 ? 1000.0 : 2000.0,
      );

      expect(result.groups[0].groupTotal, 12000.0);
      expect(result.groups[1].groupTotal, 12000.0);
      expect(result.groups[2].groupTotal, 24000.0);
    });

    test('per-period function receives correct arguments', () {
      final calls = <List<int>>[];
      projectGroupedValues(
        totalPeriods: 5,
        periodsPerGroup: 3,
        amountForPeriod: (periodNumber, groupNumber, indexInGroup) {
          calls.add([periodNumber, groupNumber, indexInGroup]);
          return 100;
        },
      );

      // Group 1: periods 1,2,3 → indices 0,1,2
      // Group 2: periods 4,5 → indices 0,1
      expect(calls, [
        [1, 1, 0],
        [2, 1, 1],
        [3, 1, 2],
        [4, 2, 0],
        [5, 2, 1],
      ]);
    });
  });
}
