import '../models/rent_projection_result.dart';
import 'financial_math.dart';
import 'round_mode.dart';

/// Generate a complete rent projection over [analysisYears].
///
/// Returns `null` when inputs are invalid.
///
/// When [increaseMonth] is provided (1–12), the annual increase takes
/// effect starting in that month within each year:
/// - Months before [increaseMonth]: previous year's rate.
/// - Months from [increaseMonth] onward: current year's rate.
///
/// This models real-world lease anniversaries that don't align with
/// January.
RentProjectionResult? calculateRentProjection({
  required double monthlyRent,
  required int analysisYears,
  required double annualRentIncrease,
  int? startYear,
  RoundMode roundMode = RoundMode.none,
  int? increaseMonth,
}) {
  // --- Validation ---
  if (monthlyRent <= 0 || analysisYears <= 0) return null;
  if (analysisYears > 120) return null;
  if (increaseMonth != null && (increaseMonth < 1 || increaseMonth > 12)) {
    return null;
  }

  final effectiveStartYear = startYear ?? DateTime.now().year;

  final years = <RentYear>[];
  var totalPaid = 0.0;

  for (var i = 0; i < analysisYears; i++) {
    late final List<double> months;
    late final double yearTotal;

    if (increaseMonth == null) {
      // Standard: whole year at the same rate.
      final yearRent = compoundGrowth(
        baseValue: monthlyRent,
        periods: i,
        annualRatePercent: annualRentIncrease,
        roundMode: roundMode,
      );
      months = List<double>.filled(12, yearRent);
      yearTotal = roundMoney(yearRent * 12, roundMode);
    } else if (i == 0) {
      // First year: always base rent for all months.
      final base = roundMoney(monthlyRent, roundMode);
      months = List<double>.filled(12, base);
      yearTotal = roundMoney(base * 12, roundMode);
    } else {
      // Mid-year increase: months before increaseMonth use prior year,
      // months from increaseMonth onward use current year.
      final prevRent = compoundGrowth(
        baseValue: monthlyRent,
        periods: i - 1,
        annualRatePercent: annualRentIncrease,
        roundMode: roundMode,
      );
      final currRent = compoundGrowth(
        baseValue: monthlyRent,
        periods: i,
        annualRatePercent: annualRentIncrease,
        roundMode: roundMode,
      );

      months = [
        for (var m = 1; m <= 12; m++) m < increaseMonth ? prevRent : currRent,
      ];
      yearTotal = roundMoney(months.fold(0.0, (sum, v) => sum + v), roundMode);
    }

    totalPaid = roundMoney(totalPaid + yearTotal, roundMode);

    years.add(
      RentYear(
        year: effectiveStartYear + i,
        months: months,
        yearTotal: yearTotal,
        cumulativeTotal: totalPaid,
      ),
    );
  }

  return RentProjectionResult(years: years, totalPaid: totalPaid);
}
