import 'package:flutter/material.dart';

import 'settings_screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, this.onNavTap});

  final ValueChanged<int>? onNavTap;

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(onNavTap: onNavTap);
  }
}
