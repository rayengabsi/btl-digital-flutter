import 'package:flutter/material.dart';

import 'profile_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.onNavTap});

  final ValueChanged<int>? onNavTap;

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(onNavTap: onNavTap);
  }
}
