import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_tab_switcher.dart';
import '../../data/models/account_model.dart';
import '../../data/models/custom_category_model.dart';
import '../../data/models/expense_model.dart';
import '../provider/account_providers.dart';
import '../provider/budget_providers.dart';
import '../provider/expense_providers.dart';
import '../provider/preferences_providers.dart';
import '../widgets/account_editor_sheet.dart';
import '../widgets/account_icons.dart';
import '../widgets/amount_visibility.dart';
import '../widgets/category_editor_sheet.dart';
import '../widgets/expense_category.dart';
import 'categories/categories_widgets.dart';

enum _BoardMode { expenses, income, accounts }

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  _BoardMode _mode = _BoardMode.expenses;

  static const List<AppTabItem> _categoryTabs = <AppTabItem>[
    AppTabItem(label: 'Expense', icon: Icons.arrow_outward_rounded),
    AppTabItem(label: 'Income', icon: Icons.arrow_downward_rounded),
    AppTabItem(label: 'Account', icon: Icons.account_balance_wallet_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categoryTabs.length, vsync: this);
    _tabController.addListener(() {
      final newIndex = _tabController.index;
      final newMode = _BoardMode.values[newIndex];
      if (_mode != newMode) {
        setState(() => _mode = newMode);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
    final allExpenseCategories = ref.watch(allExpenseCategoriesProvider);
    final allIncomeCategories = ref.watch(allIncomeCategoriesProvider);
    final customExpenseCategories =
        ref.watch(customExpenseCategoryListProvider);
    final customIncomeCategories = ref.watch(customIncomeCategoryListProvider);
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
              _tabController.animateTo(index);
            },
          ),
        ),
        if ((_mode == _BoardMode.expenses && budgetState.isLoading) ||
            (_mode == _BoardMode.accounts && accountState.isLoading))
          const LinearProgressIndicator(minHeight: 3),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _BoardMode.values.map((mode) {
              final modeCards = _buildCards(
                mode: mode,
                stats: stats,
                budgets: budgets,
                accounts: accounts,
                disabledExpenseCategories: disabledExpenseCategories,
                disabledIncomeCategories: disabledIncomeCategories,
                disabledAccountIds: disabledAccountIds,
                allExpenseCategories: allExpenseCategories,
                allIncomeCategories: allIncomeCategories,
                customExpenseCategories: customExpenseCategories,
                customIncomeCategories: customIncomeCategories,
              );
              return _buildModeScrollPane(
                mode: mode,
                cards: modeCards,
                currency: currency,
                privacyModeEnabled: privacyModeEnabled,
              );
            }).toList(growable: false),
          ),
        ),
      ],
    );
  }

  Widget _buildModeScrollPane({
    required _BoardMode mode,
    required List<CategoryGridData> cards,
    required NumberFormat currency,
    required bool privacyModeEnabled,
  }) {
    return SingleChildScrollView(
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
                  onTap: () => _handlePrimaryActionTapFor(mode),
                  title: _actionTitle(mode),
                  detail: _actionDetail(mode),
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
    required List<ExpenseCategory> allExpenseCategories,
    required List<ExpenseCategory> allIncomeCategories,
    required List<CustomCategoryModel> customExpenseCategories,
    required List<CustomCategoryModel> customIncomeCategories,
  }) {
    final builtInExpenseNames = expenseCategories.map((c) => c.name).toSet();
    final builtInIncomeNames = incomeCategories.map((c) => c.name).toSet();

    switch (mode) {
      case _BoardMode.expenses:
        return allExpenseCategories.map(
          (category) {
            final amount = stats.categoryTotals[category.name] ?? 0;
            final budget = budgets[category.name] ?? 0;
            final isEnabled =
                !disabledExpenseCategories.contains(category.name);
            final isCustom = !builtInExpenseNames.contains(category.name);
            final customModel = isCustom
                ? customExpenseCategories
                    .where((c) => c.name == category.name)
                    .firstOrNull
                : null;
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
              onTap: isCustom && customModel != null
                  ? () => _openCustomCategoryEditor(
                        customModel,
                        TransactionType.expense,
                        budget,
                      )
                  : () => _openBuiltInCategoryEditor(
                        category,
                        budget,
                        TransactionType.expense,
                      ),
              onToggle: (value) =>
                  _setExpenseCategoryEnabled(category.name, value),
            );
          },
        ).toList(growable: false);
      case _BoardMode.income:
        return allIncomeCategories.map(
          (category) {
            final amount = stats.incomeCategoryTotals[category.name] ?? 0;
            final budget = budgets[category.name] ?? 0;
            final isEnabled = !disabledIncomeCategories.contains(category.name);
            final isCustom = !builtInIncomeNames.contains(category.name);
            final customModel = isCustom
                ? customIncomeCategories
                    .where((c) => c.name == category.name)
                    .firstOrNull
                : null;
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
              onTap: isCustom && customModel != null
                  ? () => _openCustomCategoryEditor(
                        customModel,
                        TransactionType.income,
                        budget,
                      )
                  : () => _openBuiltInCategoryEditor(
                        category,
                        budget,
                        TransactionType.income,
                      ),
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
        return 'Add category';
      case _BoardMode.income:
        return 'Add category';
      case _BoardMode.accounts:
        return 'Add account';
    }
  }

  String _actionDetail(_BoardMode mode) {
    switch (mode) {
      case _BoardMode.expenses:
        return 'Create your own expense category.';
      case _BoardMode.income:
        return 'Create your own income category.';
      case _BoardMode.accounts:
        return 'Create a new account entry.';
    }
  }

  void _handlePrimaryActionTapFor(_BoardMode mode) {
    switch (mode) {
      case _BoardMode.expenses:
        _openCategoryCreator(TransactionType.expense);
        return;
      case _BoardMode.income:
        _openCategoryCreator(TransactionType.income);
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

  Future<void> _openCategoryCreator(TransactionType type) async {
    final result = await showCategoryEditorSheet(
      context,
      currencySymbol: ref.read(currencySymbolProvider),
    );
    if (result == null || !mounted) return;

    final newCategory = CustomCategoryModel.create(
      name: result.name,
      iconKey: result.iconKey,
      colorHex: result.colorHex,
    );

    final controller = ref.read(appPreferencesControllerProvider);
    if (type == TransactionType.expense) {
      await controller.addExpenseCategory(newCategory);
    } else {
      await controller.addIncomeCategory(newCategory);
    }

    if (result.monthlyLimit != null && result.monthlyLimit! > 0) {
      await ref.read(budgetControllerProvider).saveBudget(
            category: result.name,
            monthlyLimit: result.monthlyLimit!,
          );
    }

    if (!mounted) return;
    _showFeedback('${result.name} created.');
  }

  Future<void> _openCustomCategoryEditor(
    CustomCategoryModel existing,
    TransactionType type,
    double currentBudget,
  ) async {
    final result = await showCategoryEditorSheet(
      context,
      editName: existing.name,
      editIconKey: existing.iconKey,
      editColorHex: existing.colorHex,
      editMonthlyLimit: currentBudget > 0 ? currentBudget : null,
      currencySymbol: ref.read(currencySymbolProvider),
    );
    if (result == null || !mounted) return;

    final controller = ref.read(appPreferencesControllerProvider);

    if (result.isDelete) {
      if (type == TransactionType.expense) {
        await controller.removeExpenseCategory(existing.id);
      } else {
        await controller.removeIncomeCategory(existing.id);
      }
      if (!mounted) return;
      _showFeedback('${existing.name} deleted.');
      return;
    }

    final updated = existing.copyWith(
      name: result.name,
      iconKey: result.iconKey,
      colorHex: result.colorHex,
    );

    if (type == TransactionType.expense) {
      await controller.updateExpenseCategory(updated);
    } else {
      await controller.updateIncomeCategory(updated);
    }

    if (result.monthlyLimit != null) {
      await ref.read(budgetControllerProvider).saveBudget(
            category: result.name,
            monthlyLimit: result.monthlyLimit!,
          );
    }

    if (!mounted) return;
    _showFeedback('${result.name} updated.');
  }

  Future<void> _openBuiltInCategoryEditor(
    ExpenseCategory category,
    double currentBudget,
    TransactionType type,
  ) async {
    final result = await showCategoryEditorSheet(
      context,
      editName: category.name,
      editIconKey: category.iconKey,
      editColorHex: category.colorHex,
      editMonthlyLimit: currentBudget > 0 ? currentBudget : null,
      isBuiltIn: true,
      currencySymbol: ref.read(currencySymbolProvider),
    );
    if (result == null || !mounted) return;

    final override = BuiltInCategoryOverride(
      name: category.name,
      iconKey: result.iconKey,
      colorHex: result.colorHex,
    );

    final controller = ref.read(appPreferencesControllerProvider);
    if (type == TransactionType.expense) {
      await controller.saveBuiltInExpenseCategoryOverride(override);
    } else {
      await controller.saveBuiltInIncomeCategoryOverride(override);
    }

    if (result.monthlyLimit != null) {
      await ref.read(budgetControllerProvider).saveBudget(
            category: category.name,
            monthlyLimit: result.monthlyLimit!,
          );
    }

    if (!mounted) return;
    _showFeedback('${category.name} updated.');
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
