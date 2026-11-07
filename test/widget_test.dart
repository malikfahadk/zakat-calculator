import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zakat_calculator/main.dart';

void main() {
  testWidgets('completes the three-step offline workflow', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const ZakatCalculatorApp());

    expect(find.text('Nisab'), findsOneWidget);
    expect(find.text('OFFLINE'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('nisabField')), '1234.50');
    await tester.enterText(find.byKey(const Key('zakatRateField')), '2.5');
    await tester.tap(find.byKey(const Key('valuationDateField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue to assets'));
    await tester.pumpAndSettle();

    expect(find.text('Assets'), findsOneWidget);
    await tester.tap(find.byKey(const Key('hijriYearField')));
    await tester.tap(find.text('Review details'));
    await tester.pumpAndSettle();

    expect(find.text('Review'), findsOneWidget);
    expect(find.textContaining('Net zakatable wealth:'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Finish review'),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Finish review'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Review acknowledged'), findsOneWidget);
  });

  testWidgets('requires nisab and date before continuing', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const ZakatCalculatorApp());

    await tester.tap(find.text('Continue to assets'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Enter a nisab amount'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('nisabField')), '100');
    await tester.enterText(find.byKey(const Key('zakatRateField')), '2.5');
    await tester.tap(find.text('Continue to assets'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Select a valuation date'), findsOneWidget);
  });
}
