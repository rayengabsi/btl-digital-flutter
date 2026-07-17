import 'package:flutter/material.dart';

import 'cards_screen.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key, this.onNavTap});

  /// Called when the user taps a bottom nav item inside the Cards screen.
  /// Bubbles the selected index back up to DashboardScreen.
  final ValueChanged<int>? onNavTap;

  @override
  Widget build(BuildContext context) {
    return CardsScreen(onNavTap: onNavTap);
  }
}
