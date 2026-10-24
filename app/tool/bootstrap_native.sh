#!/usr/bin/env bash
set -euo pipefail

# Run from any directory; Flutter project generation happens inside app/.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK is required. Install Flutter and add flutter to PATH." >&2
  exit 1
fi

cd "$APP_DIR"

# Generates the missing native host projects while preserving the existing Dart app.
# com.zuno is a provisional Android/iOS bundle namespace; choose the final reverse-domain
# identifier before publishing the app.
flutter create --platforms=android,ios --project-name zuno --org com.zuno .
flutter pub get

echo
echo "Native host projects generated under app/android and app/ios."
echo "Review the provisional application identifier before any public release."
