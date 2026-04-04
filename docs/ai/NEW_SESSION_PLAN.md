# Settings & Backup System Handoff Plan

> **Note for New Session:** Use `claude-mem:do` to execute this plan. The current work is implemented locally but UNCOMMITTED.

**Goal**: Finalize the structured settings system and robust offline backup functionality.

## Phase 0: Documentation Discovery
1.  **Workmanager 0.9.0+**: Review `package:workmanager` for Pigeon-generated API changes.
    *   Confirmed: `ExistingWorkPolicy` is replaced by `ExistingPeriodicWorkPolicy` for periodic tasks.
    *   Confirmed: `NetworkType` members are now camelCase (e.g., `notRequired` instead of `not_required`).
2.  **Android Background Tasks**: Review `AndroidManifest.xml` requirements for persistent scheduling.
    *   Required: `RECEIVE_BOOT_COMPLETED` and `WAKE_LOCK`.

## Phase 1: Review and Commit Stability Fixes
1.  **Review `lib/features/expense/presentation/provider/preferences_providers.dart`**:
    *   Ensure `Workmanager().registerPeriodicTask` uses `ExistingPeriodicWorkPolicy.replace`.
    *   Ensure `Constraints` uses `networkType: NetworkType.notRequired`.
2.  **Review `android/app/src/main/AndroidManifest.xml`**:
    *   Ensure `RECEIVE_BOOT_COMPLETED` and `WAKE_LOCK` permissions are present.
3.  **Review `pubspec.yaml`**:
    *   Ensure `workmanager: ^0.9.0` and `path: ^1.9.1` are present.
4.  **Action**: Commit and push these stability fixes to `main`.

## Phase 2: Functional Verification
1.  **Build**: Run `flutter build apk --debug --verbose` to ensure the build completes without encoding or compilation errors.
2.  **Analyze**: Run `flutter analyze` to verify code quality.
3.  **Test**: Run `flutter test` (all 40 unit tests should pass).
4.  **Manual Verification**:
    *   Navigate to **Settings** from the sidebar.
    *   Trigger **Export Data** and verify `.xpensa` file generation.
    *   Enable **Auto Backup**, select a frequency, and verify path selection.

## Anti-Pattern Guards
- DO NOT use `ExistingWorkPolicy` for periodic tasks in Workmanager 0.9.0.
- DO NOT use snake_case for `NetworkType` enums.
- DO NOT use single backslashes in `.properties` files for Windows paths.
