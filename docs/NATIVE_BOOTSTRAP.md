# Native project bootstrap and BLE device testing

Zuno's repository keeps its Flutter/Dart application separate from generated native host projects. The bootstrap script generates Android and iOS host projects and configures the minimum permissions for the BLE discovery proof of concept.

From the repository root:

```bash
bash app/tool/bootstrap_native.sh
```

The script requires Flutter and Python 3. It generates `app/android` and `app/ios`, sets Android minSdk to 24, adds Android Bluetooth permissions, adds iOS Bluetooth purpose strings, and runs `flutter pub get`.

## Permissions configured

- Android 12 and newer: `BLUETOOTH_SCAN` (with `neverForLocation`), `BLUETOOTH_CONNECT`, and `BLUETOOTH_ADVERTISE`.
- Android 11 and older: legacy `BLUETOOTH` and `BLUETOOTH_ADMIN`, plus fine location capped at API 30 for older BLE scan behavior.
- iOS: `NSBluetoothAlwaysUsageDescription` and the legacy `NSBluetoothPeripheralUsageDescription` purpose string.

The plugin's authorization API is called before discovery starts. The operating system may still deny, restrict, or disable Bluetooth; Zuno must show a helpful error and must not bypass user permission choices. No background scanning entitlement or location-in-the-background permission is enabled.

## Physical-device discovery test (required)

A GitHub-hosted Linux runner can verify Dart analysis, tests, and generated permission declarations, but it cannot establish that radio discovery works on actual phones. Do not mark real-device discovery as passed until this checklist has been run on physical devices.

### Prepare the build

1. Run `bash app/tool/bootstrap_native.sh`.
2. Connect an Android phone with USB debugging enabled. Build/install with `cd app && flutter run` from a machine with Android SDK/ADB configured.
3. For iPhone, use macOS with Xcode, a signed development team, and a physical iPhone. Open `app/ios/Runner.xcworkspace`, confirm the bundle identifier/signing, then run on the device.
4. Confirm Bluetooth is enabled on both phones and accept the operating system permission prompt.

### Discovery matrix

- [ ] Android phone scans with mobile data and Wi-Fi turned off; Bluetooth remains on.
- [ ] iPhone scans with mobile data and Wi-Fi turned off; Bluetooth remains on.
- [ ] On phone A, tap **Make this phone discoverable**; on phone B, tap **Scan for Zuno devices**. Repeat in the opposite direction.
- [ ] Android and iPhone are tested near each other, then farther apart.
- [ ] A permission denial is handled without a crash; enabling permission in Settings allows a retry.
- [ ] Stop scanning stops discovery without leaving a stuck spinner.
- [ ] Record device model, OS version, build/commit, scan result, and any logs.

Important: the current discovery view lists BLE peripherals visible to the phone, not confirmed Zuno users. The Nearby screen now has separate controls to advertise a public Zuno service UUID and scan specifically for that service. Advertisements contain only the short name and service UUID—no message content or personal identity. This makes a physical-device discovery test possible, but Android-to-iPhone behavior remains unverified until tested on actual phones. GATT connection, authenticated peer identity, and message transfer are not implemented.

## Remaining limitations

- The generated `com.zuno` application/bundle identifier is provisional. Choose a permanent reverse-domain identifier before public distribution.
- Generating host projects does not implement local Wi-Fi transfer, multi-hop mesh forwarding, encryption, or internet relay.
- iOS builds require macOS/Xcode; Linux CI cannot validate an iOS device build.
- Do not put names, stable personal IDs, or message content into BLE advertisements.
- Before sending messages, define a public service UUID, GATT characteristics, authenticated peer verification, message framing, encryption, retry behavior, and physical Android-to-iPhone tests.

## Package reference

The proof of concept uses the `bluetooth_low_energy` Flutter plugin: https://pub.dev/packages/bluetooth_low_energy
