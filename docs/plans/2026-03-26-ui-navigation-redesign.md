# Design Doc: UI Navigation Redesign & Search Implementation

**Date:** 2026-03-26
**Status:** Approved
**Topic:** UI structure overhaul, Sidebar integration, Search flow, and Real-time Scanning.

## 1. Overview
The goal of this redesign is to focus the main interface on core actionability while moving administrative and secondary features to a new sidebar. We are also introducing a dedicated search capability and a high-utility "Power Pill" for rapid transaction entry.

## 2. Architecture & Components

### 2.1 AppShell Expansion
- **Scaffold Update**: Add a `GlobalKey<ScaffoldState>` and a `Drawer` property.
- **AppDrawer Widget**: A custom sidebar containing:
    - Profile Header (Avatar, Name).
    - Preferences Section (Theme, Privacy Mode, Smart Reminders).
    - Utility Links (About, Support, Miscellaneous).
- **Gradient Overlay**: A subtle `LinearGradient` (transparent to semi-dark) at the bottom of the stack to improve contrast for the floating pill navbar.

### 2.2 HomeScreen Refactor
- **Header Navigation**:
    - **Top-Left**: Hamburger menu icon (`Icons.menu_rounded`) to open the sidebar.
    - **Top-Right**: Search icon (`Icons.search_rounded`) replacing the old filter icon.
- **Search Flow**:
    - Dedicated `TransactionSearchScreen`.
    - Real-time filtering via Riverpod.
    - Internal filter overlay for Category/Date Range refinement.

### 2.3 The "Power Pill" (5th Tab)
- **Primary Action**: Single tap opens the standard `AddExpenseScreen`.
- **Secondary Actions**: Long press / Double tap reveals a floating sub-menu:
    -🎤 **Voice**: Voice input.
    -👥 **Split**: Split Bill tool.
    -📷 **Scanner**: Real-time barcode/QR scanner.
- **Aesthetics**: Bold `AppColors.primaryBlue` background with a white icon.

### 2.4 Scanner Integration
- **Dependency**: `mobile_scanner`.
- **Logic**: Live camera feed with barcode/QR detection.
- **Data Parsing**: Automatic extraction of UPI payees or receipt data, pre-filling the transaction composer.

## 3. Data Flow
- **Navigation**: Managed via `AppShell` index and standard `Navigator` pushes for search/scanner.
- **State**: Search query and filtered results managed by a new `searchProvider` in `expense_providers.dart`.
- **Haptics**: Use `HapticFeedback.mediumImpact()` for the Power Pill expansion.

## 4. UI/UX Consistency
- All new components will strictly adhere to `AppColors` and use the unified `AppColors.cardShadow`.
- Animations will use `Curves.fastOutSlowIn` to match existing app transitions.
