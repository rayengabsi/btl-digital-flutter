import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:btl_digital/features/home/presentation/pages/dashboard_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Home dashboard renders static demo data', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Wallet card: static balance 12,450.80 TND.
    expect(find.text('Wallet Balance'), findsOneWidget);
    expect(find.text('TND 12,450.80', findRichText: true), findsOneWidget);

    // Quick actions.
    expect(find.text('Send'), findsOneWidget);
    expect(find.text('Request'), findsOneWidget);
    expect(find.text('Top Up'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);

    // Main button "Deposit"; bottom nav label "Transfer" still present.
    expect(find.text('Deposit'), findsOneWidget);
    expect(find.text('Transfer'), findsOneWidget);

    // Header: Transactions + All >  + notification bell with badge.
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    // Transactions: titles, subtitles and amounts.
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Netflix Subscription'), findsOneWidget);
    expect(find.text('Carrefour Market'), findsOneWidget);
    expect(find.text('Ooredoo Recharge'), findsOneWidget);

    expect(find.text('Today, 08:30 AM'), findsOneWidget);
    expect(find.text('Yesterday, 10:15 PM'), findsOneWidget);
    expect(find.text('May 17, 2025'), findsOneWidget);
    expect(find.text('May 16, 2025'), findsOneWidget);

    expect(find.text('+2,500.00 TND'), findsOneWidget);
    expect(find.text('-29.99 TND'), findsOneWidget);
    expect(find.text('-78.60 TND'), findsOneWidget);
    expect(find.text('-10.00 TND'), findsOneWidget);

    // Per-transaction professional icons.
    expect(find.byIcon(Icons.south_west_rounded),
        findsNWidgets(2)); // Request + Salary
    expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart_rounded), findsOneWidget);
    expect(find.byIcon(Icons.phone_android_rounded),
        findsNWidgets(2)); // Top Up + Ooredoo
    expect(find.byIcon(Icons.north_east_rounded), findsOneWidget); // Send
    expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget); // Scan
  });

  testWidgets('Hide/show balance toggle keeps working', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('TND 12,450.80', findRichText: true), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pumpAndSettle();
    expect(find.text('••••••'), findsOneWidget);
    expect(find.text('TND 12,450.80', findRichText: true), findsNothing);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();
    expect(find.text('TND 12,450.80', findRichText: true), findsOneWidget);
  });
}