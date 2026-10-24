# Native project bootstrap

Zuno's source repository currently keeps its Flutter/Dart application separate from generated native host projects. Generate the Android and iOS hosts when you have the Flutter SDK installed.

From the repository root:

```bash
bash app/tool/bootstrap_native.sh
```

The script runs Flutter's project generator for both platforms and then resolves Dart dependencies. It is designed to preserve the existing `lib/` source and tests.

## Important notes

- The generated `com.zuno` reverse-domain identifier is provisional. Choose the final application ID / bundle identifier before publishing.
- Generating host projects does **not** implement Bluetooth discovery, local Wi-Fi transfer, mesh forwarding, encryption, or internet relay.
- The Android host can be built on a configured Android toolchain. An iOS build requires macOS and Xcode; Linux CI can generate the iOS project files but cannot validate an iOS device build.
- Keep generated platform files under version control when you are ready to build and maintain native integrations. Review generated permission declarations before requesting Bluetooth or local-network access.
- Test Bluetooth and local-network behavior on physical Android and iPhone devices; emulator/simulator checks are not sufficient.

## Next native proof of concept

1. Generate and commit the native host folders.
2. Add only the platform permissions needed for the first BLE discovery experiment, with user-facing explanations.
3. Implement a minimal native discovery API behind a Flutter platform-channel adapter.
4. Verify discovery and exchange of a tiny text payload between real devices with mobile data disabled.


## Bluetooth proof-of-concept dependency

The first BLE experiment will use the MIT-licensed `bluetooth_low_energy` Flutter plugin because it exposes both central and peripheral roles on Android and iOS. Package documentation: https://pub.dev/packages/bluetooth_low_energy

Before enabling scanning or advertising in the app:

- Add an explicit Bluetooth purpose string to iOS `Info.plist` (`NSBluetoothAlwaysUsageDescription`; also include the legacy peripheral key if supporting older iOS versions).
- Confirm Android `minSdk` is at least 24 and configure the Bluetooth permissions required by the Android versions being supported.
- Request runtime authorization where the platform requires it and handle denied/restricted states without crashing.
- Use physical devices for radio tests; BLE is not available in standard emulators.
- Advertise only the public service UUID. Do not put names, message contents, stable personal IDs, or other sensitive information into BLE advertisements.

The dependency is a transport building block, not a completed messaging implementation. Zuno still needs a defined GATT service/characteristic contract, message framing, authenticated peer verification, encryption, retries, and real Android-to-iPhone tests.
