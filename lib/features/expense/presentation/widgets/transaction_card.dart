import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../provider/preferences_providers.dart';
import '../../data/models/expense_model.dart';
import 'amount_visibility.dart';
import 'expense_category.dart';

class TransactionCard extends ConsumerWidget {
  const TransactionCard({
    super.key,
    required this.expense,
    required this.onDelete,
    this.onEdit,
    this.accountLabel,
    this.maskAmounts = false,
  });

  final ExpenseModel expense;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final String? accountLabel;
  final bool maskAmounts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final symbol = ref.watch(currencySymbolProvider);

    final currencyFormat = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: expense.amount.truncateToDouble() == expense.amount ? 0 : 2,
    );
    final timeFormat = DateFormat('HH:mm');

    final category = resolveCategory(
      expense.category,
      income: expense.isIncome,
    );
    final signedPrefix = expense.isIncome ? '+' : '-';
    final amountColor = expense.isIncome
        ? AppColors.success
        : AppColors.danger;
    final sourceLabel = accountLabel?.trim().isNotEmpty ?? false
        ? accountLabel!
        : expense.accountId == null
        ? 'No Account'
        : 'Archived Account';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        child: Semantics(
          button: true,
          label: 'Transaction: ${expense.note.isEmpty ? category.name : expense.note}, Amount: $signedPrefix${maskAmount(currencyFormat.format(expense.amount), masked: maskAmounts)}',
          hint: 'Double tap to edit',
          child: InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(26),
            child: Container(
              padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(category.icon, color: category.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        expense.note.isEmpty ? category.name : expense.note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${expense.category.toUpperCase()}  •  ${sourceLabel.toUpperCase()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSubtle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '$signedPrefix${maskAmount(currencyFormat.format(expense.amount), masked: maskAmounts)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: amountColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeFormat.format(expense.date.toLocal()),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz_rounded),
                      tooltip: 'Transaction options',
                      color: Colors.white,
                      iconColor: AppColors.textMuted,
                      onSelected: (value) {
                        if (value == 'delete') {
                          onDelete();
                          return;
                        }
                        onEdit?.call();
                      },
                      itemBuilder: (context) => <PopupMenuEntry<String>>[
                        if (onEdit != null)
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
