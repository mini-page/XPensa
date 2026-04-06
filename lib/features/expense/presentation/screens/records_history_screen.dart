import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../data/models/account_model.dart';
import '../../data/models/expense_model.dart';
import '../provider/account_providers.dart';
import '../provider/expense_providers.dart';
import '../provider/preferences_providers.dart';
import '../widgets/ui_feedback.dart';
import 'records_history/records_cards.dart';
import 'records_history/records_expense_list.dart';
import 'records_history/records_filter.dart';
import 'records_history/records_filter_bar.dart';

export 'records_history/records_filter.dart';

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
    final expenses = expenseState.value ?? const <ExpenseModel>[];
    final accounts = accountState.value ?? const <AccountModel>[];
    final accountMap = {for (final a in accounts) a.id: a};
    final filteredExpenses = _filterExpenses(expenses);
    final groupedExpenses = _groupExpenses(filteredExpenses);

    final currency = ref.watch(currencyFormatProvider);
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
            color: AppColors.textDark,
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
              RecordsSummaryCard(
                filteredTotal: filteredTotal,
                transactionCount: filteredExpenses.length,
                currency: currency,
                privacyModeEnabled: privacyModeEnabled,
              ),
              const SizedBox(height: 18),
              RecordsFilterChips(
                selectedFilter: _selectedFilter,
                onFilterSelected: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                labelForFilter: _labelForFilter,
              ),
              const SizedBox(height: 14),
              RecordsAccountDropdown(
                accounts: accounts,
                onAccountSelected: (value) {
                  setState(() {
                    _selectedAccountFilter = value;
                  });
                },
                allAccountsKey: _allAccountsKey,
                accountFilterLabel: _accountFilterLabel(accountMap),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: expenseState.hasError
                    ? const RecordsStateCard(
                        title: 'Unable to load records',
                        message:
                            'The transaction history is not available right now.',
                      )
                    : expenseState.isLoading && expenses.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : filteredExpenses.isEmpty
                    ? const RecordsStateCard(
                        title: 'No matching transactions',
                        message: 'Try another filter or add a new expense.',
                      )
                    : RecordsExpenseList(
                        groupedExpenses: groupedExpenses,
                        accounts: accounts,
                        privacyModeEnabled: privacyModeEnabled,
                        groupLabel: _groupLabel,
                        accountLabelFor: _accountLabelFor,
                        onEdit: (expense) =>
                            _openEditExpenseScreen(context, expense),
                        onDelete: (expense) =>
                            _confirmDeleteExpense(context, ref, expense),
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

    return expenses
        .where((expense) {
          final localDate = expense.date.toLocal();
          final dateOnly = DateUtils.dateOnly(localDate);
          final matchesAccount =
              _selectedAccountFilter == _allAccountsKey ||
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
              return dateOnly.year == today.year &&
                  dateOnly.month == today.month;
            case RecordsFilter.future:
              return dateOnly.isAfter(today);
            case RecordsFilter.all:
              return true;
          }
        })
        .toList(growable: false)
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

  String _accountFilterLabel(Map<String, AccountModel> accountMap) {
    if (_selectedAccountFilter == _allAccountsKey) {
      return 'All accounts';
    }
    return accountMap[_selectedAccountFilter]?.name ?? 'Archived account';
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
    for (final a in accounts) {
      if (a.id == expense.accountId) {
        return a.name;
      }
    }
    return 'Archived Account';
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

  Future<void> _confirmDeleteExpense(
    BuildContext context,
    WidgetRef ref,
    ExpenseModel expense,
  ) async {
    final label = expense.note.isEmpty ? expense.category : expense.note;
    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Delete transaction?',
      message: 'Remove "$label" from your records? This cannot be undone.',
      confirmLabel: 'Delete txn',
    );
    if (!confirmed || !context.mounted) {
      return;
    }

    await ref.read(expenseControllerProvider).deleteExpense(expense.id);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Transaction removed.')));
  }
}
