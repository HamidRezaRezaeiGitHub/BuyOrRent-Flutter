import 'package:flutter_test/flutter_test.dart';

import 'package:buy_or_rent/shared/models/grouped_periodic_value.dart';
import 'package:buy_or_rent/shared/services/rent_calculator.dart';
import 'package:buy_or_rent/shared/services/group_compression.dart';

void main() {
  // ---------------------------------------------------------------
  // projectMonthlyRent — validation
  // ---------------------------------------------------------------
  group('projectMonthlyRent — validation', () {
    test('returns null for zero rent', () {
      expect(
        projectMonthlyRent(
          monthlyRent: 0,
          analysisYears: 5,
          annualRentIncrease: 2.5,
        ),
        isNull,
      );
    });

    test('returns null for negative rent', () {
      expect(
        projectMonthlyRent(
          monthlyRent: -100,
          analysisYears: 5,
          annualRentIncrease: 2.5,
        ),
        isNull,
      );
    });

    test('returns null for zero analysis years', () {
      expect(
        projectMonthlyRent(
          monthlyRent: 2000,
          analysisYears: 0,
          annualRentIncrease: 2.5,
        ),
        isNull,
      );
    });

    test('returns null for > 120 years', () {
      expect(
        projectMonthlyRent(
          monthlyRent: 2000,
          analysisYears: 121,
          annualRentIncrease: 2.5,
        ),
        isNull,
      );
    });

    test('returns null for invalid increaseMonth', () {
      expect(
        projectMonthlyRent(
          monthlyRent: 2000,
          analysisYears: 5,
          annualRentIncrease: 2.5,
          increaseMonth: 0,
        ),
        isNull,
      );
      expect(
        projectMonthlyRent(
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
  // projectMonthlyRent — core logic
  // ---------------------------------------------------------------
  group('projectMonthlyRent — schedule', () {
    test('1 year at 2000 with 0% increase', () {
      final result = projectMonthlyRent(
        monthlyRent: 2000,
        analysisYears: 1,
        annualRentIncrease: 0,
      )!;

      expect(result.groups.length, 1);
      expect(result.groups.first.groupNumber, 1);
      final amounts = result.groups.first.periods
          .map((p) => p.periodAmount)
          .toList();
      expect(amounts, everyElement(2000.0));
      expect(result.groups.first.groupTotal, 24000.0);
      expect(result.totalAmount, 24000.0);
    });

    test('3 years with 2.5% increase: group totals grow', () {
      final result = projectMonthlyRent(
        monthlyRent: 2000,
        analysisYears: 3,
        annualRentIncrease: 2.5,
      )!;

      expect(result.groups.length, 3);
      expect(result.groups[0].groupTotal, closeTo(24000.0, 0.01));
      expect(
        result.groups[1].groupTotal,
        greaterThan(result.groups[0].groupTotal),
      );
      expect(
        result.groups[2].groupTotal,
        greaterThan(result.groups[1].groupTotal),
      );
    });

    test('cumulative totals are strictly increasing', () {
      final result = projectMonthlyRent(
        monthlyRent: 1500,
        analysisYears: 10,
        annualRentIncrease: 3,
      )!;

      for (var i = 1; i < result.groups.length; i++) {
        expect(
          result.groups[i].cumulativeTotal,
          greaterThan(result.groups[i - 1].cumulativeTotal),
        );
      }
    });

    test('totalAmount matches last group cumulativeTotal', () {
      final result = projectMonthlyRent(
        monthlyRent: 2000,
        analysisYears: 25,
        annualRentIncrease: 2.5,
      )!;

      expect(result.totalAmount, result.groups.last.cumulativeTotal);
    });

    test('each group has exactly 12 periods', () {
      final result = projectMonthlyRent(
        monthlyRent: 2000,
        analysisYears: 5,
        annualRentIncrease: 2.5,
      )!;

      for (final group in result.groups) {
        expect(group.periods.length, 12);
      }
    });

    test('negative increase: rent decreases over time', () {
      final result = projectMonthlyRent(
        monthlyRent: 2000,
        analysisYears: 3,
        annualRentIncrease: -5,
      )!;

      expect(
        result.groups[1].groupTotal,
        lessThan(result.groups[0].groupTotal),
      );
    });
  });

  // ---------------------------------------------------------------
  // projectMonthlyRent — anniversary (increaseMonth)
  // ---------------------------------------------------------------
  group('projectMonthlyRent — increaseMonth', () {
    test('increase in July (month 7): year 0 is flat', () {
      final result = projectMonthlyRent(
        monthlyRent: 1000,
        analysisYears: 3,
        annualRentIncrease: 10,
        increaseMonth: 7,
      )!;

      final amounts = result.groups[0].periods
          .map((p) => p.periodAmount)
          .toList();
      expect(amounts, everyElement(1000.0));
    });

    test('increase in July: year 1 splits at month 7', () {
      final result = projectMonthlyRent(
        monthlyRent: 1000,
        analysisYears: 3,
        annualRentIncrease: 10,
        increaseMonth: 7,
      )!;

      final year1 = result.groups[1].periods;
      // Months 1–6 (indices 0–5): still $1000
      for (var i = 0; i < 6; i++) {
        expect(year1[i].periodAmount, 1000.0);
      }
      // Months 7–12 (indices 6–11): $1100
      for (var i = 6; i < 12; i++) {
        expect(year1[i].periodAmount, closeTo(1100.0, 0.01));
      }
    });

    test('increase in January (month 1) behaves like no-increaseMonth', () {
      final withMonth = projectMonthlyRent(
        monthlyRent: 2000,
        analysisYears: 5,
        annualRentIncrease: 2.5,
        increaseMonth: 1,
      )!;

      final standard = projectMonthlyRent(
        monthlyRent: 2000,
        analysisYears: 5,
        annualRentIncrease: 2.5,
      )!;

      for (var g = 1; g < 5; g++) {
        for (var m = 0; m < 12; m++) {
          expect(
            withMonth.groups[g].periods[m].periodAmount,
            closeTo(standard.groups[g].periods[m].periodAmount, 0.01),
          );
        }
      }
    });
  });

  // ---------------------------------------------------------------
  // compressGroups
  // ---------------------------------------------------------------
  group('compressGroups', () {
    late List<GroupedPeriodicValue> tenGroups;

    setUp(() {
      final result = projectMonthlyRent(
        monthlyRent: 2000,
        analysisYears: 10,
        annualRentIncrease: 2.5,
      )!;
      tenGroups = result.groups;
    });

    test('no compression when groups <= maxRows', () {
      final rows = compressGroups(groups: tenGroups, maxRows: 15);
      expect(rows.length, 10);
      expect(rows.first.startGroupNumber, 1);
      expect(rows.first.endGroupNumber, 1);
      expect(rows.last.startGroupNumber, 10);
    });

    test('compresses 10 groups into 5 rows (2 per chunk)', () {
      final rows = compressGroups(groups: tenGroups, maxRows: 5);
      expect(rows.length, 5);
      expect(rows.first.startGroupNumber, 1);
      expect(rows.first.endGroupNumber, 2);
      expect(rows.last.startGroupNumber, 9);
      expect(rows.last.endGroupNumber, 10);
    });

    test('maxRows=0 aggregates all into single row', () {
      final rows = compressGroups(groups: tenGroups, maxRows: 0);
      expect(rows.length, 1);
      expect(rows.first.startGroupNumber, 1);
      expect(rows.first.endGroupNumber, 10);
      expect(rows.first.cumulativeTotal, tenGroups.last.cumulativeTotal);
    });

    test('last row cumulative matches input last group', () {
      final rows = compressGroups(groups: tenGroups, maxRows: 3);
      expect(
        rows.last.cumulativeTotal,
        closeTo(tenGroups.last.cumulativeTotal, 0.01),
      );
    });

    test('empty input returns empty list', () {
      final rows = compressGroups(groups: [], maxRows: 5);
      expect(rows, isEmpty);
    });

    test('single group produces single row', () {
      final rows = compressGroups(groups: [tenGroups.first], maxRows: 5);
      expect(rows.length, 1);
      expect(rows.first.startGroupNumber, 1);
      expect(rows.first.endGroupNumber, 1);
    });
  });
}
