import 'dart:math' as math;

import '../models/grouped_periodic_value.dart';
import '../models/periodic_value.dart';
import '../models/projection_result.dart';
import 'financial_math.dart';
import 'round_mode.dart';

/// Signature for a function that determines each period's amount.
///
/// Receives the 1-based [periodNumber] (global across all groups),
/// the 1-based [groupNumber], and the 0-based [indexInGroup].
/// Returns the monetary amount for that period.
typedef AmountForPeriod =
    double Function(int periodNumber, int groupNumber, int indexInGroup);

// ---------------------------------------------------------------
// Core engine
// ---------------------------------------------------------------

/// Project a repeating periodic value over time, grouped into
/// fixed-size chunks.
///
/// [amountForPeriod] — called once per period to get its amount.
/// The callback receives (periodNumber, groupNumber, indexInGroup)
/// so it can implement any logic: constant, compound growth,
/// mid-group splits, step functions, etc.
///
/// [totalPeriods] — total number of atomic periods (e.g. 300 months).
/// [periodsPerGroup] — how many periods per group (e.g. 12 for annual).
///
/// Callers must validate domain constraints before calling.
ProjectionResult projectGroupedValues({
  required int totalPeriods,
  required int periodsPerGroup,
  required AmountForPeriod amountForPeriod,
  RoundMode roundMode = RoundMode.none,
}) {
  assert(totalPeriods > 0, 'totalPeriods must be positive');
  assert(periodsPerGroup > 0, 'periodsPerGroup must be positive');

  final totalGroups = (totalPeriods / periodsPerGroup).ceil();
  final groups = <GroupedPeriodicValue>[];
  var overallCumulative = 0.0;
  var periodCounter = 0;

  for (var g = 0; g < totalGroups; g++) {
    final periodsInGroup = math.min(
      periodsPerGroup,
      totalPeriods - g * periodsPerGroup,
    );

    final periods = <PeriodicValue>[];
    var groupTotal = 0.0;

    for (var p = 0; p < periodsInGroup; p++) {
      periodCounter++;

      final amount = amountForPeriod(periodCounter, g + 1, p);

      groupTotal = roundMoney(groupTotal + amount, roundMode);

      periods.add(
        PeriodicValue(
          periodNumber: periodCounter,
          periodAmount: amount,
          cumulativeAmount: roundMoney(
            overallCumulative + groupTotal,
            roundMode,
          ),
        ),
      );
    }

    overallCumulative = roundMoney(overallCumulative + groupTotal, roundMode);

    groups.add(
      GroupedPeriodicValue(
        groupNumber: g + 1,
        periods: periods,
        groupTotal: groupTotal,
        cumulativeTotal: overallCumulative,
      ),
    );
  }

  return ProjectionResult(groups: groups, totalAmount: overallCumulative);
}

// ---------------------------------------------------------------
// AmountForPeriod factories — common patterns
// ---------------------------------------------------------------

/// Constant amount every period (no growth).
AmountForPeriod constantAmount(
  double amount, {
  RoundMode roundMode = RoundMode.none,
}) {
  final rounded = roundMoney(amount, roundMode);
  return (_, _, _) => rounded;
}

/// Flat within each group, compound growth across groups.
///
/// Group 1 = [firstPeriodAmount], group 2 = first × (1 + rate%)^1, etc.
/// This is the most common pattern (e.g. rent with annual increases).
AmountForPeriod compoundPerGroup({
  required double firstPeriodAmount,
  required double groupChangeRatePercent,
  RoundMode roundMode = RoundMode.none,
}) {
  return (_, groupNumber, _) => compoundGrowth(
    baseValue: firstPeriodAmount,
    periods: groupNumber - 1,
    ratePercent: groupChangeRatePercent,
    roundMode: roundMode,
  );
}

/// Compound growth both across groups and within each group.
///
/// Group base grows at [groupChangeRatePercent] per group boundary.
/// Within each group, periods grow at [periodicChangeRatePercent].
AmountForPeriod compoundPerGroupAndPeriod({
  required double firstPeriodAmount,
  required double groupChangeRatePercent,
  double periodicChangeRatePercent = 0,
  RoundMode roundMode = RoundMode.none,
}) {
  return (_, groupNumber, indexInGroup) {
    final groupBase = compoundGrowth(
      baseValue: firstPeriodAmount,
      periods: groupNumber - 1,
      ratePercent: groupChangeRatePercent,
      roundMode: roundMode,
    );
    if (periodicChangeRatePercent == 0) return groupBase;
    return compoundGrowth(
      baseValue: groupBase,
      periods: indexInGroup,
      ratePercent: periodicChangeRatePercent,
      roundMode: roundMode,
    );
  };
}
