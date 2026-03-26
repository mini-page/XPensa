# UI Navigation Redesign & Search Flow Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Overhaul the app navigation by introducing a sidebar for administrative tasks, a dedicated search flow, and a high-utility "Power Pill" action menu with real-time scanning.

**Architecture:** Refactor `AppShell` to support a `Drawer` and a hybrid navigation model. Core views remain in the bottom pill, while Profile and Settings move to the sidebar. Search and Scanner are implemented as dedicated push-based screens.

**Tech Stack:** Flutter, Riverpod, `mobile_scanner` 6.0.0+, `intl`.

---

### Task 1: Environment Setup & Dependencies

**Files:**
- Modify: `pubspec.yaml`

**Step 1: Add mobile_scanner dependency**
Add `mobile_scanner: ^6.0.0` to `dependencies` section.

**Step 2: Run pub get**
Run: `flutter pub get`

**Step 3: Commit**
```bash
git add pubspec.yaml
git commit -m "chore: add mobile_scanner dependency"
```

---

### Task 2: AppShell Refactor - Drawer Architecture

**Files:**
- Modify: `lib/features/expense/presentation/screens/app_shell.dart`
- Create: `lib/features/expense/presentation/widgets/app_drawer.dart`

**Step 1: Add GlobalKey and Scaffold Update**
Update `_AppShellState` to hold a `final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();`.
Apply this key to the `Scaffold` and add an empty `Drawer`.

**Step 2: Scaffolding AppDrawer**
Create `lib/features/expense/presentation/widgets/app_drawer.dart` with a basic `Drawer` structure using `AppColors`.

**Step 3: Update buildPages to 4 items**
Remove `ProfileScreen` from the `_buildPages` list in `AppShell`.

**Step 4: Verify navigation still works for first 4 tabs**
Run: `flutter test` (standard tests should pass).

**Step 5: Commit**
```bash
git add lib/features/expense/presentation/screens/app_shell.dart lib/features/expense/presentation/widgets/app_drawer.dart
git commit -m "refactor: update AppShell architecture for Drawer support"
```

---

### Task 3: Sidebar Implementation (AppDrawer)

**Files:**
- Modify: `lib/features/expense/presentation/widgets/app_drawer.dart`
- Modify: `lib/features/expense/presentation/screens/profile_screen.dart` (to extract logic)

**Step 1: Move Profile logic to AppDrawer**
Refactor the profile header and settings toggles from `ProfileScreen` into `AppDrawer`.

**Step 2: Add About/Support/Miscellaneous sections**
Add simple list tiles for these sections with placeholder icons.

**Step 3: Apply AppColors and cardShadow to drawer items**
Ensure consistent styling.

**Step 4: Commit**
```bash
git add lib/features/expense/presentation/widgets/app_drawer.dart lib/features/expense/presentation/screens/profile_screen.dart
git commit -m "feat: implement AppDrawer with Profile and Settings"
```

---

### Task 4: HomeScreen Header Refactor

**Files:**
- Modify: `lib/features/expense/presentation/screens/home_screen.dart`

**Step 1: Add Hamburger Menu Icon**
Update `_Header` to accept an `onMenuPressed` callback. Place a menu icon at the top-left.

**Step 2: Replace Filter with Search Icon**
Change the icon at the top-right of the header from `tune_rounded` to `search_rounded`.

**Step 3: Pass callbacks from HomeScreen build**
Ensure tapping menu calls `_scaffoldKey.currentState?.openDrawer()`.

**Step 4: Commit**
```bash
git add lib/features/expense/presentation/screens/home_screen.dart
git commit -m "feat: add menu and search icons to HomeScreen header"
```

---

### Task 5: Transaction Search Flow

**Files:**
- Create: `lib/features/expense/presentation/screens/transaction_search_screen.dart`
- Modify: `lib/features/expense/presentation/provider/expense_providers.dart` (for search logic)

**Step 1: Create searchProvider**
Implement a `searchQueryProvider` (StateProvider) and a `filteredExpensesProvider` that reacts to the query.

**Step 2: Implement TransactionSearchScreen UI**
Add a search field with autofocus and a results list using `TransactionCard`.

**Step 3: Link HomeScreen search icon to SearchScreen**
`Navigator.of(context).push(...)`.

**Step 4: Commit**
```bash
git add lib/features/expense/presentation/provider/expense_providers.dart lib/features/expense/presentation/screens/transaction_search_screen.dart
git commit -m "feat: implement transaction search flow"
```

---

### Task 6: The "Power Pill" Action Menu

**Files:**
- Modify: `lib/features/expense/presentation/screens/app_shell.dart`
- Create: `lib/features/expense/presentation/widgets/power_pill_menu.dart`

**Step 1: Replace 5th tab with PowerPill**
Update `_NavBarItem` or create a unique widget for the 5th position that handles tap vs long-press.

**Step 2: Implement pop-out animation logic**
Create `PowerPillMenu` that uses `Overlay` to show Voice/Split/Scanner options.

**Step 3: Add Haptic feedback**
Trigger `HapticFeedback.mediumImpact()` on long-press.

**Step 4: Commit**
```bash
git add lib/features/expense/presentation/screens/app_shell.dart lib/features/expense/presentation/widgets/power_pill_menu.dart
git commit -m "feat: implement Power Pill action menu with animations"
```

---

### Task 7: Real-Time Scanner Integration

**Files:**
- Create: `lib/features/expense/presentation/screens/scanner_screen.dart`

**Step 1: Implement ScannerScreen with mobile_scanner**
Set up the `MobileScanner` controller and view.

**Step 2: Implement QR/Barcode parsing**
Add logic to extract data from scanned codes.

**Step 3: Link to AddExpenseScreen**
Navigate to composer with pre-filled `initialAmount`, `initialCategory`, etc.

**Step 4: Commit**
```bash
git add lib/features/expense/presentation/screens/scanner_screen.dart
git commit -m "feat: integrate real-time barcode and QR scanner"
```

---

### Task 8: Final Polish & Gradient Overlay

**Files:**
- Modify: `lib/features/expense/presentation/screens/app_shell.dart`

**Step 1: Add bottom gradient overlay**
Implement the `Positioned` gradient at the bottom of the `AppShell` stack.

**Step 2: Final Verify**
Run: `flutter analyze && flutter test`

**Step 3: Commit**
```bash
git add lib/features/expense/presentation/screens/app_shell.dart
git commit -m "style: add bottom navigation gradient and final cleanup"
```
