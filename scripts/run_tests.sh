#!/usr/bin/env bash
# Run automated tests headlessly. Set GODOT to your Godot 4 executable if not in PATH.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT:-godot}"

if ! command -v "$GODOT" >/dev/null 2>&1; then
  for candidate in \
    "/d/Programming/Tools/Godot_v4.7/Godot_v4.7-stable_win64_console.exe" \
    "/d/Programming/Tools/Godot_v4.7/Godot_v4.7-stable_win64.exe"; do
    if [ -x "$candidate" ]; then
      GODOT="$candidate"
      break
    fi
  done
fi

if ! command -v "$GODOT" >/dev/null 2>&1 && [ ! -x "$GODOT" ]; then
  echo "Godot not found. Install Godot 4.4+ and add to PATH, or set GODOT=/path/to/godot"
  exit 1
fi

echo "Using: $GODOT"
"$GODOT" --headless --path "$ROOT" res://tests/test_runner.tscn "$@"
