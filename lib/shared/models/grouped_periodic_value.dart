import 'periodic_value.dart';

/// A group of consecutive [PeriodicValue]s with aggregated totals.
///
/// Models a logical grouping such as "12 months within a year" or
/// "4 quarters within a year." Each group contains its sub-period
/// breakdown plus summary totals.
///
/// [groupNumber] is 1-based within the overall projection.
class GroupedPeriodicValue {
  /// Position of this group in the projection (1-based).
  final int groupNumber;

  /// The individual periods that make up this group.
  final List<PeriodicValue> periods;

  /// Sum of all [PeriodicValue.periodAmount]s in this group.
  final double groupTotal;

  /// Running total from group 1 through this group.
  final double cumulativeTotal;

  const GroupedPeriodicValue({
    required this.groupNumber,
    required this.periods,
    required this.groupTotal,
    required this.cumulativeTotal,
  });

  @override
  String toString() =>
      'GroupedPeriodicValue(#$groupNumber: total=$groupTotal, '
      'cumulative=$cumulativeTotal, periods=${periods.length})';
}
