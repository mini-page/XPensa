import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../provider/account_providers.dart';
import '../widgets/account_editor_sheet.dart';
import '../widgets/app_drawer.dart';
import '../widgets/power_pill_menu.dart';
import 'accounts_screen.dart';
import 'add_expense_screen.dart';
import 'categories_screen.dart';
import 'home_screen.dart';
import 'scanner_screen.dart';
import 'stats_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  OverlayEntry? _menuOverlay;

  void _showPowerMenu() {
    _menuOverlay = OverlayEntry(
      builder: (context) => PowerPillMenu(
        onVoice: () => context.showSnackBar('Voice input arriving soon.'),
        onSplit: () => context.showSnackBar('Split bill tool arriving soon.'),
        onScanner: () {
          _menuOverlay?.remove();
          _menuOverlay = null;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ScannerScreen()),
          );
        },
        onClose: () {
          _menuOverlay?.remove();
          _menuOverlay = null;
        },
      ),
    );
    Overlay.of(context).insert(_menuOverlay!);
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
                      AppColors.backgroundLight.withOpacity(0.0),
                      AppColors.backgroundLight.withOpacity(0.8),
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
        padding: const EdgeInsets.only(bottom: 92),
        child: PowerPill(
          onTap: _handleFabPressed,
          onLongPress: _showPowerMenu,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _CustomFloatingNavBar(
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
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AddExpenseScreen()));
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

    await ref
        .read(accountControllerProvider)
        .saveAccount(
          name: result.name,
          iconKey: result.iconKey,
          balance: result.balance,
        );

    if (!mounted) {
      return;
    }

    context.showSnackBar('${result.name} created.');
  }
}

// ── Custom Floating Navigation Bar ──────────────────────────────────────────

class _CustomFloatingNavBar extends StatelessWidget {
  const _CustomFloatingNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(99),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _NavBarItem(
                label: 'Home',
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                isSelected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavBarItem(
                label: 'Charts',
                icon: Icons.pie_chart_outline_rounded,
                activeIcon: Icons.pie_chart_rounded,
                isSelected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavBarItem(
                label: 'Category',
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view_rounded,
                isSelected: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavBarItem(
                label: 'Account',
                icon: Icons.account_balance_wallet_outlined,
                activeIcon: Icons.account_balance_wallet_rounded,
                isSelected: selectedIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
            : const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.white : AppColors.textMuted,
              size: 24,
            ),
            if (isSelected) ...<Widget>[
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
