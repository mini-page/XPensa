import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/account_providers.dart';
import '../widgets/account_editor_sheet.dart';
import 'accounts_screen.dart';
import 'add_expense_screen.dart';
import 'categories_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'stats_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;

  List<Widget> _buildPages() {
    return [
      const HomeScreen(),
      StatsScreen(),
      const CategoriesScreen(),
      const AccountsScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages();

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: pages),
      floatingActionButton: _selectedIndex == 4
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: SizedBox(
                width: 72,
                height: 72,
                child: FloatingActionButton(
                  onPressed: _handleFabPressed,
                  backgroundColor: const Color(0xFF0A6BE8),
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shape: const CircleBorder(),
                  child: Icon(
                    _selectedIndex == 3
                        ? Icons.add_card_rounded
                        : Icons.add_rounded,
                    size: 32,
                  ),
                ),
              ),
            ),
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${result.name} created.')));
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
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(99),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x15000000),
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
                label: 'Analysis',
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
                label: 'Accounts',
                icon: Icons.account_balance_wallet_outlined,
                activeIcon: Icons.account_balance_wallet_rounded,
                isSelected: selectedIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavBarItem(
                label: 'Profile',
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                isSelected: selectedIndex == 4,
                onTap: () => onTap(4),
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
          color: isSelected ? const Color(0xFF0A6BE8) : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.white : const Color(0xFF97A7C1),
              size: 24,
            ),
            if (isSelected) ...<Widget>[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
