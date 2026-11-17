import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:individual_assigments/app_info.dart';
import 'package:individual_assigments/main.dart';

/// Builds the app at a typical phone size so the layout is tested like a real
/// Android device.
Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const BaggageFeeApp());
  await tester.pumpAndSettle();
}

Future<void> calculate(
  WidgetTester tester, {
  required String weight,
  required String rate,
}) async {
  await tester.enterText(find.byKey(const Key('weightField')), weight);
  await tester.enterText(find.byKey(const Key('rateField')), rate);
  await tester.ensureVisible(find.byKey(const Key('calculateButton')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('calculateButton')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('25 kg Economy at RM15 shows RM75.00 charge and RM81.00 total',
      (WidgetTester tester) async {
    await pumpApp(tester);

    await calculate(tester, weight: '25', rate: '15');

    expect(find.byKey(const Key('resultCard')), findsOneWidget);
    expect(find.text('RM 75.00'), findsOneWidget);
    expect(find.text('RM 6.00'), findsOneWidget);
    expect(find.text('RM 81.00'), findsOneWidget);
  });

  testWidgets('55 kg Business at RM12 shows RM180.00 charge and RM194.40 total',
      (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.ensureVisible(find.byKey(const Key('businessOption')));
    await tester.tap(find.byKey(const Key('businessOption')));
    await tester.pumpAndSettle();

    await calculate(tester, weight: '55', rate: '12');

    expect(find.text('RM 180.00'), findsOneWidget);
    expect(find.text('RM 14.40'), findsOneWidget);
    expect(find.text('RM 194.40'), findsOneWidget);
  });

  testWidgets('42.5 kg Business at RM12 accepts decimals and shows RM32.40',
      (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.ensureVisible(find.byKey(const Key('businessOption')));
    await tester.tap(find.byKey(const Key('businessOption')));
    await tester.pumpAndSettle();

    await calculate(tester, weight: '42.5', rate: '12');

    expect(find.text('2.5 kg'), findsWidgets);
    expect(find.text('RM 30.00'), findsOneWidget);
    expect(find.text('RM 2.40'), findsOneWidget);
    expect(find.text('RM 32.40'), findsOneWidget);
  });

  testWidgets('weight under the allowance shows RM0.00 total',
      (WidgetTester tester) async {
    await pumpApp(tester);

    await calculate(tester, weight: '18', rate: '15');

    expect(find.text('RM 0.00'), findsWidgets);
    expect(
      find.text('Within the allowance - no excess fee.'),
      findsOneWidget,
    );
  });

  testWidgets('empty input shows validation messages and no result card',
      (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.ensureVisible(find.byKey(const Key('calculateButton')));
    await tester.tap(find.byKey(const Key('calculateButton')));
    await tester.pumpAndSettle();

    expect(find.text('Please enter the checked baggage weight.'), findsOneWidget);
    expect(
      find.text('Please enter the excess baggage rate per kg.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('resultCard')), findsNothing);
  });

  testWidgets('Reset clears the fields, result and ticket class',
      (WidgetTester tester) async {
    await pumpApp(tester);
    await calculate(tester, weight: '25', rate: '15');
    expect(find.byKey(const Key('resultCard')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('resetButton')));
    await tester.tap(find.byKey(const Key('resetButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('resultCard')), findsNothing);
    expect(find.text('25'), findsNothing);
    expect(find.text('15'), findsNothing);
    expect(
      find.text('Baggage allowance: 20 kg per passenger'),
      findsOneWidget,
    );
  });

  testWidgets('drawer opens the About page with author and copyright details',
      (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(find.text(AppInfo.purpose), findsOneWidget);
    expect(find.text(AppInfo.authorName), findsOneWidget);
    expect(find.textContaining('All rights reserved'), findsOneWidget);
    expect(find.text(AppInfo.matricNumber), findsOneWidget);
  });
}
