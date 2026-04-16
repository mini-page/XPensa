import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Describes a single tab entry: the text shown when active and the icon
/// shown when inactive.
class AppTabItem {
  const AppTabItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// A pill-shaped tab switcher used consistently across all main screens.
///
/// Each tab shows its [AppTabItem.icon] when inactive and animates to its
/// [AppTabItem.label] text when selected (fade + scale).
///
/// Tabs are laid out in a horizontally scrollable row so additional tabs can
/// be added in the future without any layout changes at the call site.
class AppTabSwitcher extends StatelessWidget {
  const AppTabSwitcher({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onChanged,
  });

  final List<AppTabItem> tabs;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(22),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(tabs.length, (index) {
            return _AppTabCell(
              label: tabs[index].label,
              icon: tabs[index].icon,
              isSelected: selected == index,
              onTap: () => onChanged(index),
            );
          }),
        ),
      ),
    );
  }
}

/// Internal tab cell — shows label text when selected, icon when not.
class _AppTabCell extends StatelessWidget {
  const _AppTabCell({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Center(
            child: SizedBox(
              height: 18,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: isSelected
                    ? Text(
                        label,
                        key: ValueKey<String>('text_$label'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      )
                    : Icon(
                        icon,
                        key: ValueKey<IconData>(icon),
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
