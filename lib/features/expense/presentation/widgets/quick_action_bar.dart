import 'package:flutter/material.dart';

class QuickActionItem {
  const QuickActionItem({
    required this.label,
    required this.icon,
    this.isHighlighted = false,
  });

  final String label;
  final IconData icon;
  final bool isHighlighted;
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
            color: Color(0x1209386D),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions
            .map((action) {
              final color = action.isHighlighted
                  ? const Color(0xFF0A6BE8)
                  : const Color(0xFF8EA0BF);
              return InkWell(
                onTap: () => onTap(action),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
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
                    ],
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}
