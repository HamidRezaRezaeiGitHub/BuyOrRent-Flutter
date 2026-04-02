import 'package:flutter_test/flutter_test.dart';

import 'package:buy_or_rent/shared/models/dual_mode_value.dart';
import 'package:buy_or_rent/shared/models/purchase_input.dart';

void main() {
  const defaults = PurchaseInput(
    purchasePrice: 600000,
    mortgageRate: 5.5,
    mortgageLength: 25,
    downPayment: DualModeValue(percentage: 20, amount: 120000),
    closingCosts: DualModeValue(percentage: 1.5, amount: 12000),
    propertyTax: DualModeValue(percentage: 0.75, amount: 4500),
    maintenance: DualModeValue(percentage: 1, amount: 6000),
    assetAppreciationRate: 3,
  );

  group('PurchaseInput', () {
    test('copyWith replaces specified fields only', () {
      final updated = defaults.copyWith(
        purchasePrice: 800000,
        downPayment: const DualModeValue(
          mode: InputMode.amount,
          percentage: 20,
          amount: 160000,
        ),
      );

      expect(updated.purchasePrice, 800000);
      expect(updated.downPayment.mode, InputMode.amount);
      expect(updated.downPayment.amount, 160000);
      // Unchanged:
      expect(updated.mortgageRate, 5.5);
      expect(updated.closingCosts.percentage, 1.5);
    });

    test('equality compares by value including nested DualModeValue', () {
      const a = defaults;
      final b = defaults.copyWith();
      final c = defaults.copyWith(
        downPayment: const DualModeValue(
          mode: InputMode.amount,
          percentage: 20,
          amount: 120000,
        ),
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, b.hashCode);
    });
  });
}
