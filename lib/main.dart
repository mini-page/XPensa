import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/utils/hive_bootstrap.dart';
import 'features/expense/presentation/provider/preferences_providers.dart';
import 'features/expense/presentation/screens/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  await HiveBootstrap.initialize();
  runApp(const ProviderScope(child: XPensaApp()));
}

class XPensaApp extends ConsumerWidget {
  const XPensaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'XPensa',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF3F7FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A6BE8),
          primary: const Color(0xFF0A6BE8),
          secondary: const Color(0xFFFF5B6C),
          surface: Colors.white,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0E1626),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A9DFF),
          brightness: Brightness.dark,
          primary: const Color(0xFF4A9DFF),
          secondary: const Color(0xFFFF6C89),
          surface: const Color(0xFF182234),
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      home: const AppShell(),
    );
  }
}
