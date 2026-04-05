# optimize-build — Reduce App Size & Improve Build Speed

## Purpose
Minimize APK/AAB size for Android and bundle size for Web, and speed up incremental build times.

## Android Optimization

1. **Build in release mode with tree-shaking**
   ```bash
   flutter build apk --release --split-per-abi
   # or
   flutter build appbundle --release
   ```

2. **Analyze APK size**
   ```bash
   flutter build apk --analyze-size
   ```

3. **Asset audit**
   - Remove unused images from `assets/images/`.
   - Use WebP instead of PNG for photos.
   - Ensure launcher icons in `assets/icon/` are not duplicated in `assets/images/`.

4. **Dependency audit**
   - Run `flutter pub deps` and remove unused packages from `pubspec.yaml`.
   - Prefer smaller alternatives for large transitive deps.

## Web Optimization

1. **Build with CanvasKit vs HTML renderer**
   ```bash
   # Smaller bundle for text-heavy apps:
   flutter build web --web-renderer html --release
   # Better fidelity:
   flutter build web --web-renderer canvaskit --release
   ```

2. **Enable gzip/brotli** in your web server config for `main.dart.js`.

3. **Font subsetting** – only include needed `GoogleFonts` locales.

## Build Speed

- Use `flutter build apk --debug` during development.
- Keep Hive-generated `.g.dart` files committed to avoid re-running `build_runner` in CI.
- Run `flutter clean` only when dependency versions change.

## Verify
```bash
flutter analyze
flutter test
```
