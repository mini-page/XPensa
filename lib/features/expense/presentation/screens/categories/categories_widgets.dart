import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Two-option pill toggle for switching between expense/income categories.
class CategoriesPillSwitch extends StatelessWidget {
  const CategoriesPillSwitch({
    super.key,
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
          _CategoriesSwitchOption(
            label: leftLabel,
            isSelected: !isRightSelected,
            onTap: () => onChanged(false),
          ),
          _CategoriesSwitchOption(
            label: rightLabel,
            isSelected: isRightSelected,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _CategoriesSwitchOption extends StatelessWidget {
  const _CategoriesSwitchOption({
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

/// A single category grid cell showing spend amount and optional budget detail.
class CategoryGridCard extends StatelessWidget {
  const CategoryGridCard({
    super.key,
    required this.title,
    required this.icon,
    required this.tone,
    required this.amount,
    required this.actionLabel,
    required this.onTap,
    this.detail,
  });

  final String title;
  final IconData icon;
  final Color tone;
  final String amount;
  final String? detail;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tone.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(22),
      child: Semantics(
        button: true,
        label: 'Category details for $title',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tone.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF16233C),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        amount,
                        style: const TextStyle(
                          color: Color(0xFF0A6BE8),
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (detail != null) ...<Widget>[
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          detail!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF6C7D99),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                top: 6,
                right: 2,
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: tone.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.white,
                  onSelected: (_) => onTap(),
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'primary',
                      child: Text(actionLabel),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Add category" placeholder cell in the grid.
class AddCategoryCard extends StatelessWidget {
  const AddCategoryCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFD8DFE9),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: const Center(
          child: Icon(Icons.add_rounded, color: AppColors.textMuted, size: 40),
        ),
      ),
    );
  }
}

/// Data object for a single category grid cell.
class CategoryGridData {
  const CategoryGridData({
    required this.title,
    required this.icon,
    required this.tone,
    required this.amount,
    required this.onTap,
    this.budget = 0,
  });

  final String title;
  final IconData icon;
  final Color tone;
  final double amount;
  final double budget;
  final VoidCallback onTap;
}
