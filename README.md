# XPensa

XPensa is a cross-platform expense tracker designed for a simple, focused money-management experience. The app aims to make daily spending easy to log, easy to review, and easy to understand without clutter.

## Overview

| Item | Details |
| --- | --- |
| Product Type | Personal expense tracker |
| Experience Goal | Fast expense logging with a clean, minimal UI |
| Platforms | Android, iOS, Web, Windows, macOS, Linux |
| Current Direction | Offline-first personal finance MVP |
| Primary Focus | Add, view, delete, and summarize expenses |

## Core Experience

XPensa is being shaped around a lightweight, distraction-free flow:

- add an expense in a few taps
- view spending in a clean list
- review monthly totals at a glance
- keep your personal finance data available locally

## Feature Snapshot

| Feature | Purpose | Status |
| --- | --- | --- |
| Expense list | Browse recorded expenses in one place | In progress |
| Add expense flow | Capture amount, category, date, and note | In progress |
| Delete action | Remove incorrect or unwanted entries | Planned in MVP |
| Monthly summary | Quick overview of total spending | Planned in MVP |
| Category insights | Better visibility into spending habits | Planned |
| Cloud sync | Multi-device data sync | Later |

## UI Direction

| Area | Focus |
| --- | --- |
| Home screen | Clear expense list with fast entry access |
| Add expense flow | Minimal form, low-friction input |
| Stats view | Simple summaries instead of dense dashboards |
| Visual style | Clean, readable, and practical |
| Interaction model | Quick actions over complex navigation |

## MVP Scope

The first release is intentionally small and focused on the essentials:

- add expense
- show expense list
- delete expense
- display basic monthly totals

This keeps the product lean while the core experience is validated.

## Getting Started

### Prerequisites

- Flutter SDK
- A configured emulator, simulator, or connected device

### Run Locally

```bash
flutter pub get
flutter run
```

### Useful Commands

| Command | What it does |
| --- | --- |
| `flutter run` | Runs the app on the selected device |
| `flutter analyze` | Checks the code for issues |
| `dart format .` | Formats the Dart codebase |
| `flutter build apk` | Builds an Android APK |

## Platform Support

XPensa is built with Flutter, which allows one codebase to target:

- Android
- iOS
- Web
- Windows
- macOS
- Linux

## Project Status

XPensa is in an early build phase. The foundation is being prepared around a polished expense-entry experience first, with broader finance features planned after the MVP is stable.

## Roadmap

| Stage | Focus |
| --- | --- |
| MVP | Expense entry, list management, monthly totals |
| Next | Categories, better summaries, UI refinement |
| Later | Sync, authentication, advanced budgeting flows |

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
