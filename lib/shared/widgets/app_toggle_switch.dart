import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A compact, pill-shaped boolean toggle used consistently across all screens.
///
/// Visual spec (matches the category-screen toggle):
///   • Track: 42 × 24 dp, fully rounded  (small: 36 × 20 dp)
///   • Thumb: 18 × 18 dp white circle with a subtle shadow  (small: 16 × 16 dp)
///   • On  → track fills with [activeColor]
///   • Off → track fills with [AppColors.backgroundLight]
///
/// Set [small] to `true` for contexts where the toggle must stay within a
/// 20 dp row height (e.g. the Power FAB SMS pill).
class AppToggleSwitch extends StatelessWidget {
  const AppToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = AppColors.primaryBlue,
    this.small = false,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  /// Track colour when the toggle is on. Defaults to [AppColors.primaryBlue].
  final Color activeColor;

  /// When `true`, renders a smaller variant (36×20 dp track, 16 dp thumb) so
  /// it fits within a 20 dp row without expanding the parent pill's height.
  final bool small;

  @override
  Widget build(BuildContext context) {
    final double trackW = small ? 36 : 42;
    final double trackH = small ? 20 : 24;
    final double thumbSz = small ? 16 : 18;
    final double pad = small ? 2 : 3;

    return Semantics(
      button: true,
      toggled: value,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: trackW,
          height: trackH,
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            color: value ? activeColor : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 160),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: thumbSz,
              height: thumbSz,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
