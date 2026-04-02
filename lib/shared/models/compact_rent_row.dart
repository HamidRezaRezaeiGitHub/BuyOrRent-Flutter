/// A row in a compressed year-range display table.
///
/// Used to show aggregated multi-year data when the number of
/// individual years exceeds the available display rows.
class CompactRentRow {
  /// Display label: a single year ("2026") or range ("2026-2030").
  final String yearRange;

  /// Total rent paid across all years in this row.
  final double total;

  /// Cumulative rent paid from the start through the last year in this row.
  final double cumulativeTotal;

  const CompactRentRow({
    required this.yearRange,
    required this.total,
    required this.cumulativeTotal,
  });
}
