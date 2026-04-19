import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// An informational card shown when there are no transactions to display.
class HomeEmptyCard extends StatelessWidget {
  const HomeEmptyCard({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// A tappable chip showing a pre-set amount for the quick-add flow.
class HomeAmountChip extends StatelessWidget {
  const HomeAmountChip({
    super.key,
    required this.label,
    required this.onTap,
    this.onLongPress,
  });

  final String label;
  final VoidCallback onTap;

  /// Called when the chip is long-pressed. When non-null a subtle delete hint
  /// is implied to the user via the chip appearance.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Quick add $label',
      child: GestureDetector(
        onLongPress: onLongPress,
        child: ActionChip(
          onPressed: onTap,
          label: Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          backgroundColor: AppColors.surfaceAccent,
          side: const BorderSide(color: AppColors.primaryBlueLight, width: 1),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          elevation: 0,
        ),
      ),
    );
  }
}

/// A chip showing a `+` icon to let users add their own quick-add amount.
class HomeAddAmountChip extends StatelessWidget {
  const HomeAddAmountChip({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add custom quick amount',
      child: ActionChip(
        onPressed: onTap,
        avatar: const Icon(
          Icons.add_rounded,
          size: 16,
          color: AppColors.textSecondary,
        ),
        label: const Text(
          'Add',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        backgroundColor: AppColors.surfaceLight,
        side: const BorderSide(color: Color(0xFFD1DAEA), width: 1),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: 0,
      ),
    );
  }
}
