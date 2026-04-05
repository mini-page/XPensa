/// Recurring Subscriptions feature public API.
///
/// Import this barrel to access all recurring-subscription UI, state, and
/// data types without coupling consumers to the internal directory layout.
///
/// The underlying data files (model, datasource, repository) live in
/// `lib/features/expense/data/` because they share the same Hive instance.
/// Migrate to `lib/features/recurring/data/` when the data layer is split.

// Presentation – widgets
export '../expense/presentation/widgets/recurring_tool_view.dart';
export '../expense/presentation/widgets/subscription_editor_sheet.dart';
export '../expense/presentation/widgets/subscription_icons.dart';

// Presentation – providers
export '../expense/presentation/provider/recurring_subscription_providers.dart';

// Data models (shared; re-exported for convenience)
export '../expense/data/models/recurring_subscription_model.dart';
