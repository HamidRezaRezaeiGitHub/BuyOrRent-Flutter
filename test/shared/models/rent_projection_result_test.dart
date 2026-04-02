import 'package:flutter_test/flutter_test.dart';

import 'package:buy_or_rent/shared/models/rent_projection_result.dart';

void main() {
  group('RentProjectionResult', () {
    test('cumulative totals accumulate across years', () {
      const year1 = RentYear(
        year: 2026,
        months: [2000, 2000, 2000, 2000, 2000, 2000,
                 2000, 2000, 2000, 2000, 2000, 2000],
        yearTotal: 24000,
        cumulativeTotal: 24000,
      );
      const year2 = RentYear(
        year: 2027,
        months: [2050, 2050, 2050, 2050, 2050, 2050,
                 2050, 2050, 2050, 2050, 2050, 2050],
        yearTotal: 24600,
        cumulativeTotal: 48600,
      );

      const result = RentProjectionResult(
        years: [year1, year2],
        totalPaid: 48600,
      );

      expect(result.years, hasLength(2));
      expect(result.totalPaid, 48600);
      expect(
        result.years.last.cumulativeTotal,
        greaterThan(result.years.first.cumulativeTotal),
      );
    });
  });
}
