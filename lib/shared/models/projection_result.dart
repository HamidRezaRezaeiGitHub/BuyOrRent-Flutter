import 'grouped_periodic_value.dart';

/// The complete result of a grouped periodic-value projection.
///
/// Contains the full breakdown by groups (e.g. years) and the
/// grand total across all periods.
class ProjectionResult {
  /// Group-level breakdown of the projection.
  final List<GroupedPeriodicValue> groups;

  /// Grand total across all periods in all groups.
  final double totalAmount;

  const ProjectionResult({required this.groups, required this.totalAmount});

  @override
  String toString() =>
      'ProjectionResult(groups: ${groups.length}, '
      'total: $totalAmount)';
}
