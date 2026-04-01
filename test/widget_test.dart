import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:buy_or_rent/app/app.dart';

void main() {
  testWidgets('App renders landing screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BuyOrRentApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BuyOrRent'), findsOneWidget);
    expect(find.text('Start Your Analysis'), findsOneWidget);
  });
}

