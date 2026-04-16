import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// An expandable power FAB.
///
/// Shows a circular `+` button. When tapped the button rotates 135° (making it
/// look like ×) and four action pills animate up above it:
///   Quick Add · {symbol} Scanner · {symbol} Voice (Soon) · SMS (Soon)
///
/// Use [PowerFabState] via a [GlobalKey] to imperatively [close] the menu
/// (e.g. from a barrier tap in the parent).
class PowerFab extends StatefulWidget {
  const PowerFab({
    super.key,
    required this.onQuickAdd,
    required this.onScanner,
    required this.onToggle,
  });

  final VoidCallback onQuickAdd;
  final VoidCallback onScanner;

  /// Called whenever the open/closed state changes. `true` = opened.
  final ValueChanged<bool> onToggle;

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
            staggerStart: 0.3,
            icon: Icons.sms_outlined,
            label: 'SMS',
            badgeLabel: 'Soon',
          ),
          const SizedBox(height: 8),
          _AnimatedPill(
            animation: _ctrl,
            staggerStart: 0.2,
            icon: Icons.mic_none_rounded,
            label: 'Voice',
            badgeLabel: 'Soon',
          ),
          const SizedBox(height: 8),
          _AnimatedPill(
            animation: _ctrl,
            staggerStart: 0.1,
            icon: Icons.qr_code_scanner_rounded,
            label: 'Scanner',
            onTap: () => _closeAndRun(widget.onScanner),
          ),
          const SizedBox(height: 8),
          _AnimatedPill(
            animation: _ctrl,
            staggerStart: 0.0,
            icon: Icons.add_rounded,
            label: 'Quick Add',
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
                color: _open
                    ? const Color(0xFF1A2340)
                    : AppColors.primaryBlue,
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

class _AnimatedPill extends StatelessWidget {
  const _AnimatedPill({
    required this.animation,
    required this.staggerStart,
    required this.icon,
    required this.label,
    this.badgeLabel,
    this.highlighted = false,
    this.onTap,
  });

  final Animation<double> animation;

  /// Fraction [0–1] of the parent animation when this pill begins appearing.
  final double staggerStart;
  final IconData icon;
  final String label;
  final String? badgeLabel;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(
      parent: animation,
      curve: Interval(
        staggerStart,
        (staggerStart + 0.6).clamp(0.0, 1.0),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap != null
              ? () {
                  HapticFeedback.selectionClick();
                  onTap!();
                }
              : null,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: highlighted ? AppColors.primaryBlue : _kPillColor,
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
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 0.2,
                  ),
                ),
                if (badgeLabel != null) ...<Widget>[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeLabel!,
                      style: const TextStyle(
                        color: Colors.white,
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
      ),
    );
  }
}
