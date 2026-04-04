import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/account_model.dart';
import '../../data/models/expense_model.dart';
import '../provider/account_providers.dart';
import '../provider/expense_providers.dart';
import '../provider/preferences_providers.dart';
import '../widgets/transaction_card.dart';
import '../widgets/ui_feedback.dart';
import 'add_expense_screen.dart';

class TransactionSearchScreen extends ConsumerStatefulWidget {
  const TransactionSearchScreen({super.key});

  @override
  ConsumerState<TransactionSearchScreen> createState() =>
      _TransactionSearchScreenState();
}

class _TransactionSearchScreenState
    extends ConsumerState<TransactionSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = ref.watch(filteredExpensesProvider);
    final accounts =
        ref.watch(accountListProvider).value ?? const <AccountModel>[];
    final accountMap = {for (final account in accounts) account.id: account};
    final privacyModeEnabled = ref.watch(privacyModeEnabledProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: const InputDecoration(
            hintText: 'Search transactions...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).updateQuery(value);
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).updateQuery('');
              },
            ),
        ],
      ),
      body: filteredExpenses.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredExpenses.length,
              itemBuilder: (context, index) {
                final expense = filteredExpenses[index];
                return TransactionCard(
                  expense: expense,
                  accountLabel: _accountLabelFor(expense, accountMap),
                  maskAmounts: privacyModeEnabled,
                  onEdit: () => _openEditExpenseScreen(context, expense),
                  onDelete: () => _confirmDeleteExpense(expense),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    final query = ref.watch(searchQueryProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            query.isEmpty ? Icons.search_rounded : Icons.search_off_rounded,
            size: 64,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            query.isEmpty ? 'Type to search' : 'No results found',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String? _accountLabelFor(
    ExpenseModel expense,
    Map<String, AccountModel> accountMap,
  ) {
    if (expense.accountId == null) return null;
    return accountMap[expense.accountId]?.name ?? 'Archived Account';
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

  Future<void> _confirmDeleteExpense(ExpenseModel expense) async {
    final label = expense.note.isEmpty ? expense.category : expense.note;
    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Delete transaction?',
      message: 'Remove "$label" from your search results and records?',
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
