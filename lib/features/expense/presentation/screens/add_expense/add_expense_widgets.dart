import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../data/models/account_model.dart';
import '../../../data/models/expense_model.dart';
import '../../widgets/account_icons.dart';
import '../../widgets/expense_category.dart';

/// Extension on [TransactionType] to check if it represents income.
extension TransactionTypeX on TransactionType {
  bool get isIncome => this == TransactionType.income;
}

/// Small circular icon button used in the AddExpense top bar.
class AddExpenseTopButton extends StatelessWidget {
  const AddExpenseTopButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.color = AppColors.textMuted,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F7FB),
      shape: const CircleBorder(),
      child: Tooltip(
        message: tooltip,
        child: Semantics(
          button: true,
          label: tooltip,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 42,
              height: 42,
              child: Icon(icon, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

/// Expense / Income mode toggle tab.
class AddExpenseModeTab extends StatelessWidget {
  const AddExpenseModeTab({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textDark : AppColors.textMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// Read-only capsule showing a date/time field (tappable to open a picker).
class AddExpenseInfoCapsule extends StatelessWidget {
  const AddExpenseInfoCapsule({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F8FB),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 18, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tappable capsule showing the selected category or account.
class AddExpenseSelectionCapsule extends StatelessWidget {
  const AddExpenseSelectionCapsule({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final Color background;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 3-segment horizontal bar for selecting account, income category, and expense
/// category on the quick-add screen.
class AddExpenseQuickBar extends StatelessWidget {
  const AddExpenseQuickBar({
    super.key,
    required this.selectedAccount,
    required this.expenseCategory,
    required this.incomeCategory,
    required this.selectedType,
    required this.onTapAccount,
    required this.onTapExpenseCategory,
    required this.onTapIncomeCategory,
    this.accountEnabled = true,
  });

  final AccountModel? selectedAccount;
  final ExpenseCategory expenseCategory;
  final ExpenseCategory incomeCategory;
  final TransactionType selectedType;
  final VoidCallback onTapAccount;
  final VoidCallback onTapExpenseCategory;
  final VoidCallback onTapIncomeCategory;
  final bool accountEnabled;

  @override
  Widget build(BuildContext context) {
    final isIncome = selectedType == TransactionType.income;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EDF5), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: _QuickBarSegment(
                icon: selectedAccount == null
                    ? Icons.account_balance_wallet_outlined
                    : resolveAccountIcon(selectedAccount!.iconKey),
                iconColor: AppColors.primaryBlue,
                iconBg: AppColors.lightBlueBg,
                label: 'Account',
                value: selectedAccount?.name ?? 'No account',
                isActive: true,
                onTap: accountEnabled ? onTapAccount : null,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Container(width: 1, color: const Color(0xFFE8EDF5)),
            Expanded(
              child: _QuickBarSegment(
                icon: incomeCategory.icon,
                iconColor:
                    isIncome ? incomeCategory.color : AppColors.textMuted,
                iconBg: isIncome
                    ? incomeCategory.color.withValues(alpha: 0.15)
                    : const Color(0xFFEEF0F5),
                label: 'Income',
                value: incomeCategory.name,
                isActive: isIncome,
                onTap: onTapIncomeCategory,
              ),
            ),
            Container(width: 1, color: const Color(0xFFE8EDF5)),
            Expanded(
              child: _QuickBarSegment(
                icon: expenseCategory.icon,
                iconColor:
                    !isIncome ? expenseCategory.color : AppColors.textMuted,
                iconBg: !isIncome
                    ? expenseCategory.color.withValues(alpha: 0.15)
                    : const Color(0xFFEEF0F5),
                label: 'Expense',
                value: expenseCategory.name,
                isActive: !isIncome,
                onTap: onTapExpenseCategory,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickBarSegment extends StatelessWidget {
  const _QuickBarSegment({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.isActive,
    required this.onTap,
    this.borderRadius = BorderRadius.zero,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final bool isActive;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircleAvatar(
              radius: 22,
              backgroundColor: iconBg,
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isActive ? AppColors.textDark : AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single keypad button (digit, decimal point, or confirm).
class AddExpenseKeypadButton extends StatelessWidget {
  const AddExpenseKeypadButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? const Color(0xFF383838) : AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isPrimary ? Colors.white : AppColors.textDark,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
