import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../provider/expense_providers.dart';
import '../provider/preferences_providers.dart';
import '../widgets/amount_visibility.dart';
import '../widgets/expense_category.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  static final DateFormat _monthLabel = DateFormat('MMMM\nyyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final privacyModeEnabled = ref.watch(privacyModeEnabledProvider);
    final locale = ref.watch(localeProvider);
    final symbol = ref.watch(currencySymbolProvider);

    final currencyFormat = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 0,
    );

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
                          color: Color(0xFF0A6BE8),
                          letterSpacing: 1.8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Money\nFlow',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              height: 1,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF141E35),
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
                        color: Color(0x1209386D),
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
                          color: Color(0xFF0A6BE8),
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
                            color: Color(0xFF152039),
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
                  colors: <Color>[Color(0xFF0A6BE8), Color(0xFF5DA2FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(34),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x2209386D),
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
                        child: _MetricTile(
                          label: 'Spent',
                          value: maskAmount(
                            currencyFormat.format(stats.monthTotal),
                            masked: privacyModeEnabled,
                          ),
                          accent: const Color(0xFFFF5B6C),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricTile(
                          label: 'Income',
                          value: maskAmount(
                            currencyFormat.format(stats.monthIncomeTotal),
                            masked: privacyModeEnabled,
                          ),
                          accent: const Color(0xFF1DAA63),
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
                            color: Color(0xFF8EA0BC),
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
                                  ? const Color(0xFF1DAA63)
                                  : const Color(0xFFFF446D),
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
            _BreakdownCard(
              title: 'Expense Breakdown',
              emptyMessage:
                  'No expenses yet. Add a transaction to see category mix.',
              entries: stats.categoryTotals.entries.toList(growable: false),
              privacyModeEnabled: privacyModeEnabled,
              currencyFormat: currencyFormat,
              income: false,
            ),
            const SizedBox(height: 16),
            _BreakdownCard(
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF152039),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({
    required this.title,
    required this.emptyMessage,
    required this.entries,
    required this.privacyModeEnabled,
    required this.currencyFormat,
    required this.income,
  });

  final String title;
  final String emptyMessage;
  final List<MapEntry<String, double>> entries;
  final bool privacyModeEnabled;
  final NumberFormat currencyFormat;
  final bool income;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1209386D),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF0A6BE8),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            Text(
              emptyMessage,
              style: const TextStyle(
                color: Color(0xFF6E7F9C),
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            )
          else
            ...entries.take(5).map((entry) {
              final category = resolveCategory(entry.key, income: income);
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F8FE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: category.color.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(category.icon, color: category.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            color: Color(0xFF152039),
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '${income ? '+' : ''}${maskAmount(currencyFormat.format(entry.value), masked: privacyModeEnabled)}',
                        style: TextStyle(
                          color: income
                              ? const Color(0xFF1DAA63)
                              : const Color(0xFF0A6BE8),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
