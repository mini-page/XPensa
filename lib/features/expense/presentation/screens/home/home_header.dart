import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../data/models/expense_model.dart';
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
  });

  final ExpenseStats stats;
  final NumberFormat currencyFormat;
  final bool privacyModeEnabled;
  final VoidCallback onMenuPressed;
  final VoidCallback onSearchPressed;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final netTotal = formatSignedCurrencyForHome(
      stats.monthNetTotal,
      currencyFormat,
      masked: privacyModeEnabled,
    );
    return Container(
      padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 28),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(44)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: onMenuPressed,
                icon: const Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(AppAssets.logo, width: 28, height: 28),
              ),
              const SizedBox(width: 10),
              Text(
                'XPensa',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onSearchPressed,
                icon: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'All Accounts - $netTotal',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              HomeMetricColumn(
                label: 'EXPENSE SO FAR',
                value: maskAmount(
                  currencyFormat.format(stats.monthTotal),
                  masked: privacyModeEnabled,
                ),
              ),
              HomeMetricColumn(
                label: 'INCOME SO FAR',
                value: maskAmount(
                  currencyFormat.format(stats.monthIncomeTotal),
                  masked: privacyModeEnabled,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A labelled value column used inside [HomeHeader].
class HomeMetricColumn extends StatelessWidget {
  const HomeMetricColumn({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: AppColors.overlayWhiteMedium,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
        ),
      ],
    );
  }
}

/// Formats [amount] as a signed, optionally masked currency string.
String formatSignedCurrencyForHome(
  double amount,
  NumberFormat currencyFormat, {
  required bool masked,
}) {
  if (amount == 0) {
    return maskAmount(currencyFormat.format(0), masked: masked);
  }

  final absolute = maskAmount(
    currencyFormat.format(amount.abs()),
    masked: masked,
  );
  final prefix = amount > 0 ? '+' : '-';
  return '$prefix$absolute';
}
