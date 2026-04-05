/// Analytics / Statistics feature public API.
///
/// Import this barrel to access all statistics-related screens, widgets, and
/// providers.
///
/// The underlying stats computation lives in `expense_providers.dart`
/// (`statsProvider`, `filteredExpensesProvider`) because it is tightly coupled
/// to the expense data model.  Future work: extract `StatsNotifier` into this
/// feature's own provider.

// Presentation – screens
export '../expense/presentation/screens/stats_screen.dart';
export '../expense/presentation/screens/stats/stats_widgets.dart';

// Presentation – providers (stats live in the expense providers for now)
export '../expense/presentation/provider/expense_providers.dart'
    show statsProvider, filteredExpensesProvider;
