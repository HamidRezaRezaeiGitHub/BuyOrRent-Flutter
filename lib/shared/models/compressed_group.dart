/// A compressed row representing one or more consecutive groups.
///
/// Used for display when the number of groups exceeds available
/// screen rows. Contains the group number range and aggregated totals.
class CompressedGroup {
  /// First group number in this compressed row (1-based).
  final int startGroupNumber;

  /// Last group number in this compressed row (1-based).
  final int endGroupNumber;

  /// Sum of all group totals in this range.
  final double total;

  /// Cumulative total through the last group in this range.
  final double cumulativeTotal;

  const CompressedGroup({
    required this.startGroupNumber,
    required this.endGroupNumber,
    required this.total,
    required this.cumulativeTotal,
  });

  @override
  String toString() =>
      'CompressedGroup($startGroupNumber-$endGroupNumber: '
      'total=$total, cumulative=$cumulativeTotal)';
}
