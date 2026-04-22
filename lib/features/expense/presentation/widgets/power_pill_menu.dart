import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_toggle_switch.dart';

/// An expandable power FAB.
///
/// Shows a circular `+` button. When tapped the button rotates 135° (making it
/// look like ×) and action pills animate up above it:
///   Quick Add · Voice
///
/// Use [PowerFabState] via a [GlobalKey] to imperatively [close] the menu
/// (e.g. from a barrier tap in the parent).
class PowerFab extends StatefulWidget {
  const PowerFab({
    super.key,
    required this.onQuickAdd,
    required this.onScanner,
    required this.onPayDirectly,
    required this.onVoice,
    required this.onSms,
    required this.onToggle,
    required this.smsParsingEnabled,
    required this.onSmsToggle,
  });

  final VoidCallback onQuickAdd;
  final VoidCallback onScanner;

  /// Opens the UPI QR scanner for the "Pay Directly" flow.
  final VoidCallback onPayDirectly;

  /// Opens the voice entry bottom sheet.
  final VoidCallback onVoice;

  /// Opens the SMS settings sheet.
  final VoidCallback onSms;

  /// Called whenever the open/closed state changes. `true` = opened.
  final ValueChanged<bool> onToggle;

  /// Current SMS parsing enabled state (drives the inline toggle).
  final bool smsParsingEnabled;

  /// Called when the user taps the inline SMS toggle switch.
  final ValueChanged<bool> onSmsToggle;

  @override
  PowerFabState createState() => PowerFabState();
}

class PowerFabState extends State<PowerFab>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Toggle open / closed.
  void toggle() {
    HapticFeedback.lightImpact();
    if (!_open) {
      setState(() => _open = true);
      widget.onToggle(true);
      _ctrl.forward();
    } else {
      close();
    }
  }

  /// Programmatically close the menu (e.g. when a barrier is tapped).
  void close() {
    widget.onToggle(false);
    _ctrl.reverse().then((_) {
      if (mounted) setState(() => _open = false);
    });
  }

  void _closeAndRun(VoidCallback action) {
    widget.onToggle(false);
    _ctrl.reverse().then((_) {
      if (mounted) {
        setState(() => _open = false);
        action();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        // ── Action pills (shown only when open) ──────────────────────────
        if (_open) ...<Widget>[
          _AnimatedPill(
            animation: _ctrl,
            staggerStart: 0.1,
            icon: Icons.mic_none_rounded,
            label: 'Voice',
            infoText: 'Speak an expense aloud — parsed and saved for you',
            onTap: () => _closeAndRun(widget.onVoice),
          ),
          const SizedBox(height: 8),
          _AnimatedPill(
            animation: _ctrl,
            staggerStart: 0.0,
            icon: Icons.add_rounded,
            label: 'Quick Add',
            infoText: 'Jump straight into adding a new expense entry',
            highlighted: true,
            onTap: () => _closeAndRun(widget.onQuickAdd),
          ),
          const SizedBox(height: 12),
        ],

        // ── FAB button ────────────────────────────────────────────────────
        GestureDetector(
          onTap: toggle,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, child) => Transform.rotate(
              angle: _ctrl.value * math.pi * 0.75, // 0 → 135°
              child: child,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _open ? const Color(0xFF1A2340) : AppColors.primaryBlue,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helpers
// ─────────────────────────────────────────────────────────────────────────────

const _kPillColor = Color(0xFF1A2340); // dark navy

// ── Pill ─────────────────────────────────────────────────────────────────────

class _AnimatedPill extends StatefulWidget {
  const _AnimatedPill({
    required this.animation,
    required this.staggerStart,
    required this.icon,
    required this.label,
    required this.infoText,
    this.highlighted = false,
    this.onTap,
    this.trailingToggleValue,
    this.onTrailingToggle,
  });

  final Animation<double> animation;

  /// Fraction [0–1] of the parent animation when this pill begins appearing.
  final double staggerStart;
  final IconData icon;
  final String label;

  /// Short description shown in the info bar when the ⓘ icon is tapped.
  final String infoText;

  final bool highlighted;
  final VoidCallback? onTap;

  /// When non-null, a compact toggle switch is shown at the trailing edge
  /// of the pill. Tapping the toggle does NOT trigger [onTap].
  final bool? trailingToggleValue;
  final ValueChanged<bool>? onTrailingToggle;

  @override
  State<_AnimatedPill> createState() => _AnimatedPillState();
}

class _AnimatedPillState extends State<_AnimatedPill> {
  bool _showInfo = false;
  Timer? _infoTimer;

  void _toggleInfo() {
    HapticFeedback.selectionClick();
    _infoTimer?.cancel();
    setState(() => _showInfo = !_showInfo);
    if (_showInfo) {
      _infoTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showInfo = false);
      });
    }
  }

  @override
  void dispose() {
    _infoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(
      parent: widget.animation,
      curve: Interval(
        widget.staggerStart,
        (widget.staggerStart + 0.6).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: curve,
      builder: (_, child) => Opacity(
        opacity: curve.value,
        child: Transform.translate(
          offset: Offset(24 * (1 - curve.value), 0),
          child: child,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          // ── Pill row ──────────────────────────────────────────────────
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap != null
                  ? () {
                      HapticFeedback.selectionClick();
                      widget.onTap!();
                    }
                  : null,
              borderRadius: BorderRadius.circular(28),
              child: Container(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 12,
                  top: 14,
                  bottom: 14,
                ),
                decoration: BoxDecoration(
                  color: widget.highlighted
                      ? AppColors.primaryBlue
                      : _kPillColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x28000000),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(widget.icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (widget.trailingToggleValue != null) ...<Widget>[
                      const SizedBox(width: 10),
                      Container(
                        width: 1,
                        height: 20,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                      const SizedBox(width: 8),
                      // GestureDetector absorbs taps so they don't bubble
                      // to InkWell
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          widget.onTrailingToggle
                              ?.call(!widget.trailingToggleValue!);
                        },
                        child: AppToggleSwitch(
                          value: widget.trailingToggleValue!,
                          onChanged: widget.onTrailingToggle ?? (_) {},
                          small: true,
                        ),
                      ),
                    ],
                    // ── Info icon ────────────────────────────────────────
                    const SizedBox(width: 10),
                    Container(
                      width: 1,
                      height: 20,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    const SizedBox(width: 2),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _toggleInfo,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: Icon(
                          _showInfo
                              ? Icons.info_rounded
                              : Icons.info_outline_rounded,
                          color: _showInfo
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.55),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Info bar ────────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SizeTransition(
                sizeFactor: anim,
                axisAlignment: -1,
                child: child,
              ),
            ),
            child: _showInfo
                ? _InfoBar(
                    key: const ValueKey('info'),
                    text: widget.infoText,
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ],
      ),
    );
  }
}

// ── Info bar ──────────────────────────────────────────────────────────────────

class _InfoBar extends StatelessWidget {
  const _InfoBar({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1829),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.lightbulb_outline_rounded,
              color: Colors.white.withValues(alpha: 0.55),
              size: 13,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
