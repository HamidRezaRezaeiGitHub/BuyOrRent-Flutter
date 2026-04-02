import '../models/projection_result.dart';
import 'financial_math.dart';
import 'projection_calculator.dart';
import 'round_mode.dart';

/// Project monthly rent over [analysisYears] with annual compound
/// increases.
///
/// Returns `null` when inputs are invalid.
///
/// When [increaseMonth] is provided (1–12), the annual increase takes
/// effect starting in that month within each year, modeling real-world
/// lease anniversaries that don't align with January.
///
/// This is a thin domain wrapper around [projectGroupedValues].
ProjectionResult? projectMonthlyRent({
  required double monthlyRent,
  required int analysisYears,
  required double annualRentIncrease,
  RoundMode roundMode = RoundMode.none,
  int? increaseMonth,
}) {
  // --- Domain validation ---
  if (monthlyRent <= 0 || analysisYears <= 0) return null;
  if (analysisYears > 120) return null;
  if (increaseMonth != null && (increaseMonth < 1 || increaseMonth > 12)) {
    return null;
  }

  final AmountForPeriod amountFn;

  if (increaseMonth == null) {
    // Standard: flat within each year, compound across years.
    amountFn = compoundPerGroup(
      firstPeriodAmount: monthlyRent,
      groupChangeRatePercent: annualRentIncrease,
      roundMode: roundMode,
    );
  } else {
    // Mid-year increase: months before increaseMonth use the
    // prior year's rate, months from increaseMonth onward use
    // the current year's rate.
    amountFn = _midYearIncrease(
      monthlyRent: monthlyRent,
      annualRentIncrease: annualRentIncrease,
      increaseMonth: increaseMonth,
      roundMode: roundMode,
    );
  }

  return projectGroupedValues(
    totalPeriods: analysisYears * 12,
    periodsPerGroup: 12,
    amountForPeriod: amountFn,
    roundMode: roundMode,
  );
}

/// Build an [AmountForPeriod] that splits each year at
/// [increaseMonth].
AmountForPeriod _midYearIncrease({
  required double monthlyRent,
  required double annualRentIncrease,
  required int increaseMonth,
  required RoundMode roundMode,
}) {
  return (_, groupNumber, indexInGroup) {
    final monthInYear = indexInGroup + 1; // 1-based

    if (groupNumber == 1) {
      // First year: always base rent.
      return roundMoney(monthlyRent, roundMode);
    }

    // Before the anniversary month: use prior year's rate.
    if (monthInYear < increaseMonth) {
      return compoundGrowth(
        baseValue: monthlyRent,
        periods: groupNumber - 2,
        ratePercent: annualRentIncrease,
        roundMode: roundMode,
      );
    }

    // From the anniversary month onward: use current year's rate.
    return compoundGrowth(
      baseValue: monthlyRent,
      periods: groupNumber - 1,
      ratePercent: annualRentIncrease,
      roundMode: roundMode,
    );
  };
}
