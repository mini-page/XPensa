#!/usr/bin/env bash
# .claude/hooks/build-check.sh
# Verifies the project builds successfully for Android and Web.
# Run in CI or locally before opening a PR.

set -e

echo "▶ flutter pub get"
flutter pub get

echo ""
echo "▶ flutter analyze"
flutter analyze

echo ""
echo "▶ flutter test"
flutter test

echo ""
echo "▶ flutter build apk --debug (Android check)"
flutter build apk --debug

echo ""
echo "▶ flutter build web --release (Web check)"
flutter build web --release

echo ""
echo "✅ All build checks passed."
