# XPens – Tasks & Future Goals

> **Purpose:** Backlog of planned improvements, feature ideas, and technical debt items for the XPens app.
> Update this file as items are started, completed, or reprioritised.
> Last updated: 2026-04-20.

---

## Legend

| Symbol | Meaning |
|--------|---------|
| 🔴 | High priority / blocking |
| 🟡 | Medium priority |
| 🟢 | Low priority / nice-to-have |
| ✅ | Done |
| 🚧 | In progress |

---

## 1. Brand & Assets

| # | Priority | Task | Notes |
|---|----------|------|-------|
| B-1 | 🔴 | Replace `assets/icon/app_icon.png` with new logo (1024×1024, solid bg, no alpha) | See brand guide below |
| B-2 | 🔴 | Replace `assets/icon/app_icon_fg.png` with logo foreground (1024×1024, transparent bg, logo centred at ~66%) | For Android adaptive icon |
| B-3 | 🔴 | Replace `assets/icon/splash_mark.png` with new logo mark (512×512, transparent bg) | For splash screen |
| B-4 | 🔴 | Replace `assets/images/xpens_logo.png` with in-app logo (1024×1024, transparent bg) | Shown in About / Onboarding |
| B-5 | 🔴 | Update `adaptive_icon_background` colour in `pubspec.yaml` to match new brand navy | Currently `#0A6BE8` (blue) |
| B-6 | 🔴 | Run `flutter pub run flutter_launcher_icons` after asset replacement to regenerate all mipmap PNGs | Auto-generates density variants |
| B-7 | 🔴 | Run `flutter pub run flutter_native_splash:create` after asset replacement to regenerate splash assets | Auto-generates all drawable variants |
| B-8 | 🟡 | Update `website/index.html` hero image and OG meta tags with new brand visuals | Marketing landing page |
| B-9 | 🟡 | Export a dark-mode variant of the logo mark for dark-theme in-app usage | |

### Brand Spec (new logo — the P-mark icon)

| Asset | Canvas | Logo area | Background | Format |
|-------|--------|-----------|------------|--------|
| `app_icon.png` | 1024×1024 | 100% | Solid dark navy (e.g. `#0F1629`) | PNG, no alpha |
| `app_icon_fg.png` | 1024×1024 | ~680×680 px centred | **Transparent** | PNG RGBA |
| `splash_mark.png` | 512×512 | ~300×300 px centred | **Transparent** | PNG RGBA |
| `xpens_logo.png` | 1024×1024 | your choice | Transparent preferred | PNG RGBA |

---

## 2. Architecture & Code Quality

| # | Priority | Task | Notes |
|---|----------|------|-------|
| A-1 | 🟡 | Physical feature migration – move `accounts`, `categories`, `analytics`, `settings` providers + data layer into their own `lib/features/<name>/` directories | Currently re-exported via barrel; actual code still lives under `expense/` |
| A-2 | 🟡 | Create `lib/features/sms_parser/` proper barrel `sms_parser.dart` index with full re-exports | Partial – `sms_parser.dart` exists but may need updating |
| A-3 | 🟡 | Add Hive TypeAdapter for `CustomCategoryModel` if missing | Check `hive_bootstrap.dart` |
| A-4 | 🟢 | Replace remaining inline `ThemeData` usages (if any) with `AppTheme.light()` / `AppTheme.dark()` | |
| A-5 | 🟢 | Audit all `BuildContext` usages across screens – replace `MediaQuery.of(context)` with `context.screenWidth` extension helpers | `context_extensions.dart` |
| A-6 | 🟢 | Add `AppButton` coverage to all remaining full-width button patterns in onboarding and editor sheets | `lib/shared/widgets/app_button.dart` already exists |

---

## 3. New Features

| # | Priority | Task | Notes |
|---|----------|------|-------|
| F-1 | 🔴 | **PIN / Biometric lock** – complete `pin_entry_screen.dart` + wire `biometric_service.dart` into app launch flow | Screen + service exist; need provider wiring |
| F-2 | 🔴 | **Notifications** – implement actual push/local notification scheduling via `notifications_provider.dart` | Provider scaffolded; scheduling logic pending |
| F-3 | 🔴 | **Home Widget** – complete `widget_sync_service.dart` to sync today's spend to Android home-screen widget via `home_widget` package | Service scaffolded |
| F-4 | 🟡 | **SMS Auto-import** – complete `sms_monitoring_service.dart` so detected bank SMS transactions auto-appear in the queue for confirmation | Parser engine exists; monitoring service needs foreground-service permission handling |
| F-5 | 🟡 | **Receipt Scanner** – finish `receipt_scanner_screen.dart` OCR pipeline: extract merchant, amount, date and pre-fill AddExpense | Screen scaffolded; OCR logic pending |
| F-6 | 🟡 | **Product Scanner** – complete `product_scanner_screen.dart` to look up product price by barcode via `ai_product_service.dart` | |
| F-7 | 🟡 | **Voice Entry** – complete `voice_entry_screen.dart` so spoken expense amount + category is recognised and submitted | Screen scaffolded; STT integration pending |
| F-8 | 🟡 | **UPI Scanner** – complete `upi_scanner_screen.dart` to parse UPI deep-link QR codes and auto-fill AddExpense | Screen exists; edge-case parsing needed |
| F-9 | 🟡 | **In-app update prompt** – wire `update_service.dart` to show a non-blocking banner when a new version is available | Service scaffolded |
| F-10 | 🟡 | **Custom Categories** – wire `custom_category_model.dart` + `category_editor_sheet.dart` into the CategoriesScreen so users can add/edit/delete their own categories | Model + sheet exist |
| F-11 | 🟢 | **Budget roll-over** – allow unused budget from previous month to carry forward | New feature |
| F-12 | 🟢 | **Multi-currency** – per-account currency with live exchange rates via HTTP | Requires schema change |
| F-13 | 🟢 | **CSV / PDF export** – export transaction history as CSV or PDF via `share_plus` | |
| F-14 | 🟢 | **Shared expenses** – tag a transaction as shared, split with contacts | Long-term |
| F-15 | 🟢 | **iCloud / Google Drive backup** – auto-upload `.xpens` backup file to cloud storage | Long-term |
| F-16 | 🟢 | **Dark/light scheduled theme** – auto-switch theme based on time of day | |
| F-17 | 🟢 | **Loan tracker** – track money lent to / borrowed from people | New feature |

---

## 4. UI / UX Polish

| # | Priority | Task | Notes |
|---|----------|------|-------|
| U-1 | 🟡 | Complete `profile_screen.dart` – user avatar, name, currency, language | Mostly placeholder |
| U-2 | 🟡 | Complete `about_screen.dart` – show version, changelogs, links | Screen exists; content may be thin |
| U-3 | 🟡 | Complete `support_screen.dart` – FAQ, contact form, feedback | Screen exists |
| U-4 | 🟡 | Add empty-state illustrations to StatsScreen when no data for selected month | |
| U-5 | 🟡 | Add haptic feedback on FAB tap and swipe-to-delete gestures | |
| U-6 | 🟢 | Animated number counter for balance amounts on HomeScreen | |
| U-7 | 🟢 | Add skeleton loading placeholders while Hive data is loading | |
| U-8 | 🟢 | Smooth shared-element transition from HomeScreen transaction card → AddExpenseScreen (edit) | |

---

## 5. Testing

| # | Priority | Task | Notes |
|---|----------|------|-------|
| T-1 | 🔴 | Write unit tests for `sms_parser_engine.dart` – cover all common bank SMS formats | |
| T-2 | 🟡 | Write unit tests for `amount_expression.dart` calculator logic | |
| T-3 | 🟡 | Write unit tests for `tag_parser.dart` | |
| T-4 | 🟡 | Widget tests for `FloatingNavBar`, `AppPillSwitch`, `AppButton` | |
| T-5 | 🟢 | Integration test: full add-expense → stats-screen flow | |
| T-6 | 🟢 | Integration test: backup export → wipe → restore flow | |

---

## 6. Performance

| # | Priority | Task | Notes |
|---|----------|------|-------|
| P-1 | 🟡 | Benchmark + optimise `statsProvider` – currently recomputes on every transaction change; consider memoised selector | `benchmark/` directory exists |
| P-2 | 🟡 | Lazy-load `RecordsHistoryScreen` list with `Sliver` pagination instead of loading all transactions at once | |
| P-3 | 🟢 | Profile app startup time; defer Hive box opens that are not needed on first frame | |

---

## 7. DevOps / CI

| # | Priority | Task | Notes |
|---|----------|------|-------|
| D-1 | 🟡 | Add GitHub Actions workflow: `flutter analyze` + `flutter test` on every PR | |
| D-2 | 🟡 | Add release workflow: bump version, build APK/AAB, attach to GitHub Release | |
| D-3 | 🟢 | Add `flutter pub outdated` check in CI | |

---

## 8. Completed ✅

| Date | Item |
|------|------|
| 2026-04-04 | Centralised navigation via `AppRoutes` |
| 2026-04-04 | Barrel `index.dart` exports for all directories |
| 2026-04-04 | `FloatingNavBar` extracted to `shared/widgets/` |
| 2026-04-04 | All large screens split into sub-widget directories |
| 2026-04-04 | `AppPillSwitch` shared widget replacing duplicates |
| 2026-04-06 | `AppTheme.light()` / `AppTheme.dark()` centralised |
| 2026-04-16 | Home screen scroll bottom padding fix (160 dp) |
| 2026-04-19 | Rebrand XPensa → XPens; package `app.xpensa.finance` → `app.xpens.finance` |
