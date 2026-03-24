import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/account_model.dart';
import '../provider/account_providers.dart';
import '../provider/expense_providers.dart';
import '../provider/preferences_providers.dart';
import '../widgets/account_editor_sheet.dart';
import '../widgets/account_icons.dart';
import '../widgets/amount_visibility.dart';

class AccountsScreen extends ConsumerWidget {
  AccountsScreen({super.key})
      : _currency = NumberFormat.currency(
          locale: 'en_IN',
          symbol: '₹',
          decimalDigits: 0,
        );

  final NumberFormat _currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final accountState = ref.watch(accountListProvider);
    final summary = ref.watch(accountSummaryProvider);
    final privacyModeEnabled = ref.watch(privacyModeEnabledProvider);
    final accounts = accountState.valueOrNull ?? const <AccountModel>[];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFF0A6BE8), Color(0xFF5DA2FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x2209386D),
                    blurRadius: 26,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Accounts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Track balances across wallets, cards, and cash.',
                    style: TextStyle(
                      color: Color(0xD9FFFFFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    maskAmount(
                      _currency.format(summary.totalBalance),
                      masked: privacyModeEnabled,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _SummaryChip(
                          label: 'Expense So Far',
                          value: maskAmount(
                            _currency.format(stats.monthTotal),
                            masked: privacyModeEnabled,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryChip(
                          label: 'Active Accounts',
                          value: '${summary.accountCount}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Your Accounts',
              style: TextStyle(
                color: Color(0xFF7D8EA9),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            if (accountState.isLoading)
              const LinearProgressIndicator(minHeight: 4),
            const SizedBox(height: 12),
            Expanded(
              child: accounts.isEmpty
                  ? _EmptyAccountsCard(
                      onCreate: () => _openAccountEditor(context, ref),
                    )
                  : ListView(
                      children: accounts.map((account) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _AccountCard(
                            account: account,
                            balanceText: maskAmount(
                              _currency.format(account.balance.abs()),
                              masked: privacyModeEnabled,
                            ),
                            isNegative: account.balance < 0,
                            onTap: () => _openAccountEditor(
                              context,
                              ref,
                              account: account,
                            ),
                            onDelete: () =>
                                _deleteAccount(context, ref, account.id),
                          ),
                        );
                      }).toList(growable: false),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAccountEditor(
    BuildContext context,
    WidgetRef ref, {
    AccountModel? account,
  }) async {
    final result = await showAccountEditorSheet(context, account: account);
    if (result == null) {
      return;
    }

    await ref.read(accountControllerProvider).saveAccount(
          id: result.id,
          name: result.name,
          iconKey: result.iconKey,
          balance: result.balance,
        );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          account == null
              ? '${result.name} created.'
              : '${result.name} updated.',
        ),
      ),
    );
  }

  Future<void> _deleteAccount(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    await ref.read(accountControllerProvider).deleteAccount(id);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account removed.')),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0x1FFFFFFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.balanceText,
    required this.isNegative,
    required this.onTap,
    required this.onDelete,
  });

  final AccountModel account;
  final String balanceText;
  final bool isNegative;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: <Widget>[
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF5FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  resolveAccountIcon(account.iconKey),
                  color: const Color(0xFF0A6BE8),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      account.name,
                      style: const TextStyle(
                        color: Color(0xFF152039),
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Balance: ${isNegative ? '-' : ''}$balanceText',
                      style: TextStyle(
                        color: isNegative
                            ? const Color(0xFFFF446D)
                            : const Color(0xFF0A6BE8),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: Color(0xFF90A1BE),
                ),
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                  } else {
                    onTap();
                  }
                },
                itemBuilder: (context) => const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyAccountsCard extends StatelessWidget {
  const _EmptyAccountsCard({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x1209386D),
              blurRadius: 22,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.wallet_outlined,
              size: 42,
              color: Color(0xFF0A6BE8),
            ),
            const SizedBox(height: 12),
            const Text(
              'No accounts yet',
              style: TextStyle(
                color: Color(0xFF152039),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first account to track balances and organize where money sits.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF90A1BE),
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onCreate,
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
