import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../routes/app_routes.dart';
import '../../provider/account_providers.dart';
import '../../provider/expense_providers.dart';
import '../../widgets/amount_visibility.dart';

// ---------------------------------------------------------------------------
// HomeTopBar — sticky slim app-bar (menu · logo · name · search · bell)
// ---------------------------------------------------------------------------

/// The sticky top application bar shown on the Home screen.
///
/// Only this widget is pinned; the blue hero balance card below it scrolls.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.onSearchPressed,
    required this.onNotificationPressed,
    this.unreadCount = 0,
  });

  final VoidCallback onSearchPressed;
  final VoidCallback onNotificationPressed;

  /// Number of unread notifications — drives the red badge.
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.primaryBlue,
      padding: EdgeInsets.fromLTRB(16, topPadding + 4, 4, 4),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(AppAssets.logo, width: 30, height: 30),
          ),
          const SizedBox(width: 8),
          Text(
            'XPensa',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Search transactions',
            onPressed: onSearchPressed,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          Stack(
            children: <Widget>[
              IconButton(
                tooltip: 'Notifications',
                onPressed: onNotificationPressed,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 10,
                  right: 12,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryBlue,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => AppRoutes.pushSettings(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HomeHeader — scrollable blue hero card (balance, metrics, budget bar)
// ---------------------------------------------------------------------------

/// Blue hero section showing the net total and monthly metrics.
///
/// This widget is NOT sticky — it scrolls with the page content.
class HomeHeader extends StatefulWidget {
  const HomeHeader({
    super.key,
    required this.stats,
    required this.accountSummary,
    required this.currencyFormat,
    required this.privacyModeEnabled,
    required this.onTogglePrivacy,
  });

  final ExpenseStats stats;
  final AccountSummary accountSummary;
  final NumberFormat currencyFormat;
  final bool privacyModeEnabled;
  final VoidCallback onTogglePrivacy;

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  bool _netWorthRevealed = false;

  @override
  Widget build(BuildContext context) {
    final stats = widget.stats;
    final netTotal = formatSignedCurrencyForHome(
      stats.monthNetTotal,
      widget.currencyFormat,
      masked: widget.privacyModeEnabled,
    );
    final bool isDeficit = stats.monthNetTotal < 0;
    final bool isZero = stats.monthNetTotal == 0;

    // Inline surplus/deficit indicator colour & symbol
    final Color signColor = isZero
        ? Colors.white54
        : isDeficit
            ? const Color(0xFFFFA2A2)
            : const Color(0xFFA2FFC0);
    final String signSymbol = isZero
        ? ''
        : isDeficit
            ? '−'
            : '+';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: <Widget>[
          // Label row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'ALL ACCOUNTS',
                style: TextStyle(
                  color: AppColors.overlayWhiteMedium,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                button: true,
                label: 'Toggle privacy mode',
                child: GestureDetector(
                  onTap: widget.onTogglePrivacy,
                  child: Tooltip(
                    message: 'Toggle privacy mode',
                    child: Icon(
                      widget.privacyModeEnabled
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.overlayWhiteMedium,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Balance row — colored sign prefix + amount
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (signSymbol.isNotEmpty) ...[
                Text(
                  signSymbol,
                  style: TextStyle(
                    color: signColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    netTotal,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Net worth chip (tap to reveal)
          GestureDetector(
            onTap: () => setState(() => _netWorthRevealed = !_netWorthRevealed),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withAlpha(60)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white70,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Net Worth: ${_netWorthRevealed ? widget.currencyFormat.format(widget.accountSummary.totalBalance) : '• • •'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _netWorthRevealed
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white54,
                    size: 13,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Expense & Income Cards
          Row(
            children: <Widget>[
              Expanded(
                child: _MetricCard(
                  label: 'EXPENSE',
                  amount: maskAmount(
                    widget.currencyFormat.format(stats.monthTotal),
                    masked: widget.privacyModeEnabled,
                  ),
                  iconData: Icons.arrow_downward_rounded,
                  iconColor: const Color(0xFFFF8585),
                  iconBgColor: const Color(0xFFFF8585).withAlpha(50),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MetricCard(
                  label: 'INCOME',
                  amount: maskAmount(
                    widget.currencyFormat.format(stats.monthIncomeTotal),
                    masked: widget.privacyModeEnabled,
                  ),
                  iconData: Icons.arrow_upward_rounded,
                  iconColor: const Color(0xFF85FFB8),
                  iconBgColor: const Color(0xFF85FFB8).withAlpha(50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.amount,
    required this.iconData,
    required this.iconColor,
    required this.iconBgColor,
  });

  final String label;
  final String amount;
  final IconData iconData;
  final Color iconColor;
  final Color iconBgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.overlayWhiteMedium,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Formats [amount] as an absolute currency string optionally masked.
String formatSignedCurrencyForHome(
  double amount,
  NumberFormat currencyFormat, {
  required bool masked,
}) {
  if (amount == 0) {
    return maskAmount(currencyFormat.format(0), masked: masked);
  }

  // Return the absolute amount for display, dropping the +/- sign.
  return maskAmount(
    currencyFormat.format(amount.abs()),
    masked: masked,
  );
}
