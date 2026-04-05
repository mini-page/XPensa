import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../data/models/account_model.dart';
import 'records_filter.dart';

/// Horizontal scrollable row of [ChoiceChip]s for filtering records.
class RecordsFilterChips extends StatelessWidget {
  const RecordsFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.labelForFilter,
  });

  final RecordsFilter selectedFilter;
  final ValueChanged<RecordsFilter> onFilterSelected;
  final String Function(RecordsFilter) labelForFilter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: RecordsFilter.values
            .map((filter) {
              final isSelected = selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(labelForFilter(filter)),
                  selected: isSelected,
                  onSelected: (_) => onFilterSelected(filter),
                  selectedColor: AppColors.primaryBlue,
                  backgroundColor: AppColors.lightBlueBg,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF48607E),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

/// Popup-menu button for filtering records by account.
class RecordsAccountDropdown extends StatelessWidget {
  const RecordsAccountDropdown({
    super.key,
    required this.accounts,
    required this.onAccountSelected,
    required this.allAccountsKey,
    required this.accountFilterLabel,
  });

  final List<AccountModel> accounts;
  final ValueChanged<String> onAccountSelected;
  final String allAccountsKey;
  final String accountFilterLabel;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: PopupMenuButton<String>(
        color: Colors.white,
        onSelected: onAccountSelected,
        itemBuilder: (context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: allAccountsKey,
            child: const Text('All accounts'),
          ),
          ...accounts.map((account) {
            return PopupMenuItem<String>(
              value: account.id,
              child: Text(account.name),
            );
          }),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                accountFilterLabel,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
