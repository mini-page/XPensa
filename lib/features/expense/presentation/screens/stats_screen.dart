import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_tab_switcher.dart';
import '../provider/expense_providers.dart';
import '../provider/preferences_providers.dart';
import 'stats/stats_widgets.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedTab = 0;
  String _selectedRange = 'This Month';

  static const List<AppTabItem> _analyticsTabs = <AppTabItem>[
    AppTabItem(label: 'Flow', icon: Icons.waterfall_chart_rounded),
    AppTabItem(label: 'Spend', icon: Icons.pie_chart_outline_rounded),
    AppTabItem(label: 'Habit', icon: Icons.calendar_month_outlined),
  ];

  static const _rangeOptions = <String>[
    'This Week',
    'This Month',
    'Last Month',
    'Last 3 Months',
    'This Year',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _analyticsTabs.length, vsync: this);
    _tabController.addListener(() {
      final newIndex = _tabController.index;
      if (_selectedTab != newIndex) {
        setState(() => _selectedTab = newIndex);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(analyticsSnapshotProvider(_selectedRange));
    final privacyModeEnabled = ref.watch(privacyModeEnabledProvider);
    final currencyFormat = ref.watch(currencyFormatProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppPageHeader(
          eyebrow: 'Analytics',
          title: 'Financial Insights',
          trailing: Tooltip(
            message: 'Export coming soon',
            child: Opacity(
              opacity: 0.5,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  color: AppColors.surfaceAccent,
                ),
                child: const Icon(
                  Icons.download_rounded,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
          bottom: AppTabSwitcher(
            tabs: _analyticsTabs,
            selected: _selectedTab,
            onChanged: (index) {
              setState(() => _selectedTab = index);
              _tabController.animateTo(index);
            },
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: List.generate(_analyticsTabs.length, (tabIndex) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  120,
                ),
                child: AnalyticsGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Tab title
                      Text(
                        _analyticsTabs[tabIndex].label,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // Range picker
                      InkWell(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        onTap: _showRangePicker,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                _selectedRange,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.textSecondary,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Tab content
                      _buildTabContent(
                        tabIndex: tabIndex,
                        snapshot: snapshot,
                        currencyFormat: currencyFormat,
                        privacyModeEnabled: privacyModeEnabled,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent({
    required int tabIndex,
    required AnalyticsSnapshot snapshot,
    required NumberFormat currencyFormat,
    required bool privacyModeEnabled,
  }) {
    switch (tabIndex) {
      case 0:
        return FlowTabContent(
          snapshot: snapshot,
          currencyFormat: currencyFormat,
          privacyModeEnabled: privacyModeEnabled,
        );
      case 1:
        return SpendTabContent(
          snapshot: snapshot,
          currencyFormat: currencyFormat,
          privacyModeEnabled: privacyModeEnabled,
        );
      case 2:
        return HabitTabContent(
          snapshot: snapshot,
          currencyFormat: currencyFormat,
          privacyModeEnabled: privacyModeEnabled,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _showRangePicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.xxl),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _rangeOptions.map((option) {
              final active = option == _selectedRange;
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                tileColor:
                    active ? AppColors.surfaceAccent : Colors.transparent,
                title: Text(
                  option,
                  style: TextStyle(
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? AppColors.primaryBlue : AppColors.textDark,
                  ),
                ),
                trailing: active
                    ? const Icon(
                        Icons.check_circle,
                        color: AppColors.primaryBlue,
                      )
                    : null,
                onTap: () => Navigator.pop(context, option),
              );
            }).toList(growable: false),
          ),
        );
      },
    );
    if (selected != null) {
      setState(() => _selectedRange = selected);
    }
  }
}
