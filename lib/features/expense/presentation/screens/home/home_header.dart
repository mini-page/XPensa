import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../provider/account_providers.dart';
import '../../provider/expense_providers.dart';
import '../../widgets/amount_visibility.dart';

/// Blue hero header showing the app bar, net total, and monthly metrics.
class HomeHeader extends StatefulWidget {
  const HomeHeader({
    super.key,
    required this.stats,
    required this.accountSummary,
    required this.budgets,
    required this.currencyFormat,
    required this.privacyModeEnabled,
    required this.onMenuPressed,
    required this.onSearchPressed,
    required this.onTogglePrivacy,
  });

  final ExpenseStats stats;
  final AccountSummary accountSummary;
  final Map<String, double> budgets;
  final NumberFormat currencyFormat;
  final bool privacyModeEnabled;
  final VoidCallback onMenuPressed;
  final VoidCallback onSearchPressed;
  final VoidCallback onTogglePrivacy;

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  bool _netWorthRevealed = false;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final stats = widget.stats;
    final netTotal = formatSignedCurrencyForHome(
      stats.monthNetTotal,
      widget.currencyFormat,
      masked: widget.privacyModeEnabled,
    );
    final bool isDeficit = stats.monthNetTotal < 0;

    // H1: find the top budget category with the most activity
    double topBudgetLimit = 0;
    double topBudgetSpend = 0;
    String topBudgetCategory = '';
    for (final entry in widget.budgets.entries) {
      final spend = stats.categoryTotals[entry.key] ?? 0;
      if (entry.value > 0 && spend > topBudgetSpend) {
        topBudgetSpend = spend;
        topBudgetLimit = entry.value;
        topBudgetCategory = entry.key;
      }
    }
    final hasBudget = topBudgetLimit > 0;
    final budgetProgress = hasBudget
        ? (topBudgetSpend / topBudgetLimit).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 28),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: <Widget>[
          // Top App Bar
          Row(
            children: <Widget>[
              IconButton(
                tooltip: 'Open menu',
                onPressed: widget.onMenuPressed,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(AppAssets.logo, width: 32, height: 32),
              ),
              const SizedBox(width: 8),
              Text(
                'XPensa',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Search transactions',
                onPressed: widget.onSearchPressed,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    tooltip: 'Notifications',
                    onPressed: () {},
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 12,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryBlue, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Balance Section
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'ALL ACCOUNTS',
                style: TextStyle(
                  color: AppColors.overlayWhiteMedium,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                button: true,
                label: 'Toggle privacy mode',
                child: GestureDetector(
                  onTap: widget.onTogglePrivacy,
                  child: Tooltip(
                    message: 'Toggle privacy mode',
                    child: Icon(
                      widget.privacyModeEnabled
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.overlayWhiteMedium,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              netTotal,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 52,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // H2: Net worth chip (tap to reveal)
          GestureDetector(
            onTap: () => setState(() => _netWorthRevealed = !_netWorthRevealed),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withAlpha(60)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white70,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Net Worth: ${_netWorthRevealed ? widget.currencyFormat.format(widget.accountSummary.totalBalance) : '• • •'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _netWorthRevealed
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white54,
                    size: 13,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Deficit / Surplus Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isDeficit
                  ? Colors.redAccent.withAlpha(40)
                  : Colors.greenAccent.withAlpha(40),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDeficit
                    ? Colors.redAccent.withAlpha(80)
                    : Colors.greenAccent.withAlpha(80),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDeficit ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                  color: isDeficit
                      ? const Color(0xFFFFA2A2)
                      : const Color(0xFFA2FFC0),
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  isDeficit ? 'Deficit' : 'Surplus',
                  style: TextStyle(
                    color: isDeficit
                        ? const Color(0xFFFFA2A2)
                        : const Color(0xFFA2FFC0),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // H1: Budget progress bar for top active budget category
          if (hasBudget) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          topBudgetCategory.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Text(
                        '${widget.currencyFormat.format(topBudgetSpend)} / ${widget.currencyFormat.format(topBudgetLimit)}',
                        style: TextStyle(
                          color: budgetProgress >= 0.9
                              ? const Color(0xFFFFA2A2)
                              : Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: budgetProgress,
                      backgroundColor: Colors.white.withAlpha(40),
                      color: budgetProgress >= 0.9
                          ? Colors.redAccent
                          : const Color(0xFFA2FFC0),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Expense & Income Cards
          Row(
            children: <Widget>[
              Expanded(
                child: _MetricCard(
                  label: 'EXPENSE',
                  amount: maskAmount(
                    widget.currencyFormat.format(stats.monthTotal),
                    masked: widget.privacyModeEnabled,
                  ),
                  iconData: Icons.close_rounded,
                  iconColor: const Color(0xFFFF8585),
                  iconBgColor: const Color(0xFFFF8585).withAlpha(50),
                  progressColor: const Color(0xFFFF8585),
                  progressFactor: stats.monthIncomeTotal > 0
                      ? (stats.monthTotal / stats.monthIncomeTotal).clamp(0.0, 1.0)
                      : 0.65,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MetricCard(
                  label: 'INCOME',
                  amount: maskAmount(
                    widget.currencyFormat.format(stats.monthIncomeTotal),
                    masked: widget.privacyModeEnabled,
                  ),
                  iconData: Icons.north_east_rounded,
                  iconColor: const Color(0xFF85FFB8),
                  iconBgColor: const Color(0xFF85FFB8).withAlpha(50),
                  progressColor: const Color(0xFF85FFB8),
                  progressFactor: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.amount,
    required this.iconData,
    required this.iconColor,
    required this.iconBgColor,
    required this.progressColor,
    required this.progressFactor,
  });

  final String label;
  final String amount;
  final IconData iconData;
  final Color iconColor;
  final Color iconBgColor;
  final Color progressColor;
  final double progressFactor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.overlayWhiteMedium,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(40),
              borderRadius: BorderRadius.circular(3),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progressFactor,
              child: Container(
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Formats [amount] as an absolute currency string optionally masked.
String formatSignedCurrencyForHome(
  double amount,
  NumberFormat currencyFormat, {
  required bool masked,
}) {
  if (amount == 0) {
    return maskAmount(currencyFormat.format(0), masked: masked);
  }

  // Return the absolute amount for display, dropping the +/- sign.
  return maskAmount(
    currencyFormat.format(amount.abs()),
    masked: masked,
  );
}
