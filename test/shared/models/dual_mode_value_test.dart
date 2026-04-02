import 'package:flutter_test/flutter_test.dart';

import 'package:buy_or_rent/shared/models/dual_mode_value.dart';

void main() {
  group('DualModeValue', () {
    test('defaults to percentage mode', () {
      const val = DualModeValue(percentage: 20, amount: 120000);
      expect(val.mode, InputMode.percentage);
    });

    test('copyWith replaces specified fields only', () {
      const original = DualModeValue(percentage: 20, amount: 120000);
      final toggled = original.copyWith(mode: InputMode.amount);

      expect(toggled.mode, InputMode.amount);
      expect(toggled.percentage, 20);
      expect(toggled.amount, 120000);
    });

    test('equality includes mode in comparison', () {
      const a = DualModeValue(percentage: 20, amount: 120000);
      const b = DualModeValue(percentage: 20, amount: 120000);
      const c = DualModeValue(
        mode: InputMode.amount,
        percentage: 20,
        amount: 120000,
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, b.hashCode);
    });
  });
}
