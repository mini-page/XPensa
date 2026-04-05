import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'accounts/accounts_widgets.dart';
import '../provider/preferences_providers.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  bool _showTools = false;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final symbol = ref.watch(currencySymbolProvider);

    final currency = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 0,
    );

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
              child: AccountsPillSwitch(
                leftLabel: 'Accounts',
                rightLabel: 'Tools',
                isRightSelected: _showTools,
                onChanged: (value) {
                  setState(() {
                    _showTools = value;
                  });
                },
              ),
            ),
          ),
          if (!_showTools)
            SliverAccountsTabView(currency: currency)
          else
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 120),
                child: AccountsToolsTabView(),
              ),
            ),
        ],
      ),
    );
  }
}
