import 'package:flutter_test/flutter_test.dart';

import 'package:buy_or_rent/shared/models/rent_input.dart';

void main() {
  group('RentInput', () {
    test('copyWith replaces specified fields only', () {
      const original = RentInput(monthlyRent: 2000, rentIncreaseRate: 2.5);
      final updated = original.copyWith(monthlyRent: 3000);

      expect(updated.monthlyRent, 3000);
      expect(updated.rentIncreaseRate, 2.5);
    });

    test('equality compares by value', () {
      const a = RentInput(monthlyRent: 2000, rentIncreaseRate: 2.5);
      const b = RentInput(monthlyRent: 2000, rentIncreaseRate: 2.5);
      const c = RentInput(monthlyRent: 3000, rentIncreaseRate: 2.5);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, b.hashCode);
    });
  });
}
