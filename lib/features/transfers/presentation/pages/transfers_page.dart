import 'package:flutter/material.dart';

import '../pages/transfer_screen.dart';

class TransfersPage extends StatelessWidget {
  const TransfersPage({super.key, this.onNavTap});

  final ValueChanged<int>? onNavTap;

  @override
  Widget build(BuildContext context) {
    return TransferScreen(onNavTap: onNavTap);
  }
}
