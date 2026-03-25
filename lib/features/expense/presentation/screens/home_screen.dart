import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/account_model.dart';
import '../../data/models/expense_model.dart';
import '../provider/account_providers.dart';
import '../provider/expense_providers.dart';
import '../provider/preferences_providers.dart';
import '../widgets/amount_visibility.dart';
import '../widgets/expense_category.dart';
import '../widgets/quick_action_bar.dart';
import '../widgets/transaction_card.dart';
import 'add_expense_screen.dart';
import 'manage_subscriptions_screen.dart';
import 'records_history_screen.dart';

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
    final expenses = expenseState.valueOrNull ?? const <ExpenseModel>[];
    final accounts =
        ref.watch(accountListProvider).valueOrNull ?? const <AccountModel>[];
    final stats = ref.watch(statsProvider);
    final privacyModeEnabled = ref.watch(privacyModeEnabledProvider);
    final currencyFormat =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
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
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _FeatureRow(
                  onSplitTap: () => _openSplitBillSheet(context),
                  onRecurringTap: () => _openSubscriptionsScreen(context),
                ),
                const SizedBox(height: 22),
                QuickActionBar(
                  actions: const <QuickActionItem>[
                    QuickActionItem(label: 'SMS', icon: Icons.sms_outlined),
                    QuickActionItem(
                      label: 'VOICE',
                      icon: Icons.mic_none_rounded,
                    ),
                    QuickActionItem(
                      label: 'SPLIT',
                      icon: Icons.group_outlined,
                    ),
                    QuickActionItem(
                      label: 'SMART',
                      icon: Icons.bolt_outlined,
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
                      return;
                    }
                    if (action.label == 'SPLIT') {
                      _openSplitBillSheet(context);
                      return;
                    }
                    _showSoonMessage(context, action.label);
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
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: expenseCategories.map((category) {
                    return _CategoryTile(
                      category: category,
                      onTap: () => _openAddExpenseScreen(
                        context,
                        initialCategory: category.name,
                        initialDate: _selectedDate,
                      ),
                    );
                  }).toList(growable: false),
                ),
                const SizedBox(height: 30),
                Row(
                  children: <Widget>[
                    const Text(
                      'RECENT TRANSACTIONS',
                      style: TextStyle(
                        color: Color(0xFF0A6BE8),
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
                      accountLabel: _accountLabelFor(expense, accounts),
                      maskAmounts: privacyModeEnabled,
                      onEdit: () => _openEditExpenseScreen(context, expense),
                      onDelete: () => ref
                          .read(expenseControllerProvider)
                          .deleteExpense(expense.id),
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
      MaterialPageRoute<void>(
        builder: (_) => const RecordsHistoryScreen(),
      ),
    );
  }

  Future<void> _openSubscriptionsScreen(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ManageSubscriptionsScreen(),
      ),
    );
  }

  Future<void> _openSplitBillSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => const _SplitBillSheet(),
    );
  }

  void _showSoonMessage(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label shortcuts arrive after the core expense flow is stable.',
        ),
      ),
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

  String? _accountLabelFor(ExpenseModel expense, List<AccountModel> accounts) {
    if (expense.accountId == null) {
      return null;
    }

    for (final account in accounts) {
      if (account.id == expense.accountId) {
        return account.name;
      }
    }

    return 'Archived Account';
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.stats,
    required this.currencyFormat,
    required this.privacyModeEnabled,
  });

  final ExpenseStats stats;
  final NumberFormat currencyFormat;
  final bool privacyModeEnabled;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final netTotal = _formatSignedCurrency(
      stats.monthNetTotal,
      currencyFormat,
      masked: privacyModeEnabled,
    );
    return Container(
      padding: EdgeInsets.fromLTRB(22, topPadding + 14, 22, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF0A6BE8),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(44)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/icon/xpensa_logo.png',
                  width: 32,
                  height: 32,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'XPensa',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              const Icon(Icons.tune_rounded, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            'All Accounts - $netTotal',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
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
  const _MetricColumn({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: Color(0xB3FFFFFF),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.onSplitTap,
    required this.onRecurringTap,
  });

  final VoidCallback onSplitTap;
  final VoidCallback onRecurringTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _FeatureCard(
            title: 'Split Bills',
            subtitle: 'SPLITWISE',
            icon: Icons.group_outlined,
            onTap: onSplitTap,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _FeatureCard(
            title: 'Recurring',
            subtitle: 'MANAGE SUBS',
            icon: Icons.sync_alt_rounded,
            onTap: onRecurringTap,
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF5FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFF0A6BE8)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF13213B),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF9AA8BE),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({
    required this.label,
    required this.onTap,
  });

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
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF13213B),
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onTap,
  });

  final ExpenseCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEFF3FA),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: 96,
          height: 118,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(category.icon, color: category.color, size: 28),
              const SizedBox(height: 10),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    category.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF97A7C1),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
            color: Color(0x1209386D),
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
                    color: Color(0xFF17233D),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _DateNavButton(
                icon: Icons.arrow_back_rounded,
                onTap: onPrevious,
              ),
              const SizedBox(width: 8),
              _DateNavButton(
                icon: Icons.arrow_forward_rounded,
                onTap: onNext,
              ),
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
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Selected day',
                    style: TextStyle(
                      color: Color(0xFF6D7D98),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '$transactionCount txns',
                  style: const TextStyle(
                    color: Color(0xFF8F9FB7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  selectedTotalText,
                  style: const TextStyle(
                    color: Color(0xFF152039),
                    fontWeight: FontWeight.w900,
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
  const _DateNavButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F7FB),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 18, color: const Color(0xFF7E8CA4)),
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
          color: isSelected ? const Color(0xFFD6F57C) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF253411)
                    : const Color(0xFF96A2B8),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              day,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF253411)
                    : const Color(0xFF17233D),
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
  const _EmptyCard({
    required this.title,
    required this.message,
  });

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
              color: Color(0xFF13213B),
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF6F7F9C),
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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

class _SplitBillSheet extends StatefulWidget {
  const _SplitBillSheet();

  @override
  State<_SplitBillSheet> createState() => _SplitBillSheetState();
}

class _SplitBillSheetState extends State<_SplitBillSheet> {
  final TextEditingController _amountController =
      TextEditingController(text: '0');
  int _peopleCount = 2;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final totalAmount = double.tryParse(_amountController.text) ?? 0;
    final perPerson = _peopleCount <= 0 ? 0 : totalAmount / _peopleCount;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DFEB),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Split Bill',
              style: TextStyle(
                color: Color(0xFF152039),
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Calculate a fair share before you save the final transaction.',
              style: TextStyle(
                color: Color(0xFF8EA0BC),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Total amount',
                prefixText: '₹ ',
                filled: true,
                fillColor: const Color(0xFFF6F8FC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FC),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'People',
                      style: TextStyle(
                        color: Color(0xFF152039),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _StepperButton(
                    icon: Icons.remove_rounded,
                    onTap: _peopleCount > 2
                        ? () => setState(() => _peopleCount -= 1)
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      '$_peopleCount',
                      style: const TextStyle(
                        color: Color(0xFF152039),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _StepperButton(
                    icon: Icons.add_rounded,
                    onTap: () => setState(() => _peopleCount += 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <double>[200, 500, 1000, 2000].map((amount) {
                return ActionChip(
                  label: Text(currency.format(amount)),
                  backgroundColor: const Color(0xFFEFF5FF),
                  labelStyle: const TextStyle(
                    color: Color(0xFF0A6BE8),
                    fontWeight: FontWeight.w800,
                  ),
                  onPressed: () {
                    _amountController.text = amount.toStringAsFixed(0);
                    setState(() {});
                  },
                );
              }).toList(growable: false),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFF0A6BE8), Color(0xFF56A0FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Per person',
                    style: TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currency.format(perPerson),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null ? const Color(0xFFF1F4F8) : const Color(0xFFE8F1FF),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            icon,
            color: onTap == null
                ? const Color(0xFFAAB7CB)
                : const Color(0xFF0A6BE8),
            size: 18,
          ),
        ),
      ),
    );
  }
}
