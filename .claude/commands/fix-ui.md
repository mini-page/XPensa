# fix-ui — Fix UI Layout & Rendering Issues

## Purpose
Diagnose and resolve Flutter UI bugs: layout overflows, incorrect constraints, rendering artifacts, and responsiveness failures on Android and Web.

## Steps

1. **Identify the symptom**
   - Describe the overflow direction, broken widget, or visual glitch.
   - Note whether the issue is Android-only, Web-only, or both.

2. **Locate the widget**
   - Search for the screen in `lib/features/<feature>/presentation/screens/`.
   - Check sibling sub-directory (`screens/<name>/`) for extracted widgets.

3. **Common fixes**

   | Symptom | Fix |
   |---------|-----|
   | `RenderFlex overflow` | Wrap with `Flexible`, `Expanded`, or `SingleChildScrollView`. |
   | Hardcoded pixel size breaks Web | Replace with `MediaQuery` / `LayoutBuilder` percentages. |
   | Text overflow on small screens | Add `overflow: TextOverflow.ellipsis` or `maxLines`. |
   | Image too large / not loading | Use `BoxFit.cover`, add `cacheWidth`/`cacheHeight`. |
   | Dark-mode color mismatch | Replace raw `Colors.*` with `Theme.of(context).colorScheme.*` tokens. |
   | Keyboard covers input fields | Wrap with `SingleChildScrollView` + `resizeToAvoidBottomInset: true`. |

4. **Verify**
   - Run on Android: `flutter run -d <android-device>`.
   - Run on Web: `flutter run -d chrome`.
   - No new `flutter analyze` warnings.

## Related Agent
Use `flutter-reviewer` for a full widget-tree audit.
