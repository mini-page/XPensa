/// Accounts feature public API.
///
/// Import this barrel to access all accounts-related screens, widgets, and
/// providers without coupling consumers to the internal directory layout.
///
/// Data layer (AccountModel, repositories, datasources) remains in
/// `lib/features/expense/data/` because it is shared with the core expense
/// feature. Migrate to `lib/features/accounts/data/` once the data layer is
/// fully decoupled.

// Presentation – screens
export '../expense/presentation/screens/accounts_screen.dart';
export '../expense/presentation/screens/accounts/accounts_widgets.dart';

// Presentation – providers
export '../expense/presentation/provider/account_providers.dart';

// Data models (shared; re-exported for convenience)
export '../expense/data/models/account_model.dart';
