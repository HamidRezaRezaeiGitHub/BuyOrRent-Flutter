import 'package:flutter_test/flutter_test.dart';

import 'package:buy_or_rent/shared/models/mortgage_amortization_result.dart';

void main() {
  group('MortgageAmortizationResult', () {
    test('months list is accessible and ordered', () {
      const month1 = AmortizationMonth(
        index: 1,
        year: 1,
        monthInYear: 1,
        payment: 3687.47,
        interest: 3333.33,
        principal: 354.14,
        balanceStart: 640000,
        balanceEnd: 639645.86,
        cumulativePrincipal: 354.14,
        cumulativeInterest: 3333.33,
      );
      const month2 = AmortizationMonth(
        index: 2,
        year: 1,
        monthInYear: 2,
        payment: 3687.47,
        interest: 3331.49,
        principal: 355.98,
        balanceStart: 639645.86,
        balanceEnd: 639289.88,
        cumulativePrincipal: 710.12,
        cumulativeInterest: 6664.82,
      );

      const result = MortgageAmortizationResult(
        monthlyPayment: 3687.47,
        totalPrincipalPaid: 640000,
        totalInterestPaid: 466241,
        totalPaid: 1106241,
        months: [month1, month2],
      );

      expect(result.months, hasLength(2));
      expect(result.months.first.index, 1);
      expect(result.months.last.index, 2);
      expect(
        result.months.last.cumulativeInterest,
        greaterThan(result.months.first.cumulativeInterest),
      );
    });
  });
}
