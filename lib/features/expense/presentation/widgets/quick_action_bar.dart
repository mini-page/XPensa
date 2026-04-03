import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

class QuickActionItem {
  const QuickActionItem({
    required this.label,
    required this.icon,
    this.isHighlighted = false,
    this.isEnabled = true,
    this.badgeLabel,
  });

  final String label;
  final IconData icon;
  final bool isHighlighted;
  final bool isEnabled;
  final String? badgeLabel;
}

class QuickActionBar extends StatelessWidget {
  const QuickActionBar({super.key, required this.actions, required this.onTap});

  final List<QuickActionItem> actions;
  final ValueChanged<QuickActionItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: actions.map((action) {
          final baseColor = action.isHighlighted
              ? AppColors.primaryBlue
              : AppColors.textMuted;
          final color =
              action.isEnabled ? baseColor : AppColors.disabledContent;
          return Semantics(
            button: action.isEnabled,
            enabled: action.isEnabled,
            label: action.badgeLabel == null
                ? action.label
                : '${action.label} ${action.badgeLabel}',
            child: InkWell(
              onTap: action.isEnabled ? () => onTap(action) : null,
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xs,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(action.icon, color: color, size: 23),
                    const SizedBox(height: 6),
                    Text(
                      action.label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    if (action.badgeLabel != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.xxs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAccent,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: Text(
                          action.badgeLabel!,
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}
