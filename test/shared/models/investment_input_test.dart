import 'package:flutter_test/flutter_test.dart';

import 'package:buy_or_rent/shared/models/investment_input.dart';

void main() {
  group('InvestmentInput', () {
    test('copyWith replaces value', () {
      const original = InvestmentInput(investmentReturn: 7.5);
      final updated = original.copyWith(investmentReturn: 10);
      expect(updated.investmentReturn, 10);
    });

    test('equality compares by value', () {
      const a = InvestmentInput(investmentReturn: 7.5);
      const b = InvestmentInput(investmentReturn: 7.5);
      const c = InvestmentInput(investmentReturn: 10);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, b.hashCode);
    });
  });
}
