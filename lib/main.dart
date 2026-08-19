import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Plus Jakarta Sans is bundled locally — never fetch at runtime so the
  // original typography renders identically even without a network connection.
  GoogleFonts.config.allowRuntimeFetching = false;
  await dotenv.load(fileName: 'assets/.env');
  runApp(const ProviderScope(child: BtlDigitalApp()));
}

class BtlDigitalApp extends StatelessWidget {
  const BtlDigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BTL Digital Banking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}
