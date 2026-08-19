import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:btl_digital/features/accounts/presentation/pages/cards_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpCardsScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: CardsScreen())),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Cards screen renders static demo data without backend error',
      (tester) async {
    await pumpCardsScreen(tester);

    // The failing backend error must not appear.
    expect(find.text('Unable to load customer accounts'), findsNothing);
    expect(find.text('Unable to load cards'), findsNothing);

    // Header.
    expect(find.text('My Cards'), findsOneWidget);
    expect(find.text('Manage your cards and accounts'), findsOneWidget);

    // Bank card content (carousel can build both cards).
    expect(find.text('BTL Bank'), findsWidgets);
    expect(find.text('VISA'), findsWidgets);
    expect(find.text('RAYEN GABSI'), findsWidgets);
    expect(find.text('12,450.80 TND'), findsWidgets);
    expect(find.text('27,000.00 TND'), findsWidgets);

    // Quick actions.
    expect(find.text('Send'), findsOneWidget);
    expect(find.text('Request'), findsOneWidget);
    expect(find.text('Freeze'), findsOneWidget);
    expect(find.text('View Details'), findsOneWidget);

    // Deposit button.
    expect(find.text('Deposit'), findsOneWidget);

    // Transactions: titles, subtitles, amounts (positive green, negative red).
    expect(find.text('Recent Transactions'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Netflix Subscription'), findsOneWidget);
    expect(find.text('Carrefour Market'), findsOneWidget);
    expect(find.text('Ooredoo Recharge'), findsOneWidget);
    expect(find.text('+2,500.00 TND'), findsOneWidget);
    expect(find.text('-29.99 TND'), findsOneWidget);
    expect(find.text('-78.60 TND'), findsOneWidget);
    expect(find.text('-10.00 TND'), findsOneWidget);
  });

  testWidgets('View Details opens the professional card details sheet',
      (tester) async {
    await pumpCardsScreen(tester);

    await tester.tap(find.text('View Details'));
    await tester.pumpAndSettle();

    expect(find.text('Card Details'), findsOneWidget);
    expect(find.text('Cardholder'), findsOneWidget);
    expect(find.text('Card Number'), findsOneWidget);
    expect(find.text('Expiry Date'), findsOneWidget);
    expect(find.text('Card Type'), findsOneWidget);
    expect(find.text('Currency'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Available Balance'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Show'), findsOneWidget);
  });

  testWidgets('Freeze action confirms via dialog and toggles to Unfreeze',
      (tester) async {
    await pumpCardsScreen(tester);

    await tester.tap(find.text('Freeze'));
    await tester.pumpAndSettle();

    expect(find.text('Freeze card?'), findsOneWidget);
    expect(
      find.textContaining('demo/static card'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Freeze'));
    await tester.pumpAndSettle();

    expect(find.text('Unfreeze'), findsOneWidget);
    expect(find.text('Freeze'), findsNothing);
  });
}