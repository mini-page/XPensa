import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/account_model.dart';
import '../../data/models/expense_model.dart';
import '../provider/account_providers.dart';
import '../provider/expense_providers.dart';
import '../provider/preferences_providers.dart';
import '../widgets/amount_visibility.dart';
import '../widgets/transaction_card.dart';
import 'add_expense_screen.dart';

enum RecordsFilter { all, today, week, month, future }

class RecordsHistoryScreen extends ConsumerStatefulWidget {
  const RecordsHistoryScreen({super.key});

  @override
  ConsumerState<RecordsHistoryScreen> createState() =>
      _RecordsHistoryScreenState();
}

class _RecordsHistoryScreenState extends ConsumerState<RecordsHistoryScreen> {
  static const String _allAccountsKey = '__all_accounts__';
  RecordsFilter _selectedFilter = RecordsFilter.all;
  String _selectedAccountFilter = _allAccountsKey;

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseListProvider);
    final accountState = ref.watch(accountListProvider);
    final privacyModeEnabled = ref.watch(privacyModeEnabledProvider);
    final expenses = expenseState.valueOrNull ?? const <ExpenseModel>[];
    final accounts = accountState.valueOrNull ?? const <AccountModel>[];
    final filteredExpenses = _filterExpenses(expenses);
    final groupedExpenses = _groupExpenses(filteredExpenses);
    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final filteredTotal = filteredExpenses.fold<double>(
      0,
      (sum, expense) => sum + expense.signedAmount,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Records',
          style: TextStyle(
            color: Color(0xFF152039),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
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
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Filtered Net',
                            style: TextStyle(
                              color: Color(0xFF0A6BE8),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatSignedAmount(
                              filteredTotal,
                              currency,
                              masked: privacyModeEnabled,
                            ),
                            style: TextStyle(
                              color: filteredTotal >= 0
                                  ? const Color(0xFF1DAA63)
                                  : const Color(0xFFFF446D),
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF5FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: <Widget>[
                          const Text(
                            'TXNS',
                            style: TextStyle(
                              color: Color(0xFF7A8BA8),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${filteredExpenses.length}',
                            style: const TextStyle(
                              color: Color(0xFF0A6BE8),
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: RecordsFilter.values.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(_labelForFilter(filter)),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        selectedColor: const Color(0xFF0A6BE8),
                        backgroundColor: const Color(0xFFEFF5FF),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF48607E),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList(growable: false),
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: PopupMenuButton<String>(
                  color: Colors.white,
                  onSelected: (value) {
                    setState(() {
                      _selectedAccountFilter = value;
                    });
                  },
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: _allAccountsKey,
                      child: Text('All accounts'),
                    ),
                    ...accounts.map((account) {
                      return PopupMenuItem<String>(
                        value: account.id,
                        child: Text(account.name),
                      );
                    }),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x1209386D),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 18,
                          color: Color(0xFF0A6BE8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _accountFilterLabel(accounts),
                          style: const TextStyle(
                            color: Color(0xFF152039),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF90A1BE),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: expenseState.hasError
                    ? const _StateCard(
                        title: 'Unable to load records',
                        message:
                            'The transaction history is not available right now.',
                      )
                    : expenseState.isLoading && expenses.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : filteredExpenses.isEmpty
                            ? const _StateCard(
                                title: 'No matching transactions',
                                message:
                                    'Try another filter or add a new expense.',
                              )
                            : ListView(
                                children: groupedExpenses.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 18),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            _groupLabel(entry.key),
                                            style: const TextStyle(
                                              color: Color(0xFF0A6BE8),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                        ...entry.value.map((expense) {
                                          return TransactionCard(
                                            expense: expense,
                                            accountLabel: _accountLabelFor(
                                                expense, accounts),
                                            maskAmounts: privacyModeEnabled,
                                            onEdit: () =>
                                                _openEditExpenseScreen(
                                                    context, expense),
                                            onDelete: () => ref
                                                .read(expenseControllerProvider)
                                                .deleteExpense(expense.id),
                                          );
                                        }),
                                      ],
                                    ),
                                  );
                                }).toList(growable: false),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ExpenseModel> _filterExpenses(List<ExpenseModel> expenses) {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final weekStart = today.subtract(Duration(days: now.weekday - 1));

    return expenses.where((expense) {
      final localDate = expense.date.toLocal();
      final dateOnly = DateUtils.dateOnly(localDate);
      final matchesAccount = _selectedAccountFilter == _allAccountsKey ||
          expense.accountId == _selectedAccountFilter;

      if (!matchesAccount) {
        return false;
      }

      switch (_selectedFilter) {
        case RecordsFilter.today:
          return DateUtils.isSameDay(dateOnly, today);
        case RecordsFilter.week:
          return !dateOnly.isBefore(weekStart) && !dateOnly.isAfter(today);
        case RecordsFilter.month:
          return dateOnly.year == today.year && dateOnly.month == today.month;
        case RecordsFilter.future:
          return dateOnly.isAfter(today);
        case RecordsFilter.all:
          return true;
      }
    }).toList(growable: false)
      ..sort((left, right) => right.date.compareTo(left.date));
  }

  SplayTreeMap<DateTime, List<ExpenseModel>> _groupExpenses(
    List<ExpenseModel> expenses,
  ) {
    final grouped = SplayTreeMap<DateTime, List<ExpenseModel>>(
      (left, right) => right.compareTo(left),
    );

    for (final expense in expenses) {
      final key = DateUtils.dateOnly(expense.date.toLocal());
      grouped.putIfAbsent(key, () => <ExpenseModel>[]).add(expense);
    }

    return grouped;
  }

  String _labelForFilter(RecordsFilter filter) {
    switch (filter) {
      case RecordsFilter.today:
        return 'Today';
      case RecordsFilter.week:
        return 'This Week';
      case RecordsFilter.month:
        return 'This Month';
      case RecordsFilter.future:
        return 'Future';
      case RecordsFilter.all:
        return 'All';
    }
  }

  String _accountFilterLabel(List<AccountModel> accounts) {
    if (_selectedAccountFilter == _allAccountsKey) {
      return 'All accounts';
    }

    for (final account in accounts) {
      if (account.id == _selectedAccountFilter) {
        return account.name;
      }
    }

    return 'Archived account';
  }

  String _groupLabel(DateTime date) {
    final today = DateUtils.dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    if (DateUtils.isSameDay(date, today)) {
      return 'Today';
    }
    if (DateUtils.isSameDay(date, yesterday)) {
      return 'Yesterday';
    }
    return DateFormat('EEE, d MMM yyyy').format(date);
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

  String _formatSignedAmount(
    double amount,
    NumberFormat currency, {
    required bool masked,
  }) {
    if (amount == 0) {
      return maskAmount(currency.format(0), masked: masked);
    }

    final absolute = maskAmount(currency.format(amount.abs()), masked: masked);
    return '${amount > 0 ? '+' : '-'}$absolute';
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF152039),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF6E7F9C),
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
