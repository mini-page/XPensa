import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../data/models/account_model.dart';
import '../../data/models/expense_model.dart';
import '../provider/account_providers.dart';
import '../provider/expense_providers.dart';
import '../provider/preferences_providers.dart';
import '../widgets/amount_visibility.dart';
import '../widgets/quick_action_bar.dart';
import '../widgets/transaction_card.dart';
import '../widgets/ui_feedback.dart';
import 'add_expense_screen.dart';
import 'records_history_screen.dart';
import 'transaction_search_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late DateTime _selectedDate;
  late DateTime _windowStart;

  @override
  void initState() {
    super.initState();
    final today = DateUtils.dateOnly(DateTime.now());
    _selectedDate = today;
    _windowStart = today.subtract(const Duration(days: 3));
  }

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseListProvider);
    final expenses = expenseState.value ?? const <ExpenseModel>[];
    final accounts =
        ref.watch(accountListProvider).value ?? const <AccountModel>[];
    final accountsMap = {for (final a in accounts) a.id: a};
    final stats = ref.watch(statsProvider);
    final privacyModeEnabled = ref.watch(privacyModeEnabledProvider);
    final locale = ref.watch(localeProvider);
    final symbol = ref.watch(currencySymbolProvider);

    final currencyFormat = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 0,
    );
    final visibleDates = List<DateTime>.generate(
      7,
      (index) => _windowStart.add(Duration(days: index)),
    );
    final selectedExpenses = expenses
        .where((expense) => _isSameLocalDay(expense.date, _selectedDate))
        .toList(growable: false)
      ..sort((left, right) => right.date.compareTo(left.date));
    final selectedTotal = selectedExpenses.fold<double>(
      0,
      (sum, expense) => sum + expense.signedAmount,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Header(
            stats: stats,
            currencyFormat: currencyFormat,
            privacyModeEnabled: privacyModeEnabled,
            onMenuPressed: () => Scaffold.of(context).openDrawer(),
            onSearchPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const TransactionSearchScreen(),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 8),
                QuickActionBar(
                  actions: const <QuickActionItem>[
                    QuickActionItem(
                      label: 'SMS',
                      icon: Icons.sms_outlined,
                      isEnabled: false,
                      badgeLabel: 'Soon',
                    ),
                    QuickActionItem(
                      label: 'VOICE',
                      icon: Icons.mic_none_rounded,
                      isEnabled: false,
                      badgeLabel: 'Soon',
                    ),
                    QuickActionItem(
                      label: 'SMART',
                      icon: Icons.bolt_outlined,
                      isEnabled: false,
                      badgeLabel: 'Soon',
                    ),
                    QuickActionItem(
                      label: 'SCANNER',
                      icon: Icons.qr_code_scanner_rounded,
                      isEnabled: false,
                      badgeLabel: 'Soon',
                    ),
                    QuickActionItem(
                      label: 'MANUAL',
                      icon: Icons.add_rounded,
                      isHighlighted: true,
                    ),
                  ],
                  onTap: (action) {
                    if (action.label == 'MANUAL') {
                      _openAddExpenseScreen(
                        context,
                        initialDate: _selectedDate,
                      );
                    }
                  },
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 72,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <double>[50, 100, 200, 500, 1000].map((amount) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _AmountChip(
                          label: currencyFormat.format(amount),
                          onTap: () => _openAddExpenseScreen(
                            context,
                            initialAmount: amount,
                            initialDate: _selectedDate,
                          ),
                        ),
                      );
                    }).toList(growable: false),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: <Widget>[
                    const Text(
                      'RECENT TRANSACTIONS',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _openRecordsHistoryScreen(context),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DateStripCard(
                  visibleDates: visibleDates,
                  selectedDate: _selectedDate,
                  selectedTotalText: _formatSignedCurrency(
                    selectedTotal,
                    currencyFormat,
                    masked: privacyModeEnabled,
                  ),
                  transactionCount: selectedExpenses.length,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  onPrevious: () => _shiftWindow(-7),
                  onNext: () => _shiftWindow(7),
                ),
                const SizedBox(height: 18),
                if (expenseState.hasError)
                  const _EmptyCard(
                    title: 'Storage unavailable',
                    message: 'The expense list could not be loaded right now.',
                  )
                else if (expenseState.isLoading && expenses.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (expenses.isEmpty)
                  const _EmptyCard(
                    title: 'No expenses yet',
                    message:
                        'Tap the blue add button or choose a quick amount to record your first transaction.',
                  )
                else if (selectedExpenses.isEmpty)
                  _EmptyCard(
                    title: _emptyTitleFor(_selectedDate),
                    message: _emptyMessageFor(_selectedDate),
                  )
                else
                  ...selectedExpenses.map((expense) {
                    return TransactionCard(
                      expense: expense,
                      accountLabel: _accountLabelFor(expense, accountsMap),
                      maskAmounts: privacyModeEnabled,
                      onEdit: () => _openEditExpenseScreen(context, expense),
                      onDelete: () => _confirmDeleteExpense(expense),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddExpenseScreen(
    BuildContext context, {
    double? initialAmount,
    String? initialCategory,
    DateTime? initialDate,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddExpenseScreen(
          initialAmount: initialAmount,
          initialCategory: initialCategory,
          initialDate: initialDate,
        ),
      ),
    );
  }

  Future<void> _openEditExpenseScreen(
    BuildContext context,
    ExpenseModel expense,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddExpenseScreen(
          expenseId: expense.id,
          initialAmount: expense.amount,
          initialCategory: expense.category,
          initialDate: expense.date.toLocal(),
          initialNote: expense.note,
          initialAccountId: expense.accountId,
          initialType: expense.type,
        ),
      ),
    );
  }

  Future<void> _openRecordsHistoryScreen(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const RecordsHistoryScreen()),
    );
  }

  void _shiftWindow(int days) {
    setState(() {
      _windowStart = _windowStart.add(Duration(days: days));
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  bool _isSameLocalDay(DateTime expenseDate, DateTime targetDate) {
    final localDate = expenseDate.toLocal();
    return localDate.year == targetDate.year &&
        localDate.month == targetDate.month &&
        localDate.day == targetDate.day;
  }

  String _emptyTitleFor(DateTime date) {
    if (_isToday(date)) {
      return 'No transactions yet today';
    }
    if (date.isAfter(DateUtils.dateOnly(DateTime.now()))) {
      return 'No planned transactions';
    }
    return 'No transactions on this day';
  }

  String _emptyMessageFor(DateTime date) {
    if (_isToday(date)) {
      return 'Use the quick add flow to record today\'s first expense.';
    }
    if (date.isAfter(DateUtils.dateOnly(DateTime.now()))) {
      return 'Future days are available here so users can review scheduled spending once it exists.';
    }
    return 'Swipe across the date strip or jump back to today to review another day.';
  }

  bool _isToday(DateTime date) {
    final today = DateUtils.dateOnly(DateTime.now());
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  String? _accountLabelFor(
      ExpenseModel expense, Map<String, AccountModel> accountsMap) {
    if (expense.accountId == null) {
      return null;
    }

    final account = accountsMap[expense.accountId];
    if (account != null) {
      return account.name;
    }

    return 'Archived Account';
  }

  Future<void> _confirmDeleteExpense(ExpenseModel expense) async {
    final label = expense.note.isEmpty ? expense.category : expense.note;
    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Delete transaction?',
      message: 'Remove "$label" from your records? This cannot be undone.',
      confirmLabel: 'Delete txn',
    );
    if (!confirmed || !mounted) {
      return;
    }

    await ref.read(expenseControllerProvider).deleteExpense(expense.id);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Transaction removed.')));
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.stats,
    required this.currencyFormat,
    required this.privacyModeEnabled,
    required this.onMenuPressed,
    required this.onSearchPressed,
  });

  final ExpenseStats stats;
  final NumberFormat currencyFormat;
  final bool privacyModeEnabled;
  final VoidCallback onMenuPressed;
  final VoidCallback onSearchPressed;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final netTotal = _formatSignedCurrency(
      stats.monthNetTotal,
      currencyFormat,
      masked: privacyModeEnabled,
    );
    return Container(
      padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 28),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(44)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: onMenuPressed,
                icon: const Icon(Icons.menu_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  AppAssets.logo,
                  width: 28,
                  height: 28,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'XPensa',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onSearchPressed,
                icon: const Icon(Icons.search_rounded,
                    color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 30),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'All Accounts - $netTotal',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _MetricColumn(
                label: 'EXPENSE SO FAR',
                value: maskAmount(
                  currencyFormat.format(stats.monthTotal),
                  masked: privacyModeEnabled,
                ),
              ),
              _MetricColumn(
                label: 'INCOME SO FAR',
                value: maskAmount(
                  currencyFormat.format(stats.monthIncomeTotal),
                  masked: privacyModeEnabled,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: AppColors.overlayWhiteMedium,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
        ),
      ],
    );
  }
}

class _DateStripCard extends StatelessWidget {
  const _DateStripCard({
    required this.visibleDates,
    required this.selectedDate,
    required this.selectedTotalText,
    required this.transactionCount,
    required this.onDateSelected,
    required this.onPrevious,
    required this.onNext,
  });

  final List<DateTime> visibleDates;
  final DateTime selectedDate;
  final String selectedTotalText;
  final int transactionCount;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final monthFormat = DateFormat('MMMM yyyy');
    final weekdayFormat = DateFormat('E');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  monthFormat.format(selectedDate),
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _DateNavButton(icon: Icons.arrow_back_rounded, onTap: onPrevious),
              const SizedBox(width: 8),
              _DateNavButton(icon: Icons.arrow_forward_rounded, onTap: onNext),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: visibleDates.map((date) {
              final isSelected = DateUtils.isSameDay(date, selectedDate);
              return Expanded(
                child: _DayPill(
                  label:
                      weekdayFormat.format(date).substring(0, 1).toUpperCase(),
                  day: date.day.toString().padLeft(2, '0'),
                  isSelected: isSelected,
                  onTap: () => onDateSelected(date),
                ),
              );
            }).toList(growable: false),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Selected day',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '$transactionCount txns',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      selectedTotalText,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
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

class _DateNavButton extends StatelessWidget {
  const _DateNavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 18, color: AppColors.textMuted),
        ),
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.label,
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String day;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentLime : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Column(
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected ? AppColors.accentLimeDark : AppColors.textMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              day,
              style: TextStyle(
                color:
                    isSelected ? AppColors.accentLimeDark : AppColors.textDark,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 92,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x1209386D),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatSignedCurrency(
  double amount,
  NumberFormat currencyFormat, {
  required bool masked,
}) {
  if (amount == 0) {
    return maskAmount(currencyFormat.format(0), masked: masked);
  }

  final absolute = maskAmount(
    currencyFormat.format(amount.abs()),
    masked: masked,
  );
  final prefix = amount > 0 ? '+' : '-';
  return '$prefix$absolute';
}
