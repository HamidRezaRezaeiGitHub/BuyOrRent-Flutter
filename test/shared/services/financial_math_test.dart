import 'package:flutter_test/flutter_test.dart';

import 'package:buy_or_rent/shared/services/financial_math.dart';
import 'package:buy_or_rent/shared/services/round_mode.dart';

void main() {
  // ---------------------------------------------------------------
  // compoundGrowth
  // ---------------------------------------------------------------
  group('compoundGrowth', () {
    test('period 0 returns base value unchanged', () {
      expect(
        compoundGrowth(baseValue: 1000, periods: 0, ratePercent: 10),
        1000.0,
      );
    });

    test('single period at 10%', () {
      expect(
        compoundGrowth(baseValue: 1000, periods: 1, ratePercent: 10),
        closeTo(1100.0, 0.001),
      );
    });

    test('multi-period compound: 1000 × 1.10^3 = 1331', () {
      expect(
        compoundGrowth(baseValue: 1000, periods: 3, ratePercent: 10),
        closeTo(1331.0, 0.001),
      );
    });

    test('negative rate shrinks value', () {
      expect(
        compoundGrowth(baseValue: 1000, periods: 1, ratePercent: -10),
        closeTo(900.0, 0.001),
      );
    });

    test('zero rate returns base value for any period', () {
      expect(
        compoundGrowth(baseValue: 500, periods: 100, ratePercent: 0),
        500.0,
      );
    });

    test('rounds to cents when requested', () {
      // 1000 × 1.03^2 = 1060.9
      expect(
        compoundGrowth(
          baseValue: 1000,
          periods: 2,
          ratePercent: 3,
          roundMode: RoundMode.cents,
        ),
        1060.90,
      );
    });
  });

  // ---------------------------------------------------------------
  // calculatePeriodicPayment
  // ---------------------------------------------------------------
  group('calculatePeriodicPayment', () {
    test('zero rate yields simple division', () {
      expect(
        calculatePeriodicPayment(
          principal: 12000,
          periodicRate: 0,
          totalPeriods: 12,
        ),
        1000.0,
      );
    });

    test('standard mortgage: 480k at 5.5%/12 over 300 months ≈ 2947.62', () {
      final payment = calculatePeriodicPayment(
        principal: 480000,
        periodicRate: 5.5 / 12 / 100,
        totalPeriods: 300,
      );
      expect(payment, closeTo(2947.62, 0.01));
    });

    test('short-term loan: 12k at 6%/12 over 12 months', () {
      final payment = calculatePeriodicPayment(
        principal: 12000,
        periodicRate: 6.0 / 12 / 100,
        totalPeriods: 12,
      );
      expect(payment, closeTo(1032.81, 0.01));
    });

    test('no rounding keeps full precision', () {
      final payment = calculatePeriodicPayment(
        principal: 480000,
        periodicRate: 5.5 / 12 / 100,
        totalPeriods: 300,
        roundMode: RoundMode.none,
      );
      // Should have more than 2 decimal places
      final decimals = payment.toString().split('.').last.length;
      expect(decimals, greaterThan(2));
    });

    test('zero principal returns zero', () {
      expect(
        calculatePeriodicPayment(
          principal: 0,
          periodicRate: 0.05,
          totalPeriods: 60,
        ),
        0.0,
      );
    });
  });

  // ---------------------------------------------------------------
  // roundMoney
  // ---------------------------------------------------------------
  group('roundMoney', () {
    test('none mode returns value unchanged', () {
      expect(roundMoney(1234.56789, RoundMode.none), 1234.56789);
    });

    test('cents mode rounds to 2 decimal places', () {
      expect(roundMoney(1234.565, RoundMode.cents), 1234.57);
      expect(roundMoney(1234.564, RoundMode.cents), 1234.56);
    });

    test('already 2 decimals stays the same', () {
      expect(roundMoney(99.99, RoundMode.cents), 99.99);
    });
  });
}
