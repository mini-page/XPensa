import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import 'stats/stats_widgets.dart';
import '../provider/expense_providers.dart';
import '../provider/preferences_providers.dart';
import '../widgets/amount_visibility.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  static final DateFormat _monthLabel = DateFormat('MMMM\nyyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final privacyModeEnabled = ref.watch(privacyModeEnabledProvider);

    final currencyFormat = ref.watch(currencyFormatProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'ANALYTICS',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          letterSpacing: 1.8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Money\nFlow',
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  height: 1,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  constraints: const BoxConstraints(maxWidth: 160),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 22,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        _monthLabel.format(DateTime.now()).toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${formatSignedAmount(stats.monthNetTotal, currencyFormat, masked: privacyModeEnabled)} net',
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[
                    AppColors.primaryBlue,
                    AppColors.primaryBlueLight
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(34),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: AppColors.darkBlueShadow,
                    blurRadius: 28,
                    offset: Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0x26FFFFFF),
                        child: Icon(
                          Icons.insights_rounded,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Monthly Summary',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'EXPENSE, INCOME, AND NET',
                              style: TextStyle(
                                color: Color(0xCCFFFFFF),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: StatsMetricTile(
                          label: 'Spent',
                          value: maskAmount(
                            currencyFormat.format(stats.monthTotal),
                            masked: privacyModeEnabled,
                          ),
                          accent: AppColors.danger,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsMetricTile(
                          label: 'Income',
                          value: maskAmount(
                            currencyFormat.format(stats.monthIncomeTotal),
                            masked: privacyModeEnabled,
                          ),
                          accent: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'NET THIS MONTH',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            formatSignedAmount(
                              stats.monthNetTotal,
                              currencyFormat,
                              masked: privacyModeEnabled,
                            ),
                            style: TextStyle(
                              color: stats.monthNetTotal >= 0
                                  ? AppColors.success
                                  : AppColors.danger,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            StatsBreakdownCard(
              title: 'Expense Breakdown',
              emptyMessage:
                  'No expenses yet. Add a transaction to see category mix.',
              entries: stats.categoryTotals.entries.toList(growable: false),
              privacyModeEnabled: privacyModeEnabled,
              currencyFormat: currencyFormat,
              income: false,
            ),
            const SizedBox(height: 16),
            StatsBreakdownCard(
              title: 'Income Breakdown',
              emptyMessage:
                  'No income yet. Add income to understand where money is coming from.',
              entries: stats.incomeCategoryTotals.entries.toList(
                growable: false,
              ),
              privacyModeEnabled: privacyModeEnabled,
              currencyFormat: currencyFormat,
              income: true,
            ),
          ],
        ),
      ),
    );
  }
}

