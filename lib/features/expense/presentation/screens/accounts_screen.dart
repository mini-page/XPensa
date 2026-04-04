import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import 'accounts/accounts_widgets.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../data/models/account_model.dart';
import '../provider/account_providers.dart';
import '../provider/expense_providers.dart';
import '../provider/preferences_providers.dart';
import '../widgets/account_editor_sheet.dart';
import '../widgets/account_icons.dart';
import '../widgets/amount_visibility.dart';
import '../widgets/recurring_tool_view.dart';
import '../widgets/split_bill_tool_view.dart';
import '../widgets/ui_feedback.dart';

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
            _SliverAccountsTabView(currency: currency)
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
                  colors: <Color>[
                    AppColors.primaryBlue,
                    AppColors.primaryBlueLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadii.hero),
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
                      color: AppColors.overlayWhiteBold,
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
                        child: AccountsSummaryChip(
                          label: 'Expense',
                          value: maskAmount(
                            currency.format(stats.monthTotal),
                            masked: privacyModeEnabled,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AccountsSummaryChip(
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
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
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
              child: EmptyAccountsCard(
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
                    child: AccountCard(
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
                      onDelete: () => _deleteAccount(context, ref, account),
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
    AccountModel account,
  ) async {
    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Delete account?',
      message:
          'Remove ${account.name}? Transactions stay in history, but the account itself will be deleted.',
      confirmLabel: 'Delete account',
    );
    if (!confirmed || !context.mounted) return;

    await ref.read(accountControllerProvider).deleteAccount(account.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${account.name} removed.')));
  }
}
