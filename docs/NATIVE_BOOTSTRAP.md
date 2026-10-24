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
