import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../provider/expense_providers.dart';
import '../../widgets/amount_visibility.dart';

/// Blue hero header showing the app bar, net total, and monthly metrics.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.stats,
    required this.currencyFormat,
    required this.privacyModeEnabled,
    required this.onMenuPressed,
    required this.onSearchPressed,
    required this.onTogglePrivacy,
  });

  final ExpenseStats stats;
  final NumberFormat currencyFormat;
  final bool privacyModeEnabled;
  final VoidCallback onMenuPressed;
  final VoidCallback onSearchPressed;
  final VoidCallback onTogglePrivacy;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final netTotal = formatSignedCurrencyForHome(
      stats.monthNetTotal,
      currencyFormat,
      masked: privacyModeEnabled,
    );
    final bool isDeficit = stats.monthNetTotal < 0;

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
                onPressed: onMenuPressed,
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
                onPressed: onSearchPressed,
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
                  onTap: onTogglePrivacy,
                  child: Tooltip(
                    message: 'Toggle privacy mode',
                    child: Icon(
                      privacyModeEnabled ? Icons.visibility_off : Icons.visibility,
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
          const SizedBox(height: 12),
          
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
                  color: isDeficit ? const Color(0xFFFFA2A2) : const Color(0xFFA2FFC0),
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  isDeficit ? 'Deficit' : 'Surplus',
                  style: TextStyle(
                    color: isDeficit ? const Color(0xFFFFA2A2) : const Color(0xFFA2FFC0),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Expense & Income Cards
          Row(
            children: <Widget>[
              Expanded(
                child: _MetricCard(
                  label: 'EXPENSE',
                  amount: maskAmount(
                    currencyFormat.format(stats.monthTotal),
                    masked: privacyModeEnabled,
                  ),
                  iconData: Icons.close_rounded,
                  iconColor: const Color(0xFFFF8585),
                  iconBgColor: const Color(0xFFFF8585).withAlpha(50),
                  progressColor: const Color(0xFFFF8585),
                  progressFactor: 0.65,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MetricCard(
                  label: 'INCOME',
                  amount: maskAmount(
                    currencyFormat.format(stats.monthIncomeTotal),
                    masked: privacyModeEnabled,
                  ),
                  iconData: Icons.north_east_rounded,
                  iconColor: const Color(0xFF85FFB8),
                  iconBgColor: const Color(0xFF85FFB8).withAlpha(50),
                  progressColor: const Color(0xFF85FFB8),
                  progressFactor: 0.45,
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
