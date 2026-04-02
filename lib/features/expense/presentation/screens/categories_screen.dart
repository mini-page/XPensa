import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../data/models/expense_model.dart';
import '../provider/budget_providers.dart';
import '../provider/expense_providers.dart';
import '../provider/preferences_providers.dart';
import '../widgets/amount_visibility.dart';
import '../widgets/budget_editor_sheet.dart';
import '../widgets/expense_category.dart';
import 'add_expense_screen.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  bool _showIncome = false;

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);
    final budgetState = ref.watch(budgetTargetsProvider);
    final privacyModeEnabled = ref.watch(privacyModeEnabledProvider);
    final locale = ref.watch(localeProvider);
    final symbol = ref.watch(currencySymbolProvider);

    final currency = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 0,
    );
    final budgets = budgetState.value ?? defaultBudgetTargets;

    final categoryCards = _showIncome
        ? incomeCategories
            .map(
              (category) => _CategoryGridData(
                title: category.name,
                icon: category.icon,
                tone: category.color,
                amount: stats.incomeCategoryTotals[category.name] ?? 0,
                onTap: () => _openTransactionComposer(
                  category.name,
                  TransactionType.income,
                ),
              ),
            )
            .toList(growable: false)
        : expenseCategories
            .map(
              (category) => _CategoryGridData(
                title: category.name,
                icon: category.icon,
                tone: category.color,
                amount: stats.categoryTotals[category.name] ?? 0,
                budget: budgets[category.name] ?? 0,
                onTap: () => _openBudgetEditor(
                  categoryName: category.name,
                  currentBudget: budgets[category.name] ?? 0,
                ),
              ),
            )
            .toList(growable: false);

    final topAmount =
        _showIncome ? stats.monthIncomeTotal : stats.monthNetTotal;
    final topLabel =
        _showIncome ? 'Income captured this month' : 'Current net flow';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  _showIncome ? Icons.savings_outlined : Icons.blur_on_rounded,
                  color: AppColors.primaryBlue,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatSignedAmount(
                        topAmount,
                        currency,
                        masked: privacyModeEnabled,
                      ),
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              topLabel,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: _PillSwitch(
                    leftLabel: 'Expenses',
                    rightLabel: 'Incomes',
                    isRightSelected: _showIncome,
                    onChanged: (value) {
                      setState(() {
                        _showIncome = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _showIncome
                      ? () => _openTransactionComposer(
                            incomeCategories.first.name,
                            TransactionType.income,
                          )
                      : () => _openBudgetEditor(
                            categoryName: expenseCategories.first.name,
                            currentBudget:
                                budgets[expenseCategories.first.name] ?? 0,
                          ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    _showIncome ? 'Add Income' : 'Set Budget',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            if (budgetState.isLoading && !_showIncome)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: LinearProgressIndicator(minHeight: 4),
              ),
            const SizedBox(height: 22),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.82,
              children: <Widget>[
                ...categoryCards.map((entry) {
                  final amountText = _showIncome
                      ? '+${maskAmount(currency.format(entry.amount), masked: privacyModeEnabled)}'
                      : maskAmount(
                          currency.format(entry.amount),
                          masked: privacyModeEnabled,
                        );
                  final detailText = !_showIncome && entry.budget > 0
                      ? 'Budget ${maskAmount(currency.format(entry.budget), masked: privacyModeEnabled)}'
                      : null;
                  return _GridCategoryCard(
                    title: entry.title,
                    icon: entry.icon,
                    tone: entry.tone,
                    amount: amountText,
                    detail: detailText,
                    actionLabel: _showIncome ? 'Quick Add' : 'Edit Budget',
                    onTap: entry.onTap,
                  );
                }),
                _AddCategoryCard(
                  onTap: _showIncome
                      ? () => _openTransactionComposer(
                            incomeCategories.first.name,
                            TransactionType.income,
                          )
                      : () => _openBudgetEditor(
                            categoryName: expenseCategories.first.name,
                            currentBudget:
                                budgets[expenseCategories.first.name] ?? 0,
                          ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openBudgetEditor({
    required String categoryName,
    required double currentBudget,
  }) async {
    final result = await showBudgetEditorSheet(
      context,
      categories: expenseCategories.take(6).toList(growable: false),
      initialCategory: categoryName,
      initialAmount: currentBudget,
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

    context.showSnackBar(
      '${result.category} budget updated to ₹${result.amount.toStringAsFixed(0)}.',
    );
  }

  Future<void> _openTransactionComposer(String category, TransactionType type) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            AddExpenseScreen(initialCategory: category, initialType: type),
      ),
    );
  }
}

class _PillSwitch extends StatelessWidget {
  const _PillSwitch({
    required this.leftLabel,
    required this.rightLabel,
    required this.isRightSelected,
    required this.onChanged,
  });

  final String leftLabel;
  final String rightLabel;
  final bool isRightSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: <Widget>[
          _SwitchOption(
            label: leftLabel,
            isSelected: !isRightSelected,
            onTap: () => onChanged(false),
          ),
          _SwitchOption(
            label: rightLabel,
            isSelected: isRightSelected,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _SwitchOption extends StatelessWidget {
  const _SwitchOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textMuted,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _GridCategoryCard extends StatelessWidget {
  const _GridCategoryCard({
    required this.title,
    required this.icon,
    required this.tone,
    required this.amount,
    required this.actionLabel,
    required this.onTap,
    this.detail,
  });

  final String title;
  final IconData icon;
  final Color tone;
  final String amount;
  final String? detail;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tone.withOpacity(0.18),
      borderRadius: BorderRadius.circular(22),
      child: Semantics(
        button: true,
        label: 'Category details for $title',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tone.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF16233C),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        amount,
                        style: const TextStyle(
                          color: Color(0xFF0A6BE8),
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (detail != null) ...<Widget>[
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          detail!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF6C7D99),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                top: 6,
                right: 2,
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: tone.withOpacity(0.7),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.white,
                  onSelected: (_) => onTap(),
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'primary',
                      child: Text(actionLabel),
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

class _AddCategoryCard extends StatelessWidget {
  const _AddCategoryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFD8DFE9),
      borderRadius: BorderRadius.circular(22),
      child: Semantics(
        button: true,
        label: 'Add Category',
        child: Tooltip(
          message: 'Add new category',
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: const Center(
              child:
                  Icon(Icons.add_rounded, color: AppColors.textMuted, size: 40),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryGridData {
  const _CategoryGridData({
    required this.title,
    required this.icon,
    required this.tone,
    required this.amount,
    required this.onTap,
    this.budget = 0,
  });

  final String title;
  final IconData icon;
  final Color tone;
  final double amount;
  final double budget;
  final VoidCallback onTap;
}
