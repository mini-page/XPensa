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

  late final List<Widget> _pages = <Widget>[
    const HomeScreen(),
    StatsScreen(),
    const CategoriesScreen(),
    AccountsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      floatingActionButton: _selectedIndex == 4
          ? null
          : SizedBox(
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF0A6BE8),
        unselectedItemColor: const Color(0xFF97A7C1),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline_rounded),
            activeIcon: Icon(Icons.pie_chart_rounded),
            label: 'Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet_outlined),
            activeIcon: Icon(Icons.wallet_rounded),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Future<void> _openAddExpenseScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AddExpenseScreen(),
      ),
    );
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${result.name} created.')),
    );
  }
}
