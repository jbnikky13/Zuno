# Zuno

**Connect without limits.**

Zuno is an offline-first social app in development for Android and iPhone. It aims to let people message each other, share files, and connect with nearby devices without relying on mobile data or an internet connection.

The planned experience combines Bluetooth-based discovery and messaging with local Wi-Fi transfers for larger files. Optional internet services may support features such as profile sync or delivery to users outside local range, but local communication is the core goal.

> **Project status:** Early planning. Offline messaging, mesh relaying, and cross-platform file transfer are not yet verified or released.

## Product goals

- **Offline messaging:** Send and receive messages locally without mobile data.
- **File sharing:** Transfer photos, videos, documents, and other user-selected files over a local wireless connection.
- **Nearby social:** Discover nearby devices with clear privacy controls.
- **Optional identity:** Use the app without an account; create a profile only if desired.
- **Privacy and safety:** Protect private conversations, require consent for incoming files, and provide blocking and abuse controls.
- **Cross-platform:** Support Android and iOS, validating wireless compatibility on physical devices.

## Planned technical direction

- **App UI:** Flutter and Dart.
- **Platform networking:** Native Kotlin (Android) and Swift (iOS) integrations where required.
- **Local persistence:** SQLite-compatible storage for conversations, queued messages, and transfer state.
- **Messaging transport:** Bluetooth Low Energy discovery and a carefully evaluated peer-to-peer mesh protocol.
- **File transport:** A secure local high-throughput connection, using platform-supported Wi-Fi networking options.
- **Optional online services:** A later addition for opt-in profile sync, backups, or internet-based delivery.

These choices are provisional until the cross-platform wireless proof of concept is complete. Bluetooth mesh and local Wi-Fi file transfer are distinct transports; multi-hop file forwarding is not assumed.

## MVP roadmap

1. **Technical proof of concept:** Discover and exchange a small message between a real Android phone and iPhone with mobile data disabled.
2. **Offline chat:** Add local identity, encrypted storage, one-to-one chat, delivery states, and retry queues.
3. **File sharing:** Add explicit recipient approval, transfer progress, integrity checks, cancellation, and resumable transfers.
4. **Mesh and groups:** Evaluate and implement multi-hop message relay, duplicate suppression, expiry, and group conversations.
5. **Optional profiles:** Add nearby discovery controls, trusted contacts, blocking, and reporting.
6. **Device testing:** Verify foreground/background behavior, battery use, permissions, and compatibility across real devices.

## Important limitations

- Offline delivery requires a reachable peer or a later route to the recipient.
- Background operation is subject to Android and iOS restrictions.
- Wireless connection methods differ between platforms and must be tested; universal iPhone–Android Wi-Fi compatibility should not be assumed.
- A message being queued is not the same as being delivered.
- Anonymous use does not guarantee complete anonymity; nearby radio activity and metadata may still be observable.

## Development principles

- Prove offline functionality on real devices before claiming it works.
- Prefer established, audited cryptographic protocols over custom cryptography.
- Request only the permissions the app needs and explain why.
- Keep optional online features from becoming a dependency for local messaging.
- Review licenses carefully before incorporating third-party code.

## Current status

This repository is the starting point for Zuno's product and engineering work. The roadmap describes intended functionality, not features that are already implemented.

## License

No project license has been selected yet. Until a license is added, do not assume the code is available for reuse.
