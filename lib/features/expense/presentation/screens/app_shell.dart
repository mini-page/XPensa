import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/floating_nav_bar.dart';
import '../provider/account_providers.dart';
import '../widgets/account_editor_sheet.dart';
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
  int _selectedIndex = 0;

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
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: PowerPill(
          onTap: _handleFabPressed,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

  Future<void> _handleFabPressed() async {
    if (_selectedIndex == 0 || _selectedIndex == 1 || _selectedIndex == 2) {
      await _openAddExpenseScreen();
      return;
    }

    if (_selectedIndex != 3) {
      return;
    }

    await _openAddAccountSheet();
  }

  Future<void> _openAddAccountSheet() async {
    final result = await showAccountEditorSheet(context);
    if (result == null) {
      return;
    }

    await ref.read(accountControllerProvider).saveAccount(
          name: result.name,
          iconKey: result.iconKey,
          balance: result.balance,
        );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${result.name} created.')));
  }
}
