/// One year of rent data with per-month breakdown.
class RentYear {
  /// Calendar year (e.g. 2026).
  final int year;

  /// Monthly rent amounts for each of the 12 months.
  final List<double> months;

  /// Total rent paid in this year.
  final double yearTotal;

  /// Cumulative rent paid from the start through this year.
  final double cumulativeTotal;

  const RentYear({
    required this.year,
    required this.months,
    required this.yearTotal,
    required this.cumulativeTotal,
  });

  @override
  String toString() =>
      'RentYear(year: $year, yearTotal: $yearTotal, '
      'cumulative: $cumulativeTotal)';
}

/// Full result of a rent projection calculation.
class RentProjectionResult {
  /// Year-by-year rent data.
  final List<RentYear> years;

  /// Grand total rent paid across all years.
  final double totalPaid;

  const RentProjectionResult({required this.years, required this.totalPaid});

  @override
  String toString() =>
      'RentProjectionResult(years: ${years.length}, '
      'totalPaid: $totalPaid)';
}
