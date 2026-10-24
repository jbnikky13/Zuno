# Zuno

**Connect without limits.**

Zuno is an offline-first social app in development for Android and iPhone. It is designed around two ways to communicate:

- **Zuno Nearby:** Bluetooth-based discovery and local peer-to-peer messaging, plus local Wi-Fi for large file transfers. No mobile data is needed for a successful local transfer.
- **Zuno Anywhere:** An optional encrypted internet relay for messaging people in other cities or countries. This route requires an internet connection on a sending or receiving device or an available internet relay.

Bluetooth cannot send directly across countries. If no route exists, the message remains queued until a route becomes available.

> **Project status:** Early prototype. The Flutter interface, message lifecycle model, transport interface, and route selector are present. Wireless messaging, mesh relaying, file transfer, and the internet relay are not implemented or verified yet.

## Product goals

- **Offline messaging:** Send and receive messages locally without mobile data.
- **International messaging:** Reach friends abroad through an optional internet relay.
- **File sharing:** Transfer photos, videos, documents, and other user-selected files over a local wireless connection.
- **Nearby social:** Discover nearby devices with clear privacy controls.
- **Optional identity:** Use the app without an account; create a profile only if desired.
- **Privacy and safety:** Protect private conversations, require consent for incoming files, and provide blocking and abuse controls.
- **Cross-platform:** Support Android and iOS, validating wireless compatibility on physical devices.

## Repository layout

- `app/` — Flutter app source, message lifecycle model, transport-adapter contract, route selector, tests, and native bootstrap script.
- `docs/ARCHITECTURE.md` — offline/online transport design, international delivery, message states, security, and implementation sequence.
- `docs/NATIVE_BOOTSTRAP.md` — generate and review Android/iOS host projects.
- `.github/workflows/flutter.yml` — native project generation, Dart analysis, and tests in CI.

## Planned technical direction

- **App UI:** Flutter and Dart.
- **Platform networking:** Native Kotlin (Android) and Swift (iOS) integrations where required.
- **Local persistence:** SQLite-compatible storage for conversations, queued messages, and transfer state.
- **Nearby messaging:** Bluetooth Low Energy discovery and a carefully evaluated cross-platform mesh protocol.
- **Local file transport:** A secure local high-throughput connection using platform-supported Wi-Fi networking options.
- **International messaging:** An authenticated internet relay that stores and forwards end-to-end encrypted message envelopes for offline recipients.
- **Optional online services:** Profile sync and backups only with user consent.

These choices are provisional until the cross-platform wireless proof of concept is complete. Bluetooth mesh and local Wi-Fi file transfer are distinct transports; multi-hop file forwarding is not assumed.

## MVP roadmap

1. **Technical proof of concept:** Discover and exchange a small message between a real Android phone and iPhone with mobile data disabled.
2. **Offline chat:** Add local identity, encrypted storage, one-to-one chat, delivery states, and retry queues.
3. **International relay:** Send encrypted messages to a recipient ID abroad, queue messages for temporarily offline recipients, and report accurate delivery states.
4. **File sharing:** Add explicit recipient approval, transfer progress, integrity checks, cancellation, and resumable transfers.
5. **Mesh and groups:** Evaluate and implement multi-hop message relay, duplicate suppression, expiry, and group conversations.
6. **Optional profiles and hardening:** Add nearby discovery controls, trusted contacts, blocking, reporting, and real-device compatibility testing.

## Important limitations

- International delivery requires an internet route; it cannot be achieved by Bluetooth alone across countries.
- Offline delivery requires a reachable peer or a later route to the recipient.
- Background operation is subject to Android and iOS restrictions.
- Wireless connection methods differ between platforms and must be tested; universal iPhone–Android Wi-Fi compatibility should not be assumed.
- A message being queued or accepted by a server is not the same as being delivered.
- Anonymous use does not guarantee complete anonymity; nearby radio activity and metadata may still be observable.

## Development principles

- Prove offline functionality on real devices before claiming it works.
- Prefer established, audited cryptographic protocols over custom cryptography.
- Request only the permissions the app needs and explain why.
- Keep optional online features from becoming a dependency for local messaging.
- Review licenses carefully before incorporating third-party code.
- Never upload files or contacts silently.

## Run checks locally

Install the Flutter SDK, then run:

```bash
bash app/tool/bootstrap_native.sh
cd app
flutter analyze
flutter test
```

The bootstrap script generates Android and iOS host folders. The CI workflow checks that project generation can run and then analyzes/tests the Dart source. Linux CI cannot perform an iOS device build; iOS builds require macOS and Xcode. Native host generation does not mean wireless transports are implemented.

## License

No project license has been selected yet. Until a license is added, do not assume the code is available for reuse.
