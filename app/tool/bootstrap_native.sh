#!/usr/bin/env bash
set -euo pipefail

# Run from any directory; Flutter project generation happens inside app/.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK is required. Install Flutter and add flutter to PATH." >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "Python 3 is required to configure native permission files." >&2
  exit 1
fi

cd "$APP_DIR"

# Generates the missing native host projects while preserving the existing Dart app.
# com.zuno is a provisional Android/iOS bundle namespace; choose the final reverse-domain
# identifier before publishing the app.
flutter create --platforms=android,ios --project-name zuno --org com.zuno .

python3 - <<'PY'
from pathlib import Path
import plistlib
import re

# Android BLE permissions: Android 12+ runtime permissions plus legacy permissions
# for Android 11 and older. Never claim that BLE scan results are used for location.
manifest = Path("android/app/src/main/AndroidManifest.xml")
xml = manifest.read_text()
permissions = [
    '    <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />',
    '    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />',
    '    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />',
    '    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />',
    '    <uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />',
    '    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" android:maxSdkVersion="30" />',
]
for permission in permissions:
    name = re.search(r'android:name="([^"]+)"', permission).group(1)
    if f'android:name="{name}"' not in xml:
        xml = xml.replace('    <application', permission + '\n    <application', 1)
manifest.write_text(xml)

# BLE central/peripheral usage descriptions for iOS. Keep purpose strings explicit.
plist_path = Path("ios/Runner/Info.plist")
with plist_path.open("rb") as f:
    plist = plistlib.load(f)
plist["NSBluetoothAlwaysUsageDescription"] = (
    "Zuno uses Bluetooth to discover nearby devices for offline connection features."
)
plist["NSBluetoothPeripheralUsageDescription"] = (
    "Zuno uses Bluetooth to make nearby offline connection features available."
)
with plist_path.open("wb") as f:
    plistlib.dump(plist, f, sort_keys=False)

# The plugin supports Android API 24+. Raise the generated minimum SDK to 24.
gradle_kts = Path("android/app/build.gradle.kts")
gradle_groovy = Path("android/app/build.gradle")
if gradle_kts.exists():
    content = gradle_kts.read_text()
    content = re.sub(r'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = 24', content)
    gradle_kts.write_text(content)
elif gradle_groovy.exists():
    content = gradle_groovy.read_text()
    content = re.sub(r'minSdkVersion\s+flutter\.minSdkVersion', 'minSdkVersion 24', content)
    gradle_groovy.write_text(content)
else:
    raise SystemExit("Could not find generated Android app Gradle file.")
print("Configured Android BLE permissions, Android minSdk 24, and iOS Bluetooth purpose strings.")
PY

flutter pub get

echo
echo "Native host projects generated under app/android and app/ios."
echo "Bluetooth permissions are configured for the discovery proof of concept."
echo "Review the provisional application identifier before any public release."
