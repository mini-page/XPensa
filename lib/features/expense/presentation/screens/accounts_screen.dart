import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/context_extensions.dart';
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
              child: _PillSwitch(
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
            _SliverAccountsTabView(currency: currency)
          else
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 120),
                child: _ToolsTabView(),
              ),
            ),
        ],
      ),
    );
  }
}

class _SliverAccountsTabView extends ConsumerWidget {
  const _SliverAccountsTabView({required this.currency});
  final NumberFormat currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final accountState = ref.watch(accountListProvider);
    final summary = ref.watch(accountSummaryProvider);
    final privacyModeEnabled = ref.watch(privacyModeEnabledProvider);
    final accounts = accountState.value ?? const <AccountModel>[];

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[AppColors.primaryBlue, AppColors.primaryBlueLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: AppColors.darkBlueShadow,
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
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Your Accounts',
                      style: TextStyle(
                        color: AppColors.textSubtle,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () => _openAccountEditor(context, ref),
                    icon: const Icon(Icons.add_rounded),
                    tooltip: 'Add new account',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                    ),
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                ],
              ),
            ),
          ),
          if (accountState.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            ),
          if (accounts.isEmpty)
            SliverToBoxAdapter(
              child: _EmptyAccountsCard(
                onCreate: () => _openAccountEditor(context, ref),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
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
                childCount: accounts.length,
              ),
            ),
        ],
      ),
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

    context.showSnackBar(
      account == null ? '${result.name} created.' : '${result.name} updated.',
    );
  }

  Future<void> _deleteAccount(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    await ref.read(accountControllerProvider).deleteAccount(id);
    if (!context.mounted) return;
    context.showSnackBar('Account removed.');
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
        color: AppColors.backgroundLight,
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
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textMuted,
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
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
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
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  resolveAccountIcon(account.iconKey),
                  color: AppColors.primaryBlue,
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
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Balance: ${isNegative ? '-' : ''}$balanceText',
                        style: TextStyle(
                          color: isNegative ? AppColors.danger : AppColors.primaryBlue,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textMuted),
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
            const Icon(Icons.wallet_outlined, size: 42, color: AppColors.primaryBlue),
            const SizedBox(height: 12),
            const Text(
              'No accounts yet',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first account to track balances.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onCreate,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
