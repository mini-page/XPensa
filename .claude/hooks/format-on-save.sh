#!/usr/bin/env bash
# .claude/hooks/format-on-save.sh
# Applies dart format to all staged .dart files.
# Useful as an editor save-hook or watch script.
#
# Usage (manual): bash .claude/hooks/format-on-save.sh
# Usage (watch):  while inotifywait -e close_write **/*.dart; do bash .claude/hooks/format-on-save.sh; done

set -e

# Format only staged Dart files (efficient in git pre-commit context)
STAGED=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' || true)

if [ -n "$STAGED" ]; then
  echo "▶ Formatting staged Dart files..."
  echo "$STAGED" | xargs dart format
  echo "$STAGED" | xargs git add
  echo "✅ Formatting applied."
else
  echo "ℹ No staged Dart files to format."
fi
