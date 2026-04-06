import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../data/models/account_model.dart';
import '../../data/models/expense_model.dart';
import '../provider/account_providers.dart';
import '../provider/expense_providers.dart';
import '../provider/preferences_providers.dart';
import '../widgets/quick_action_bar.dart';
import '../widgets/transaction_card.dart';
import '../widgets/ui_feedback.dart';
import 'home/home_date_strip.dart';
import 'home/home_header.dart';
import 'home/home_misc_widgets.dart';

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

    final currencyFormat = ref.watch(currencyFormatProvider);
    final visibleDates = List<DateTime>.generate(
      7,
      (index) => _windowStart.add(Duration(days: index)),
    );
    final selectedExpenses =
        expenses
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
          HomeHeader(
            stats: stats,
            currencyFormat: currencyFormat,
            privacyModeEnabled: privacyModeEnabled,
            onMenuPressed: () => Scaffold.of(context).openDrawer(),
            onSearchPressed: () => AppRoutes.pushTransactionSearch(context),
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
                    children: <double>[50, 100, 200, 500, 1000]
                        .map((amount) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: HomeAmountChip(
                              label: currencyFormat.format(amount),
                              onTap: () => _openAddExpenseScreen(
                                context,
                                initialAmount: amount,
                                initialDate: _selectedDate,
                              ),
                            ),
                          );
                        })
                        .toList(growable: false),
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
                HomeDateStrip(
                  visibleDates: visibleDates,
                  selectedDate: _selectedDate,
                  selectedTotalText: formatSignedCurrencyForHome(
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
                  const HomeEmptyCard(
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
                  const HomeEmptyCard(
                    title: 'No expenses yet',
                    message:
                        'Tap the blue add button or choose a quick amount to record your first transaction.',
                  )
                else if (selectedExpenses.isEmpty)
                  HomeEmptyCard(
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
    return AppRoutes.pushAddExpense(
      context,
      initialAmount: initialAmount,
      initialCategory: initialCategory,
      initialDate: initialDate,
    );
  }

  Future<void> _openEditExpenseScreen(
    BuildContext context,
    ExpenseModel expense,
  ) {
    return AppRoutes.pushEditExpense(
      context,
      expenseId: expense.id,
      initialAmount: expense.amount,
      initialCategory: expense.category,
      initialDate: expense.date.toLocal(),
      initialNote: expense.note,
      initialAccountId: expense.accountId,
      initialType: expense.type,
    );
  }

  Future<void> _openRecordsHistoryScreen(BuildContext context) {
    return AppRoutes.pushRecordsHistory(context);
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
    ExpenseModel expense,
    Map<String, AccountModel> accountsMap,
  ) {
    if (expense.accountId == null) {
      return null;
    }

    return accountsMap[expense.accountId]?.name ?? 'Archived Account';
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
