import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_tokens.dart';

/// Card showing the 7-day date picker strip with navigation arrows and a
/// selected-day summary row.
class HomeDateStrip extends StatelessWidget {
  const HomeDateStrip({
    super.key,
    required this.visibleDates,
    required this.selectedDate,
    required this.selectedTotalText,
    required this.transactionCount,
    required this.onDateSelected,
    required this.onPrevious,
    required this.onNext,
  });

  final List<DateTime> visibleDates;
  final DateTime selectedDate;
  final String selectedTotalText;
  final int transactionCount;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final monthFormat = DateFormat('MMMM yyyy');
    final weekdayFormat = DateFormat('E');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  monthFormat.format(selectedDate),
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              HomeDateNavButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Previous week',
                onTap: onPrevious,
              ),
              const SizedBox(width: 8),
              HomeDateNavButton(
                icon: Icons.arrow_forward_rounded,
                tooltip: 'Next week',
                onTap: onNext,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: visibleDates
                .map((date) {
                  final isSelected = DateUtils.isSameDay(date, selectedDate);
                  return Expanded(
                    child: HomeDayPill(
                      label: weekdayFormat
                          .format(date)
                          .substring(0, 1)
                          .toUpperCase(),
                      day: date.day.toString().padLeft(2, '0'),
                      isSelected: isSelected,
                      onTap: () => onDateSelected(date),
                    ),
                  );
                })
                .toList(growable: false),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Selected day',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '$transactionCount txns',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      selectedTotalText,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small circular icon button used for previous / next navigation in
/// [HomeDateStrip].
class HomeDateNavButton extends StatelessWidget {
  const HomeDateNavButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: AppColors.surfaceMuted,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: kMinInteractiveDimension,
              height: kMinInteractiveDimension,
              child: Icon(icon, size: 18, color: AppColors.textMuted),
            ),
          ),
        ),
      ),
    );
  }
}

/// A single day pill inside [HomeDateStrip].
class HomeDayPill extends StatelessWidget {
  const HomeDayPill({
    super.key,
    required this.label,
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String day;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentLime : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Column(
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.accentLimeDark
                    : AppColors.textMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              day,
              style: TextStyle(
                color: isSelected
                    ? AppColors.accentLimeDark
                    : AppColors.textDark,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
