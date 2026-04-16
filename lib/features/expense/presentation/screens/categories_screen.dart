import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_tab_switcher.dart';
import '../../data/models/account_model.dart';
import '../../data/models/expense_model.dart';
import '../provider/account_providers.dart';
import '../provider/budget_providers.dart';
import '../provider/expense_providers.dart';
import '../provider/preferences_providers.dart';
import '../widgets/account_editor_sheet.dart';
import '../widgets/account_icons.dart';
import '../widgets/amount_visibility.dart';
import '../widgets/budget_editor_sheet.dart';
import '../widgets/expense_category.dart';
import 'categories/categories_widgets.dart';

enum _BoardMode { expenses, income, accounts }

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  _BoardMode _mode = _BoardMode.expenses;

  static const List<AppTabItem> _categoryTabs = <AppTabItem>[
    AppTabItem(label: 'Expense', icon: Icons.arrow_outward_rounded),
    AppTabItem(label: 'Income', icon: Icons.arrow_downward_rounded),
    AppTabItem(label: 'Account', icon: Icons.account_balance_wallet_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);
    final budgetState = ref.watch(budgetTargetsProvider);
    final accountState = ref.watch(accountListProvider);
    final accountSummary = ref.watch(accountSummaryProvider);
    final privacyModeEnabled = ref.watch(privacyModeEnabledProvider);
    final currency = ref.watch(currencyFormatProvider);
    final disabledExpenseCategories =
        ref.watch(disabledExpenseCategoriesProvider);
    final disabledIncomeCategories =
        ref.watch(disabledIncomeCategoriesProvider);
    final disabledAccountIds = ref.watch(disabledAccountIdsProvider);
    final budgets = budgetState.value ?? defaultBudgetTargets;
    final accounts = accountState.value ?? const <AccountModel>[];

    final summaryAmount = _summaryAmount(
      mode: _mode,
      currency: currency,
      stats: stats,
      accountSummary: accountSummary,
      masked: privacyModeEnabled,
    );
    final summaryLabel = _summaryLabel(_mode);
    final cards = _buildCards(
      mode: _mode,
      stats: stats,
      budgets: budgets,
      accounts: accounts,
      disabledExpenseCategories: disabledExpenseCategories,
      disabledIncomeCategories: disabledIncomeCategories,
      disabledAccountIds: disabledAccountIds,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppPageHeader(
          eyebrow: 'Categories',
          title: summaryAmount,
          subtitle: summaryLabel,
          bottom: AppTabSwitcher(
            tabs: _categoryTabs,
            selected: _mode.index,
            onChanged: (index) {
              setState(() {
                _mode = _BoardMode.values[index];
              });
            },
          ),
        ),
        if ((_mode == _BoardMode.expenses && budgetState.isLoading) ||
            (_mode == _BoardMode.accounts && accountState.isLoading))
          const LinearProgressIndicator(minHeight: 3),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 124),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width >= 900
                    ? 4
                    : width >= 640
                        ? 3
                        : 2;
                final ratio = width >= 900
                    ? 1.35
                    : width >= 640
                        ? 1.28
                        : 1.22;

                return GridView.builder(
                  itemCount: cards.length + 1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: ratio,
                  ),
                  itemBuilder: (context, index) {
                    if (index == cards.length) {
                      return AddCategoryCard(
                        onTap: _handlePrimaryActionTap,
                        title: _actionTitle(_mode),
                        detail: _actionDetail(_mode),
                      );
                    }

                    final entry = cards[index];
                    return CategoryGridCard(
                      title: entry.title,
                      icon: entry.icon,
                      tone: entry.tone,
                      amount: _displayAmount(
                          entry.amount, entry.amountColor, currency,
                          masked: privacyModeEnabled),
                      progressLabel: entry.progressLabel,
                      progress: entry.progress,
                      isEnabled: entry.isEnabled,
                      onTap: entry.onTap,
                      onToggle: entry.onToggle,
                      amountColor: entry.amountColor,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  List<CategoryGridData> _buildCards({
    required _BoardMode mode,
    required ExpenseStats stats,
    required Map<String, double> budgets,
    required List<AccountModel> accounts,
    required Set<String> disabledExpenseCategories,
    required Set<String> disabledIncomeCategories,
    required Set<String> disabledAccountIds,
  }) {
    switch (mode) {
      case _BoardMode.expenses:
        return expenseCategories.map(
          (category) {
            final amount = stats.categoryTotals[category.name] ?? 0;
            final budget = budgets[category.name] ?? 0;
            final isEnabled =
                !disabledExpenseCategories.contains(category.name);
            return CategoryGridData(
              title: category.name,
              icon: category.icon,
              tone: category.color,
              amount: amount,
              amountColor: AppColors.textDark,
              progress: _progressForExpenseCategory(
                amount: amount,
                budget: budget,
                monthTotal: stats.monthTotal,
              ),
              isEnabled: isEnabled,
              progressLabel: _expenseProgressLabel(
                amount: amount,
                budget: budget,
                monthTotal: stats.monthTotal,
                enabled: isEnabled,
              ),
              onTap: () => _openBudgetEditor(
                categoryName: category.name,
                currentBudget: budget,
              ),
              onToggle: (value) =>
                  _setExpenseCategoryEnabled(category.name, value),
            );
          },
        ).toList(growable: false);
      case _BoardMode.income:
        return incomeCategories.map(
          (category) {
            final amount = stats.incomeCategoryTotals[category.name] ?? 0;
            final isEnabled = !disabledIncomeCategories.contains(category.name);
            return CategoryGridData(
              title: category.name,
              icon: category.icon,
              tone: category.color,
              amount: amount,
              amountColor: AppColors.success,
              progress: _progressForIncomeCategory(
                amount: amount,
                monthTotal: stats.monthIncomeTotal,
              ),
              isEnabled: isEnabled,
              progressLabel: _incomeProgressLabel(
                amount: amount,
                monthTotal: stats.monthIncomeTotal,
                enabled: isEnabled,
              ),
              onTap: null,
              onToggle: (value) =>
                  _setIncomeCategoryEnabled(category.name, value),
            );
          },
        ).toList(growable: false);
      case _BoardMode.accounts:
        final totalAbsoluteBalance = accounts.fold<double>(
          0,
          (sum, account) => sum + account.balance.abs(),
        );

        return accounts.map(
          (account) {
            final isEnabled = !disabledAccountIds.contains(account.id);
            return CategoryGridData(
              title: account.name,
              icon: resolveAccountIcon(account.iconKey),
              tone: AppColors.primaryBlue,
              amount: account.balance,
              amountColor: account.balance < 0
                  ? AppColors.danger
                  : AppColors.primaryBlue,
              progress: totalAbsoluteBalance == 0
                  ? 0
                  : (account.balance.abs() / totalAbsoluteBalance),
              isEnabled: isEnabled,
              progressLabel: _accountProgressLabel(
                balance: account.balance,
                totalAbsoluteBalance: totalAbsoluteBalance,
                enabled: isEnabled,
              ),
              onTap: () => _openAccountEditor(account: account),
              onToggle: (value) => _setAccountEnabled(account.id, value),
            );
          },
        ).toList(growable: false);
    }
  }

  String _displayAmount(
    double amount,
    Color? amountColor,
    NumberFormat currency, {
    required bool masked,
  }) {
    if (amountColor == AppColors.success) {
      return '+${maskAmount(currency.format(amount), masked: masked)}';
    }

    if (amount < 0) {
      return '-${maskAmount(currency.format(amount.abs()), masked: masked)}';
    }

    return maskAmount(currency.format(amount), masked: masked);
  }

  String _summaryAmount({
    required _BoardMode mode,
    required NumberFormat currency,
    required ExpenseStats stats,
    required AccountSummary accountSummary,
    required bool masked,
  }) {
    switch (mode) {
      case _BoardMode.expenses:
        return maskAmount(currency.format(stats.monthTotal), masked: masked);
      case _BoardMode.income:
        return maskAmount(currency.format(stats.monthIncomeTotal),
            masked: masked);
      case _BoardMode.accounts:
        final balance = accountSummary.totalBalance;
        if (balance < 0) {
          return '-${maskAmount(currency.format(balance.abs()), masked: masked)}';
        }
        return maskAmount(currency.format(balance), masked: masked);
    }
  }

  String _summaryLabel(_BoardMode mode) {
    switch (mode) {
      case _BoardMode.expenses:
        return 'Expenses this month';
      case _BoardMode.income:
        return 'Income this month';
      case _BoardMode.accounts:
        return 'Tracked account balance';
    }
  }

  String _actionTitle(_BoardMode mode) {
    switch (mode) {
      case _BoardMode.expenses:
        return 'Set budget';
      case _BoardMode.income:
        return 'Add income';
      case _BoardMode.accounts:
        return 'Add account';
    }
  }

  String _actionDetail(_BoardMode mode) {
    switch (mode) {
      case _BoardMode.expenses:
        return 'Create or update a monthly limit.';
      case _BoardMode.income:
        return 'Create a new income entry.';
      case _BoardMode.accounts:
        return 'Create a new account entry.';
    }
  }

  void _handlePrimaryActionTap() {
    switch (_mode) {
      case _BoardMode.expenses:
        _openBudgetEditor(
          categoryName: expenseCategories.first.name,
          currentBudget: (ref.read(budgetTargetsProvider).value ??
                  defaultBudgetTargets)[expenseCategories.first.name] ??
              0,
        );
        return;
      case _BoardMode.income:
        final disabledIncomeCategories =
            ref.read(disabledIncomeCategoriesProvider);
        for (final category in incomeCategories) {
          if (!disabledIncomeCategories.contains(category.name)) {
            _openTransactionComposer(category.name, TransactionType.income);
            return;
          }
        }
        _showFeedback('Enable at least one income category first.');
        return;
      case _BoardMode.accounts:
        _openAccountEditor();
        return;
    }
  }

  String _expenseProgressLabel({
    required double amount,
    required double budget,
    required double monthTotal,
    required bool enabled,
  }) {
    if (!enabled) {
      return 'Disabled in composer';
    }
    if (budget > 0) {
      if (amount <= 0) {
        return 'Budget tracked';
      }
      final share = ((amount / budget) * 100).round();
      return '$share% of budget';
    }
    if (monthTotal <= 0 || amount <= 0) {
      return 'No spending yet';
    }
    final share = ((amount / monthTotal) * 100).round();
    return '$share% of monthly spend';
  }

  String _incomeProgressLabel({
    required double amount,
    required double monthTotal,
    required bool enabled,
  }) {
    if (!enabled) {
      return 'Disabled in composer';
    }
    if (monthTotal <= 0 || amount <= 0) {
      return 'No income yet';
    }

    final share = ((amount / monthTotal) * 100).round();
    return '$share% of monthly income';
  }

  String _accountProgressLabel({
    required double balance,
    required double totalAbsoluteBalance,
    required bool enabled,
  }) {
    if (!enabled) {
      return 'Disabled in composer';
    }
    if (totalAbsoluteBalance <= 0 || balance == 0) {
      return 'No balance yet';
    }
    final share = ((balance.abs() / totalAbsoluteBalance) * 100).round();
    return '$share% of tracked balance';
  }

  double _progressForExpenseCategory({
    required double amount,
    required double budget,
    required double monthTotal,
  }) {
    if (budget > 0) {
      return (amount / budget).clamp(0, 1);
    }
    if (monthTotal <= 0 || amount <= 0) {
      return 0;
    }
    return (amount / monthTotal).clamp(0, 1);
  }

  double _progressForIncomeCategory({
    required double amount,
    required double monthTotal,
  }) {
    if (monthTotal <= 0 || amount <= 0) {
      return 0;
    }
    return (amount / monthTotal).clamp(0, 1);
  }

  Future<void> _setExpenseCategoryEnabled(
      String categoryName, bool enabled) async {
    try {
      await ref
          .read(appPreferencesControllerProvider)
          .setExpenseCategoryEnabled(categoryName, enabled);
    } catch (_) {
      _showFeedback('Could not update $categoryName.');
    }
  }

  Future<void> _setIncomeCategoryEnabled(
      String categoryName, bool enabled) async {
    try {
      await ref
          .read(appPreferencesControllerProvider)
          .setIncomeCategoryEnabled(categoryName, enabled);
    } catch (_) {
      _showFeedback('Could not update $categoryName.');
    }
  }

  Future<void> _setAccountEnabled(String accountId, bool enabled) async {
    try {
      await ref.read(appPreferencesControllerProvider).setAccountEnabled(
            accountId,
            enabled,
          );
    } catch (_) {
      _showFeedback('Could not update the account state.');
    }
  }

  Future<void> _openBudgetEditor({
    required String categoryName,
    required double currentBudget,
  }) async {
    final result = await showBudgetEditorSheet(
      context,
      categories: expenseCategories,
      initialCategory: categoryName,
      initialAmount: currentBudget,
      currencySymbol: ref.read(currencySymbolProvider),
    );

    if (result == null) {
      return;
    }

    await ref
        .read(budgetControllerProvider)
        .saveBudget(category: result.category, monthlyLimit: result.amount);

    if (!mounted) {
      return;
    }

    if (ref.read(budgetTargetsProvider).hasError) {
      _showFeedback('Could not save ${result.category} budget.');
      return;
    }

    _showFeedback('${result.category} budget updated.');
  }

  Future<void> _openTransactionComposer(String category, TransactionType type) {
    return AppRoutes.pushAddExpense(
      context,
      initialCategory: category,
      initialType: type,
    );
  }

  Future<void> _openAccountEditor({AccountModel? account}) async {
    final result = await showAccountEditorSheet(context, account: account);
    if (result == null) {
      return;
    }

    await ref.read(accountControllerProvider).saveAccount(
          id: result.id,
          name: result.name,
          iconKey: result.iconKey,
          balance: result.balance,
        );

    if (!mounted) {
      return;
    }

    if (ref.read(accountListProvider).hasError) {
      _showFeedback('Could not save ${result.name}.');
      return;
    }

    _showFeedback(account == null
        ? '${result.name} created.'
        : '${result.name} updated.');
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

