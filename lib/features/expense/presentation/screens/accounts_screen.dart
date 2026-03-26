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
import '../widgets/recurring_tool_view.dart';
import '../widgets/split_bill_tool_view.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  bool _showTools = false;
  late final NumberFormat _currency;

  @override
  void initState() {
    super.initState();
    _currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _PillSwitch(
              leftLabel: 'Accounts',
              rightLabel: 'Tools',
              isRightSelected: _showTools,
              onChanged: (value) {
                setState(() {
                  _showTools = value;
                });
              },
            ),
            const SizedBox(height: 24),
            if (!_showTools)
              _AccountsTabView(currency: _currency)
            else
              const _ToolsTabView(),
          ],
        ),
      ),
    );
  }
}

class _AccountsTabView extends ConsumerWidget {
  const _AccountsTabView({required this.currency});
  final NumberFormat currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final accountState = ref.watch(accountListProvider);
    final summary = ref.watch(accountSummaryProvider);
    final privacyModeEnabled = ref.watch(privacyModeEnabledProvider);
    final accounts = accountState.value ?? const <AccountModel>[];

    return Column(
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
                'Net Worth',
                style: TextStyle(
                  color: Color(0xD9FFFFFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                maskAmount(
                  currency.format(summary.totalBalance),
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
                      label: 'Expense',
                      value: maskAmount(
                        currency.format(stats.monthTotal),
                        masked: privacyModeEnabled,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryChip(
                      label: 'Income',
                      value: maskAmount(
                        currency.format(stats.monthIncomeTotal),
                        masked: privacyModeEnabled,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Your Accounts',
                style: TextStyle(
                  color: Color(0xFF7D8EA9),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton.filled(
              onPressed: () => _openAccountEditor(context, ref),
              icon: const Icon(Icons.add_rounded),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF0A6BE8),
              ),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (accountState.isLoading) const LinearProgressIndicator(minHeight: 2),
        const SizedBox(height: 8),
        accounts.isEmpty
            ? _EmptyAccountsCard(
                onCreate: () => _openAccountEditor(context, ref),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _AccountCard(
                      account: account,
                      balanceText: maskAmount(
                        currency.format(account.balance.abs()),
                        masked: privacyModeEnabled,
                      ),
                      isNegative: account.balance < 0,
                      onTap: () => _openAccountEditor(
                        context,
                        ref,
                        account: account,
                      ),
                      onDelete: () => _deleteAccount(context, ref, account.id),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Future<void> _openAccountEditor(
    BuildContext context,
    WidgetRef ref, {
    AccountModel? account,
  }) async {
    final result = await showAccountEditorSheet(context, account: account);
    if (result == null) return;

    await ref.read(accountControllerProvider).saveAccount(
          id: result.id,
          name: result.name,
          iconKey: result.iconKey,
          balance: result.balance,
        );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          account == null ? '${result.name} created.' : '${result.name} updated.',
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
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Account removed.')));
  }
}

class _ToolsTabView extends StatelessWidget {
  const _ToolsTabView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SplitBillToolView(),
        SizedBox(height: 32),
        RecurringToolView(),
      ],
    );
  }
}

class _PillSwitch extends StatelessWidget {
  const _PillSwitch({
    required this.leftLabel,
    required this.rightLabel,
    required this.isRightSelected,
    required this.onChanged,
  });

  final String leftLabel;
  final String rightLabel;
  final bool isRightSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: <Widget>[
          _SwitchOption(
            label: leftLabel,
            isSelected: !isRightSelected,
            onTap: () => onChanged(false),
          ),
          _SwitchOption(
            label: rightLabel,
            isSelected: isRightSelected,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _SwitchOption extends StatelessWidget {
  const _SwitchOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0A6BE8) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF6C7D99),
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x1FFFFFFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
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
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F7FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  resolveAccountIcon(account.iconKey),
                  color: const Color(0xFF0A6BE8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      account.name,
                      style: const TextStyle(
                        color: Color(0xFF152039),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Balance: ${isNegative ? '-' : ''}$balanceText',
                      style: TextStyle(
                        color: isNegative ? const Color(0xFFFF446D) : const Color(0xFF0A6BE8),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded, color: Color(0xFF90A1BE)),
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                  } else {
                    onTap();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
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
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.wallet_outlined, size: 42, color: Color(0xFF0A6BE8)),
            const SizedBox(height: 12),
            const Text(
              'No accounts yet',
              style: TextStyle(
                color: Color(0xFF152039),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first account to track balances.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF90A1BE), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onCreate, child: const Text('Create Account')),
          ],
        ),
      ),
    );
  }
}
