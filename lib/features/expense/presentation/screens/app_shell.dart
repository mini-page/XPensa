import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/floating_nav_bar.dart';
import '../provider/preferences_providers.dart';
import '../widgets/app_drawer.dart';
import '../widgets/power_pill_menu.dart';
import 'accounts_screen.dart';
import 'categories_screen.dart';
import 'home_screen.dart';
import 'stats_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<PowerFabState> _fabKey = GlobalKey<PowerFabState>();
  int _selectedIndex = 0;
  bool _fabOpen = false;

  @override
  void initState() {
    super.initState();
    // Show What's New modal (N8) if this version hasn't been seen yet
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkWhatsNew());
  }

  void _checkWhatsNew() {
    final prefs = ref.read(appPreferencesProvider).value;
    if (prefs == null) return;
    if (prefs.whatsNewShownVersion == AppConstants.version) return;

    ref
        .read(appPreferencesControllerProvider)
        .setWhatsNewShownVersion(AppConstants.version);

    _showWhatsNewModal();
  }

  void _showWhatsNewModal() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.new_releases_rounded,
                    color: AppColors.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "What's New",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Version ${AppConstants.version}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...const [
              _WhatsNewItem(
                emoji: '🔒',
                title: 'PIN Lock',
                detail: 'Secure your app with a 4-digit PIN',
              ),
              _WhatsNewItem(
                emoji: '🏷️',
                title: 'Transaction Tags',
                detail: 'Add #tags to notes and filter by them in Records',
              ),
              _WhatsNewItem(
                emoji: '🎯',
                title: 'Savings Goals',
                detail: 'Track milestones in the new Goals tab under Tools',
              ),
              _WhatsNewItem(
                emoji: '📊',
                title: 'Budget Progress Bar',
                detail:
                    'See your top budget right on the home header',
              ),
              _WhatsNewItem(
                emoji: '📅',
                title: 'Date Range Filter',
                detail: 'Custom date ranges for Records and Stats',
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Let's go!",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPages() {
    return [
      const HomeScreen(),
      StatsScreen(),
      const CategoriesScreen(),
      const AccountsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages();

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: pages),
          // Bottom Gradient Overlay for Navbar Contrast
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 120,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.backgroundLight.withValues(alpha: 0.0),
                      AppColors.backgroundLight.withValues(alpha: 0.8),
                      AppColors.backgroundLight,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Dismiss barrier — covers content when FAB menu is open
          if (_fabOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _fabKey.currentState?.close(),
                child: Container(color: Colors.black.withValues(alpha: 0.12)),
              ),
            ),
          // Expandable power FAB
          Positioned(
            right: 16,
            bottom: 120,
            child: PowerFab(
              key: _fabKey,
              onQuickAdd: _openAddExpenseScreen,
              onScanner: () {
                if (mounted) AppRoutes.pushScanner(context);
              },
              onToggle: (open) => setState(() => _fabOpen = open),
            ),
          ),
        ],
      ),
      bottomNavigationBar: FloatingNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Future<void> _openAddExpenseScreen() async {
    await AppRoutes.pushAddExpense(context);
  }
}

class _WhatsNewItem extends StatelessWidget {
  const _WhatsNewItem({
    required this.emoji,
    required this.title,
    required this.detail,
  });

  final String emoji;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
