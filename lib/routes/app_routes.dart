import 'package:flutter/material.dart';

import '../features/expense/data/models/expense_model.dart';
import '../features/expense/presentation/screens/add_expense_screen.dart';
import '../features/expense/presentation/screens/notifications_screen.dart';
import '../features/expense/presentation/screens/records_history_screen.dart';
import '../features/expense/presentation/screens/scanner_screen.dart';
import '../features/expense/presentation/screens/settings_screen.dart';
import '../features/expense/presentation/screens/transaction_search_screen.dart';

/// Centralised navigation helpers for XPensa.
///
/// All `Navigator.push` / `pushReplacement` calls for named screens are
/// routed through this class so that screen locations and constructor
/// signatures are maintained in a single place.
abstract final class AppRoutes {
  // ── Add / Edit Expense ─────────────────────────────────────────────────────

  /// Push [AddExpenseScreen] to create a new transaction.
  static Future<void> pushAddExpense(
    BuildContext context, {
    String? initialCategory,
    double? initialAmount,
    DateTime? initialDate,
    String? initialNote,
    String? initialAccountId,
    String? initialToAccountId,
    TransactionType initialType = TransactionType.expense,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AddExpenseScreen(
          initialCategory: initialCategory,
          initialAmount: initialAmount,
          initialDate: initialDate,
          initialNote: initialNote,
          initialAccountId: initialAccountId,
          initialToAccountId: initialToAccountId,
          initialType: initialType,
        ),
      ),
    );
  }

  /// Push [AddExpenseScreen] to edit an existing transaction.
  static Future<void> pushEditExpense(
    BuildContext context, {
    required String expenseId,
    required double initialAmount,
    required String initialCategory,
    required DateTime initialDate,
    required String initialNote,
    String? initialAccountId,
    String? initialToAccountId,
    TransactionType initialType = TransactionType.expense,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AddExpenseScreen(
          expenseId: expenseId,
          initialAmount: initialAmount,
          initialCategory: initialCategory,
          initialDate: initialDate,
          initialNote: initialNote,
          initialAccountId: initialAccountId,
          initialToAccountId: initialToAccountId,
          initialType: initialType,
        ),
      ),
    );
  }

  // ── Records History ────────────────────────────────────────────────────────

  /// Push the full transaction history screen.
  static Future<void> pushRecordsHistory(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const RecordsHistoryScreen()),
    );
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  /// Push the transaction search screen.
  static Future<void> pushTransactionSearch(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const TransactionSearchScreen(),
      ),
    );
  }

  // ── Settings ───────────────────────────────────────────────────────────────

  /// Push the settings screen.
  static Future<void> pushSettings(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
  }

  // ── Notifications ──────────────────────────────────────────────────────────

  /// Push the notifications screen.
  static Future<void> pushNotifications(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const NotificationsScreen(),
      ),
    );
  }

  // ── Scanner ────────────────────────────────────────────────────────────────

  /// Push the QR / barcode scanner screen.
  static Future<void> pushScanner(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const ScannerScreen()),
    );
  }

  /// Replace the current route with [AddExpenseScreen].
  ///
  /// Used by [ScannerScreen] after a successful scan so that the user returns
  /// directly to the expense form rather than back to the scanner.
  static void replaceWithAddExpense(
    BuildContext context, {
    double? initialAmount,
    String? initialNote,
  }) {
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) => AddExpenseScreen(
            initialAmount: initialAmount, initialNote: initialNote),
      ),
    );
  }
}
