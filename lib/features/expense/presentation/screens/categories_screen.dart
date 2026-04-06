import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import 'categories/categories_widgets.dart';
import '../../../../routes/app_routes.dart';
import '../../data/models/expense_model.dart';
import '../provider/budget_providers.dart';
import '../provider/expense_providers.dart';
import '../provider/preferences_providers.dart';
import '../widgets/amount_visibility.dart';
import '../widgets/budget_editor_sheet.dart';
import '../widgets/expense_category.dart';

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

    final currency = ref.watch(currencyFormatProvider);
    final budgets = budgetState.value ?? defaultBudgetTargets;

    final categoryCards = _showIncome
        ? incomeCategories
            .map(
              (category) => CategoryGridData(
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
              (category) => CategoryGridData(
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
                  child: CategoriesPillSwitch(
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
                  return CategoryGridCard(
                    title: entry.title,
                    icon: entry.icon,
                    tone: entry.tone,
                    amount: amountText,
                    detail: detailText,
                    actionLabel: _showIncome ? 'Quick Add' : 'Edit Budget',
                    onTap: entry.onTap,
                  );
                }),
                AddCategoryCard(
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${result.category} budget updated to ₹${result.amount.toStringAsFixed(0)}.',
        ),
      ),
    );
  }

  Future<void> _openTransactionComposer(String category, TransactionType type) {
    return AppRoutes.pushAddExpense(
      context,
      initialCategory: category,
      initialType: type,
    );
  }
}
