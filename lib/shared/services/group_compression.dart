import '../models/compressed_group.dart';
import '../models/grouped_periodic_value.dart';
import 'round_mode.dart';

/// Compress grouped values into at most [maxRows] rows for display.
///
/// Groups consecutive [GroupedPeriodicValue]s when the total count
/// exceeds [maxRows]. If [maxRows] ≤ 0, aggregates everything into
/// a single row.
///
/// Guarantees:
/// - Preserves chronological order.
/// - Last row's [cumulativeTotal] equals the input's last group.
/// - Returns at most [maxRows] rows (fewer if input is shorter).
List<CompressedGroup> compressGroups({
  required List<GroupedPeriodicValue> groups,
  required int maxRows,
  RoundMode roundMode = RoundMode.none,
}) {
  if (groups.isEmpty) return [];

  if (maxRows <= 0) {
    return [
      CompressedGroup(
        startGroupNumber: groups.first.groupNumber,
        endGroupNumber: groups.last.groupNumber,
        total: roundMoney(
          groups.fold(0.0, (sum, g) => sum + g.groupTotal),
          roundMode,
        ),
        cumulativeTotal: roundMoney(groups.last.cumulativeTotal, roundMode),
      ),
    ];
  }

  if (groups.length <= maxRows) {
    return [
      for (final g in groups)
        CompressedGroup(
          startGroupNumber: g.groupNumber,
          endGroupNumber: g.groupNumber,
          total: roundMoney(g.groupTotal, roundMode),
          cumulativeTotal: roundMoney(g.cumulativeTotal, roundMode),
        ),
    ];
  }

  final groupsPerRow = (groups.length / maxRows).ceil();
  final rows = <CompressedGroup>[];

  for (var i = 0; i < groups.length; i += groupsPerRow) {
    final end = (i + groupsPerRow).clamp(0, groups.length);
    final chunk = groups.sublist(i, end);

    rows.add(
      CompressedGroup(
        startGroupNumber: chunk.first.groupNumber,
        endGroupNumber: chunk.last.groupNumber,
        total: roundMoney(
          chunk.fold(0.0, (sum, g) => sum + g.groupTotal),
          roundMode,
        ),
        cumulativeTotal: roundMoney(chunk.last.cumulativeTotal, roundMode),
      ),
    );
  }

  return rows;
}
