/// Transactions feature public API.
///
/// Import this barrel to access all transaction-related screens, widgets, and
/// providers: adding/editing expenses, browsing history, and search.
///
/// The expense data model and its providers are the core of this feature.
/// They live in `lib/features/expense/` because they predate the feature
/// split; migrate when the data layer is decoupled.

// Presentation – screens
export '../expense/presentation/screens/add_expense_screen.dart';
export '../expense/presentation/screens/add_expense/add_expense_widgets.dart';
export '../expense/presentation/screens/records_history_screen.dart';
export '../expense/presentation/screens/records_history/records_cards.dart';
export '../expense/presentation/screens/records_history/records_expense_list.dart';
export '../expense/presentation/screens/records_history/records_filter.dart';
export '../expense/presentation/screens/records_history/records_filter_bar.dart';
export '../expense/presentation/screens/transaction_search_screen.dart';

// Presentation – widgets
export '../expense/presentation/widgets/transaction_card.dart';

// Presentation – providers
export '../expense/presentation/provider/expense_providers.dart';

// Data models (shared; re-exported for convenience)
export '../expense/data/models/expense_model.dart';
