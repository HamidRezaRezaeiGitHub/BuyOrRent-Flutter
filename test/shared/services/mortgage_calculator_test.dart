import 'package:flutter_test/flutter_test.dart';

import 'package:buy_or_rent/shared/services/financial_math.dart';
import 'package:buy_or_rent/shared/services/mortgage_calculator.dart';
import 'package:buy_or_rent/shared/services/round_mode.dart';

void main() {
  // ---------------------------------------------------------------
  // calculateMonthlyPayment
  // ---------------------------------------------------------------
  group('calculatePeriodicPayment', () {
    test('standard 25-year mortgage at 5.5%', () {
      // $600k home, 20% down → $480k loan
      // Monthly rate = 5.5 / 12 / 100 = 0.00458333…
      final payment = calculatePeriodicPayment(
        principal: 480000,
        periodicRate: 5.5 / 12 / 100,
        totalPeriods: 25 * 12,
      );
      // Expected ≈ $2947.62
      expect(payment, closeTo(2947.62, 0.01));
    });

    test('zero interest rate yields simple division', () {
      final payment = calculatePeriodicPayment(
        principal: 120000,
        periodicRate: 0,
        totalPeriods: 120,
      );
      expect(payment, 1000.0);
    });

    test('short 1-year term', () {
      final payment = calculatePeriodicPayment(
        principal: 12000,
        periodicRate: 6.0 / 12 / 100,
        totalPeriods: 12,
      );
      // Should be slightly above $1000 due to interest
      expect(payment, greaterThan(1000));
      expect(payment, closeTo(1032.81, 0.01));
    });

    test('no rounding preserves full precision', () {
      final rounded = calculatePeriodicPayment(
        principal: 480000,
        periodicRate: 5.5 / 12 / 100,
        totalPeriods: 300,
        roundMode: RoundMode.cents,
      );
      final unrounded = calculatePeriodicPayment(
        principal: 480000,
        periodicRate: 5.5 / 12 / 100,
        totalPeriods: 300,
        roundMode: RoundMode.none,
      );
      // Rounded should be a clean 2-decimal number
      expect(rounded, equals((rounded * 100).roundToDouble() / 100));
      // Unrounded may have more decimal digits
      expect(unrounded, closeTo(rounded, 0.01));
    });
  });

  // ---------------------------------------------------------------
  // calculateMortgageAmortization — validation
  // ---------------------------------------------------------------
  group('calculateMortgageAmortization — validation', () {
    test('returns null for zero purchase price', () {
      expect(
        calculateMortgageAmortization(
          purchasePrice: 0,
          downPaymentPercentage: 20,
          annualInterestRate: 5.5,
          amortizationYears: 25,
        ),
        isNull,
      );
    });

    test('returns null for negative purchase price', () {
      expect(
        calculateMortgageAmortization(
          purchasePrice: -100000,
          downPaymentPercentage: 20,
          annualInterestRate: 5.5,
          amortizationYears: 25,
        ),
        isNull,
      );
    });

    test('returns null for zero amortization years', () {
      expect(
        calculateMortgageAmortization(
          purchasePrice: 600000,
          downPaymentPercentage: 20,
          annualInterestRate: 5.5,
          amortizationYears: 0,
        ),
        isNull,
      );
    });

    test('returns null for negative interest rate', () {
      expect(
        calculateMortgageAmortization(
          purchasePrice: 600000,
          downPaymentPercentage: 20,
          annualInterestRate: -1,
          amortizationYears: 25,
        ),
        isNull,
      );
    });

    test('returns null for down payment > 100%', () {
      expect(
        calculateMortgageAmortization(
          purchasePrice: 600000,
          downPaymentPercentage: 101,
          annualInterestRate: 5.5,
          amortizationYears: 25,
        ),
        isNull,
      );
    });

    test('returns null for down payment < 0%', () {
      expect(
        calculateMortgageAmortization(
          purchasePrice: 600000,
          downPaymentPercentage: -1,
          annualInterestRate: 5.5,
          amortizationYears: 25,
        ),
        isNull,
      );
    });
  });

  // ---------------------------------------------------------------
  // calculateMortgageAmortization — core logic
  // ---------------------------------------------------------------
  group('calculateMortgageAmortization — schedule', () {
    test('standard 25-year at 5.5%: schedule has correct length', () {
      final result = calculateMortgageAmortization(
        purchasePrice: 600000,
        downPaymentPercentage: 20,
        annualInterestRate: 5.5,
        amortizationYears: 25,
      )!;

      expect(result.months.length, 300); // 25 × 12
    });

    test('monthly payment matches standalone calculation', () {
      final result = calculateMortgageAmortization(
        purchasePrice: 600000,
        downPaymentPercentage: 20,
        annualInterestRate: 5.5,
        amortizationYears: 25,
      )!;

      final standalone = calculatePeriodicPayment(
        principal: 480000,
        periodicRate: 5.5 / 12 / 100,
        totalPeriods: 300,
      );

      expect(result.monthlyPayment, standalone);
    });

    test('final month balance is exactly zero', () {
      final result = calculateMortgageAmortization(
        purchasePrice: 600000,
        downPaymentPercentage: 20,
        annualInterestRate: 5.5,
        amortizationYears: 25,
      )!;

      expect(result.months.last.balanceEnd, 0.0);
    });

    test('total principal paid equals loan amount', () {
      final result = calculateMortgageAmortization(
        purchasePrice: 600000,
        downPaymentPercentage: 20,
        annualInterestRate: 5.5,
        amortizationYears: 25,
      )!;

      expect(result.totalPrincipalPaid, 480000.0);
    });

    test('totalPaid = totalPrincipal + totalInterest', () {
      final result = calculateMortgageAmortization(
        purchasePrice: 600000,
        downPaymentPercentage: 20,
        annualInterestRate: 5.5,
        amortizationYears: 25,
      )!;

      expect(
        result.totalPaid,
        closeTo(result.totalPrincipalPaid + result.totalInterestPaid, 0.01),
      );
    });

    test('cumulative totals increase monotonically', () {
      final result = calculateMortgageAmortization(
        purchasePrice: 800000,
        downPaymentPercentage: 10,
        annualInterestRate: 4.0,
        amortizationYears: 30,
      )!;

      for (var i = 1; i < result.months.length; i++) {
        expect(
          result.months[i].cumulativePrincipal,
          greaterThanOrEqualTo(result.months[i - 1].cumulativePrincipal),
        );
        expect(
          result.months[i].cumulativeInterest,
          greaterThanOrEqualTo(result.months[i - 1].cumulativeInterest),
        );
      }
    });

    test('first month interest > first month principal (typical)', () {
      final result = calculateMortgageAmortization(
        purchasePrice: 600000,
        downPaymentPercentage: 20,
        annualInterestRate: 5.5,
        amortizationYears: 25,
      )!;

      final first = result.months.first;
      expect(first.interest, greaterThan(first.principal));
    });

    test('last month principal > last month interest (typical)', () {
      final result = calculateMortgageAmortization(
        purchasePrice: 600000,
        downPaymentPercentage: 20,
        annualInterestRate: 5.5,
        amortizationYears: 25,
      )!;

      final last = result.months.last;
      expect(last.principal, greaterThan(last.interest));
    });

    test('year and monthInYear fields are correct', () {
      final result = calculateMortgageAmortization(
        purchasePrice: 600000,
        downPaymentPercentage: 20,
        annualInterestRate: 5.5,
        amortizationYears: 2,
      )!;

      // First month
      expect(result.months[0].year, 1);
      expect(result.months[0].monthInYear, 1);
      // 12th month
      expect(result.months[11].year, 1);
      expect(result.months[11].monthInYear, 12);
      // 13th month
      expect(result.months[12].year, 2);
      expect(result.months[12].monthInYear, 1);
      // Last month
      expect(result.months[23].year, 2);
      expect(result.months[23].monthInYear, 12);
    });
  });

  // ---------------------------------------------------------------
  // Edge cases
  // ---------------------------------------------------------------
  group('calculateMortgageAmortization — edge cases', () {
    test('zero interest rate: equal payments, no interest', () {
      final result = calculateMortgageAmortization(
        purchasePrice: 120000,
        downPaymentPercentage: 0,
        annualInterestRate: 0,
        amortizationYears: 10,
      )!;

      expect(result.monthlyPayment, 1000.0);
      expect(result.totalInterestPaid, 0.0);
      expect(result.totalPaid, 120000.0);
      expect(result.months.last.balanceEnd, 0.0);

      for (final m in result.months) {
        expect(m.interest, 0.0);
      }
    });

    test('100% down payment: zero loan, zero payments', () {
      final result = calculateMortgageAmortization(
        purchasePrice: 600000,
        downPaymentPercentage: 100,
        annualInterestRate: 5.5,
        amortizationYears: 25,
      )!;

      expect(result.monthlyPayment, 0.0);
      expect(result.totalPaid, 0.0);
      expect(result.months.last.balanceEnd, 0.0);
    });

    test('1-year term produces 12 months', () {
      final result = calculateMortgageAmortization(
        purchasePrice: 300000,
        downPaymentPercentage: 20,
        annualInterestRate: 6.0,
        amortizationYears: 1,
      )!;

      expect(result.months.length, 12);
      expect(result.months.last.balanceEnd, 0.0);
    });

    test('high interest rate (15%) produces valid schedule', () {
      final result = calculateMortgageAmortization(
        purchasePrice: 500000,
        downPaymentPercentage: 20,
        annualInterestRate: 15,
        amortizationYears: 25,
      )!;

      expect(result.months.length, 300);
      expect(result.months.last.balanceEnd, 0.0);
      expect(result.totalInterestPaid, greaterThan(result.totalPrincipalPaid));
    });

    test('no rounding mode produces unrounded values', () {
      final result = calculateMortgageAmortization(
        purchasePrice: 333333,
        downPaymentPercentage: 17.5,
        annualInterestRate: 4.75,
        amortizationYears: 3,
        roundMode: RoundMode.none,
      )!;

      // With awkward inputs and no rounding, monthly payment
      // likely has more than 2 decimal places.
      final paymentStr = result.monthlyPayment.toString();
      final decimals = paymentStr.contains('.')
          ? paymentStr.split('.').last.length
          : 0;
      expect(decimals, greaterThan(2));
    });
  });
}
