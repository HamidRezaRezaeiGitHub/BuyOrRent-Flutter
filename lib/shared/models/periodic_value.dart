/// A single period's financial value within a projection.
///
/// Represents one atomic time slice — e.g. one month of rent,
/// one month of investment contributions, or one year of
/// property tax.
///
/// [periodNumber] is 1-based within the overall projection.
class PeriodicValue {
  /// Position of this period in the projection (1-based).
  final int periodNumber;

  /// The monetary amount for this period.
  final double periodAmount;

  /// Running total from period 1 through this period.
  final double cumulativeAmount;

  const PeriodicValue({
    required this.periodNumber,
    required this.periodAmount,
    required this.cumulativeAmount,
  });

  @override
  String toString() =>
      'PeriodicValue(#$periodNumber: $periodAmount, '
      'cumulative: $cumulativeAmount)';
}
