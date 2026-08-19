import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:btl_digital/features/transfers/presentation/pages/transfer_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpTransferScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: TransferScreen())),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Transfer form renders static account and beneficiary selector',
      (tester) async {
    await pumpTransferScreen(tester);

    // Mode toggle.
    expect(find.text('New Transfer'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);

    // Static account is auto-selected.
    expect(find.text('From Account'), findsOneWidget);
    expect(find.text('Primary Account'), findsOneWidget);
    expect(find.text('TND 12450.80'), findsOneWidget);

    // Beneficiary selector placeholder.
    expect(find.text('To Beneficiary'), findsOneWidget);
    expect(find.text('Select a beneficiary'), findsOneWidget);

    // Amount + details + continue.
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Payment Details'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('Beneficiary selection sheet lists static beneficiaries and updates form',
      (tester) async {
    await pumpTransferScreen(tester);

    await tester.tap(find.text('To Beneficiary'));
    await tester.pumpAndSettle();

    expect(find.text('Select Beneficiary'), findsOneWidget);
    expect(find.text('Ahmed Ben Ali'), findsOneWidget);
    expect(find.text('Sarah Trabelsi'), findsOneWidget);
    expect(find.text('Mohamed Haddad'), findsOneWidget);
    expect(find.text('BTL Bank • •••• 3565'), findsOneWidget);

    await tester.tap(find.text('Ahmed Ben Ali'));
    await tester.pumpAndSettle();

    // Sheet closed and form now shows the selected beneficiary.
    expect(find.text('Select Beneficiary'), findsNothing);
    expect(find.text('Ahmed Ben Ali'), findsOneWidget);
    expect(find.text('BTL Bank • •••• 3565'), findsOneWidget);
  });
}