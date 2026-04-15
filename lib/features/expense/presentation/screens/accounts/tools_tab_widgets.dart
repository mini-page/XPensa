import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../routes/app_routes.dart';
import '../../../data/models/expense_model.dart';
import '../../provider/expense_providers.dart';
import '../../provider/preferences_providers.dart';
import '../../widgets/recurring_tool_view.dart';
import '../../widgets/split_bill_tool_view.dart';

const _maxDisplayedFutureTransactions = 6;

class ToolsTabHeader extends StatelessWidget {
  const ToolsTabHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: TabBar(
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800),
        tabs: const <Tab>[
          Tab(text: 'Split Expenses'),
          Tab(text: 'Recurring Subscriptions'),
          Tab(text: 'Future Transactions'),
        ],
      ),
    );
  }
}

class ToolsTabView extends StatelessWidget {
  const ToolsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBarView(
      children: <Widget>[
        _ToolsTabPane(child: SplitBillToolView()),
        _ToolsTabPane(child: RecurringToolView()),
        _ToolsTabPane(child: FutureTransactionsToolView()),
      ],
    );
  }
}

class _ToolsTabPane extends StatelessWidget {
  const _ToolsTabPane({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: child);
  }
}

class FutureTransactionsToolView extends ConsumerWidget {
  const FutureTransactionsToolView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseListProvider).value ?? const <ExpenseModel>[];
    final currency = ref.watch(currencyFormatProvider);
    final today = DateUtils.dateOnly(DateTime.now());

    final futureTransactions = expenses
        .where(
          (expense) => DateUtils.dateOnly(expense.date.toLocal()).isAfter(today),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Future Transactions',
          style: AppTextStyles.sectionHeading,
        ),
        const Text(
          'Review and plan upcoming entries',
          style: AppTextStyles.sectionSubtitle,
        ),
        const SizedBox(height: AppSpacing.md),
        if (futureTransactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.xl),
            ),
            child: const Text(
              'No future transactions yet. Add a transaction with a future date to plan ahead.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          ...futureTransactions.take(_maxDisplayedFutureTransactions).map((expense) {
            final signedAmount =
                expense.isIncome ? expense.amount : -expense.amount;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            expense.note.isEmpty ? expense.category : expense.note,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('EEE, d MMM').format(expense.date.toLocal()),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      currency.format(signedAmount),
                      style: TextStyle(
                        color: expense.isIncome
                            ? AppColors.success
                            : AppColors.primaryBlue,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => AppRoutes.pushAddExpense(
              context,
              initialDate: today.add(const Duration(days: 1)),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add future transaction'),
          ),
        ),
      ],
    );
  }
}
