import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/background_backup.dart';
import 'core/utils/hive_bootstrap.dart';
import 'features/expense/presentation/provider/preferences_providers.dart';
import 'features/expense/presentation/screens/app_shell.dart';
import 'features/expense/presentation/screens/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().initialize(
    callbackDispatcher,
  );

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
    final onboardingCompleted = ref.watch(isOnboardingCompletedProvider);
    final preferencesAsync = ref.watch(appPreferencesProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'XPensa',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: preferencesAsync.when(
        data: (_) =>
            onboardingCompleted ? const AppShell() : const OnboardingScreen(),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, __) => const AppShell(), // Fallback
      ),
    );
  }
}
