import '../models/compact_rent_row.dart';
import '../models/rent_projection_result.dart';
import 'round_mode.dart';

/// Compress year data into at most [maxRows] rows for display.
///
/// Groups consecutive years when the number of years exceeds [maxRows].
/// If [maxRows] ≤ 0, aggregates everything into a single row.
///
/// Guarantees:
/// - Preserves chronological order.
/// - Last row's [cumulativeTotal] equals the input's last year.
/// - Returns at most [maxRows] rows (fewer if input is shorter).
List<CompactRentRow> compressYearData({
  required List<RentYear> years,
  required int maxRows,
  RoundMode roundMode = RoundMode.none,
}) {
  if (years.isEmpty) return [];

  if (maxRows <= 0) {
    final startYear = years.first.year;
    final endYear = years.last.year;
    return [
      CompactRentRow(
        yearRange: startYear == endYear ? '$startYear' : '$startYear-$endYear',
        total: roundMoney(
          years.fold(0.0, (sum, y) => sum + y.yearTotal),
          roundMode,
        ),
        cumulativeTotal: roundMoney(years.last.cumulativeTotal, roundMode),
      ),
    ];
  }

  if (years.length <= maxRows) {
    return [
      for (final y in years)
        CompactRentRow(
          yearRange: '${y.year}',
          total: roundMoney(y.yearTotal, roundMode),
          cumulativeTotal: roundMoney(y.cumulativeTotal, roundMode),
        ),
    ];
  }

  final yearsPerRow = (years.length / maxRows).ceil();
  final rows = <CompactRentRow>[];

  for (var i = 0; i < years.length; i += yearsPerRow) {
    final end = (i + yearsPerRow).clamp(0, years.length);
    final group = years.sublist(i, end);

    final startYear = group.first.year;
    final endYear = group.last.year;

    rows.add(
      CompactRentRow(
        yearRange: startYear == endYear ? '$startYear' : '$startYear-$endYear',
        total: roundMoney(
          group.fold(0.0, (sum, y) => sum + y.yearTotal),
          roundMode,
        ),
        cumulativeTotal: roundMoney(group.last.cumulativeTotal, roundMode),
      ),
    );
  }

  return rows;
}
