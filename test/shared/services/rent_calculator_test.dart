import 'package:flutter_test/flutter_test.dart';

import 'package:buy_or_rent/shared/models/rent_projection_result.dart';
import 'package:buy_or_rent/shared/services/financial_math.dart';
import 'package:buy_or_rent/shared/services/rent_calculator.dart';
import 'package:buy_or_rent/shared/services/round_mode.dart';
import 'package:buy_or_rent/shared/services/year_compression.dart';

void main() {
  // ---------------------------------------------------------------
  // calculateMonthlyRentForYear
  // ---------------------------------------------------------------
  group('compoundGrowth (rent)', () {
    test('period 0 returns base value unchanged', () {
      final rent = compoundGrowth(
        baseValue: 2000,
        periods: 0,
        annualRatePercent: 2.5,
      );
      expect(rent, 2000.0);
    });

    test('period 1 with 2.5% increase', () {
      final rent = compoundGrowth(
        baseValue: 1000,
        periods: 1,
        annualRatePercent: 2.5,
      );
      expect(rent, closeTo(1025.0, 0.001));
    });

    test('compound growth over multiple periods', () {
      final rent = compoundGrowth(
        baseValue: 1000,
        periods: 2,
        annualRatePercent: 2.5,
      );
      // 1000 × 1.025^2 = 1050.625
      expect(rent, closeTo(1050.625, 0.001));
    });

    test('negative rate (deflation)', () {
      final rent = compoundGrowth(
        baseValue: 1000,
        periods: 1,
        annualRatePercent: -2.5,
      );
      expect(rent, closeTo(975.0, 0.001));
    });

    test('zero rate returns base value for any period', () {
      final rent = compoundGrowth(
        baseValue: 2000,
        periods: 10,
        annualRatePercent: 0,
      );
      expect(rent, 2000.0);
    });

    test('rounds to cents when requested', () {
      final rent = compoundGrowth(
        baseValue: 1000,
        periods: 2,
        annualRatePercent: 2.5,
        roundMode: RoundMode.cents,
      );
      // 1050.625 → 1050.63
      expect(rent, 1050.63);
    });
  });

  // ---------------------------------------------------------------
  // calculateRentProjection — validation
  // ---------------------------------------------------------------
  group('calculateRentProjection — validation', () {
    test('returns null for zero rent', () {
      expect(
        calculateRentProjection(
          monthlyRent: 0,
          analysisYears: 5,
          annualRentIncrease: 2.5,
        ),
        isNull,
      );
    });

    test('returns null for negative rent', () {
      expect(
        calculateRentProjection(
          monthlyRent: -100,
          analysisYears: 5,
          annualRentIncrease: 2.5,
        ),
        isNull,
      );
    });

    test('returns null for zero analysis years', () {
      expect(
        calculateRentProjection(
          monthlyRent: 2000,
          analysisYears: 0,
          annualRentIncrease: 2.5,
        ),
        isNull,
      );
    });

    test('returns null for > 120 years', () {
      expect(
        calculateRentProjection(
          monthlyRent: 2000,
          analysisYears: 121,
          annualRentIncrease: 2.5,
        ),
        isNull,
      );
    });

    test('returns null for invalid increaseMonth', () {
      expect(
        calculateRentProjection(
          monthlyRent: 2000,
          analysisYears: 5,
          annualRentIncrease: 2.5,
          increaseMonth: 0,
        ),
        isNull,
      );
      expect(
        calculateRentProjection(
          monthlyRent: 2000,
          analysisYears: 5,
          annualRentIncrease: 2.5,
          increaseMonth: 13,
        ),
        isNull,
      );
    });
  });

  // ---------------------------------------------------------------
  // calculateRentProjection — core logic
  // ---------------------------------------------------------------
  group('calculateRentProjection — schedule', () {
    test('1 year at 2000 with 0% increase', () {
      final result = calculateRentProjection(
        monthlyRent: 2000,
        analysisYears: 1,
        annualRentIncrease: 0,
        startYear: 2026,
      )!;

      expect(result.years.length, 1);
      expect(result.years.first.year, 2026);
      expect(result.years.first.months, everyElement(2000.0));
      expect(result.years.first.yearTotal, 24000.0);
      expect(result.totalPaid, 24000.0);
    });

    test('3 years with 2.5% increase: year totals grow', () {
      final result = calculateRentProjection(
        monthlyRent: 2000,
        analysisYears: 3,
        annualRentIncrease: 2.5,
        startYear: 2026,
      )!;

      expect(result.years.length, 3);
      expect(result.years[0].yearTotal, closeTo(24000.0, 0.01));
      expect(result.years[1].yearTotal, greaterThan(result.years[0].yearTotal));
      expect(result.years[2].yearTotal, greaterThan(result.years[1].yearTotal));
    });

    test('cumulative totals are strictly increasing', () {
      final result = calculateRentProjection(
        monthlyRent: 1500,
        analysisYears: 10,
        annualRentIncrease: 3,
        startYear: 2026,
      )!;

      for (var i = 1; i < result.years.length; i++) {
        expect(
          result.years[i].cumulativeTotal,
          greaterThan(result.years[i - 1].cumulativeTotal),
        );
      }
    });

    test('totalPaid matches last year cumulative total', () {
      final result = calculateRentProjection(
        monthlyRent: 2000,
        analysisYears: 25,
        annualRentIncrease: 2.5,
        startYear: 2026,
      )!;

      expect(result.totalPaid, result.years.last.cumulativeTotal);
    });

    test('each year has exactly 12 months', () {
      final result = calculateRentProjection(
        monthlyRent: 2000,
        analysisYears: 5,
        annualRentIncrease: 2.5,
        startYear: 2026,
      )!;

      for (final year in result.years) {
        expect(year.months.length, 12);
      }
    });

    test('negative increase: rent decreases over time', () {
      final result = calculateRentProjection(
        monthlyRent: 2000,
        analysisYears: 3,
        annualRentIncrease: -5,
        startYear: 2026,
      )!;

      expect(result.years[1].yearTotal, lessThan(result.years[0].yearTotal));
    });
  });

  // ---------------------------------------------------------------
  // calculateRentProjection — anniversary (increaseMonth)
  // ---------------------------------------------------------------
  group('calculateRentProjection — increaseMonth', () {
    test('increase in July (month 7): year 0 is flat', () {
      final result = calculateRentProjection(
        monthlyRent: 1000,
        analysisYears: 3,
        annualRentIncrease: 10,
        startYear: 2026,
        increaseMonth: 7,
      )!;

      // Year 0: all months = 1000
      expect(result.years[0].months, everyElement(1000.0));
    });

    test('increase in July: year 1 splits at month 7', () {
      final result = calculateRentProjection(
        monthlyRent: 1000,
        analysisYears: 3,
        annualRentIncrease: 10,
        startYear: 2026,
        increaseMonth: 7,
      )!;

      final year1Months = result.years[1].months;
      // Months 1–6 (indices 0–5): still $1000
      for (var i = 0; i < 6; i++) {
        expect(year1Months[i], 1000.0);
      }
      // Months 7–12 (indices 6–11): $1100
      for (var i = 6; i < 12; i++) {
        expect(year1Months[i], closeTo(1100.0, 0.01));
      }
    });

    test('increase in January (month 1) behaves like no-increaseMonth', () {
      final withMonth = calculateRentProjection(
        monthlyRent: 2000,
        analysisYears: 5,
        annualRentIncrease: 2.5,
        startYear: 2026,
        increaseMonth: 1,
      )!;

      final standard = calculateRentProjection(
        monthlyRent: 2000,
        analysisYears: 5,
        annualRentIncrease: 2.5,
        startYear: 2026,
      )!;

      // After year 0, each year's months should match because
      // increaseMonth=1 means all 12 months get the new rate.
      for (var y = 1; y < 5; y++) {
        for (var m = 0; m < 12; m++) {
          expect(
            withMonth.years[y].months[m],
            closeTo(standard.years[y].months[m], 0.01),
          );
        }
      }
    });
  });

  // ---------------------------------------------------------------
  // compressYearData
  // ---------------------------------------------------------------
  group('compressYearData', () {
    late List<RentYear> tenYears;

    setUp(() {
      final result = calculateRentProjection(
        monthlyRent: 2000,
        analysisYears: 10,
        annualRentIncrease: 2.5,
        startYear: 2026,
      )!;
      tenYears = result.years;
    });

    test('no compression when years <= maxRows', () {
      final rows = compressYearData(years: tenYears, maxRows: 15);
      expect(rows.length, 10);
      expect(rows.first.yearRange, '2026');
      expect(rows.last.yearRange, '2035');
    });

    test('compresses 10 years into 5 rows (2 per group)', () {
      final rows = compressYearData(years: tenYears, maxRows: 5);
      expect(rows.length, 5);
      expect(rows.first.yearRange, '2026-2027');
      expect(rows.last.yearRange, '2034-2035');
    });

    test('maxRows=0 aggregates all into single row', () {
      final rows = compressYearData(years: tenYears, maxRows: 0);
      expect(rows.length, 1);
      expect(rows.first.yearRange, '2026-2035');
      expect(rows.first.cumulativeTotal, tenYears.last.cumulativeTotal);
    });

    test('last row cumulative matches input last year', () {
      final rows = compressYearData(years: tenYears, maxRows: 3);
      expect(
        rows.last.cumulativeTotal,
        closeTo(tenYears.last.cumulativeTotal, 0.01),
      );
    });

    test('empty input returns empty list', () {
      final rows = compressYearData(years: [], maxRows: 5);
      expect(rows, isEmpty);
    });

    test('single year produces single row', () {
      final rows = compressYearData(years: [tenYears.first], maxRows: 5);
      expect(rows.length, 1);
      expect(rows.first.yearRange, '2026');
    });
  });
}
