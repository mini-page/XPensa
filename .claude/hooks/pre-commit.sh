#!/usr/bin/env bash
# .claude/hooks/pre-commit.sh
# Runs before every git commit. Install with:
#   cp .claude/hooks/pre-commit.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit

set -e

echo "▶ dart format --set-exit-if-changed ."
dart format --set-exit-if-changed . || {
  echo "❌ Formatting issues found. Run 'dart format .' and re-stage your changes."
  exit 1
}

echo "▶ flutter analyze"
flutter analyze || {
  echo "❌ Analysis issues found. Fix them before committing."
  exit 1
}

echo "▶ flutter test"
flutter test || {
  echo "❌ Tests failed. Fix failing tests before committing."
  exit 1
}

echo "✅ Pre-commit checks passed."
