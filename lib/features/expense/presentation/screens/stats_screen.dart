import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../provider/expense_providers.dart';
import '../provider/preferences_providers.dart';
import '../widgets/amount_visibility.dart';
import '../widgets/expense_category.dart';

class StatsScreen extends ConsumerWidget {
  StatsScreen({super.key})
      : _monthLabel = DateFormat('MMMM\nyyyy'),
        _currencyFormat = NumberFormat.currency(
          locale: 'en_IN',
          symbol: '₹',
          decimalDigits: 0,
        );

  final DateFormat _monthLabel;
  final NumberFormat _currencyFormat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final privacyModeEnabled = ref.watch(privacyModeEnabledProvider);

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
                        'Spending\nStats',
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  height: 1,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF141E35),
                                ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    children: <Widget>[
                      Text(
                        _monthLabel.format(DateTime.now()).toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF0A6BE8),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${maskAmount(_currencyFormat.format(stats.monthTotal), masked: privacyModeEnabled)} spent',
                        style: const TextStyle(
                          color: Color(0xFF152039),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
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
                          Icons.pie_chart_outline_rounded,
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
                              'YOUR SPENDING REPORT',
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
                  const SizedBox(height: 26),
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
                          'TOTAL SPENT THIS MONTH',
                          style: TextStyle(
                            color: Color(0xFF8EA0BC),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          maskAmount(
                            _currencyFormat.format(stats.monthTotal),
                            masked: privacyModeEnabled,
                          ),
                          style: const TextStyle(
                            color: Color(0xFF13213B),
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Container(
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
                  const Text(
                    'BREAKDOWN',
                    style: TextStyle(
                      color: Color(0xFF0A6BE8),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (stats.categoryTotals.isEmpty)
                    const Text(
                      'No expenses yet. Add your first transaction to see the category mix.',
                      style: TextStyle(
                        color: Color(0xFF6E7F9C),
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    )
                  else
                    ...stats.categoryTotals.entries.take(5).map((entry) {
                      final category = resolveCategory(entry.key);
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
                                child: Icon(
                                  category.icon,
                                  color: category.color,
                                ),
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
                                maskAmount(
                                  _currencyFormat.format(entry.value),
                                  masked: privacyModeEnabled,
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF0A6BE8),
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
            ),
          ],
        ),
      ),
    );
  }
}
