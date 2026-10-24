# Zuno architecture

## Product promise

Zuno supports two complementary communication paths:

1. **Nearby/offline:** Bluetooth-based discovery and peer-to-peer messaging, with optional multi-hop relaying through participating devices. Large files use a separately negotiated local high-throughput connection such as supported local Wi-Fi networking.
2. **Anywhere/online:** When the sender or recipient has internet access, an encrypted message can travel through Zuno's internet relay to a recipient in another city or country.

International delivery cannot be guaranteed by Bluetooth alone. If no internet route exists and the recipient is not reachable through a physical mesh, the message remains queued on the sender's device until a route becomes available.

## Architecture layers

- **Presentation:** Flutter UI shared by Android and iOS.
- **Local application services:** Conversations, device identity, message outbox, delivery state, local contacts, and transfer queue.
- **Local persistence:** SQLite-compatible database. Sensitive local records should be encrypted where practical; key material belongs in platform secure storage.
- **Transport interface:** A transport-agnostic interface exposes discovery, send, receive, status, and cancellation operations.
- **Local transport:** Native platform integrations for BLE discovery/connections and an evaluated cross-platform mesh protocol. File transfer is a separate transport and must not be assumed to work over mesh automatically.
- **Internet transport:** Authenticated HTTPS/WebSocket service for online message submission and delivery, with a durable queue for temporarily offline recipients.
- **Backend storage:** Store only the data required for routing and delivery. Private message bodies must remain end-to-end encrypted so the relay cannot read them.
- **Optional account/profile service:** Profiles and cross-device sync are opt-in. Anonymous local use must remain possible.

## Message lifecycle

1. Create a unique message ID, recipient identity, creation time, expiry, and encrypted payload.
2. Save the message to the local outbox before attempting transmission.
3. Prefer an available direct/local route when the recipient is nearby and the user has not selected another route.
4. If the recipient is not locally reachable and internet is available, submit the encrypted envelope to the online relay.
5. If neither route is available, keep the message queued and show **Queued — not delivered**.
6. Accept delivery receipts only after the recipient device acknowledges receipt.
7. Deduplicate by message ID and reject expired or replayed envelopes.

Statuses should distinguish **Draft**, **Queued**, **Sending**, **Relayed**, **Delivered**, **Read** (only when supported and enabled), **Expired**, and **Failed**. A server accepting a message means **Relayed**, not necessarily **Delivered**.

## International messaging

- International messages use the internet relay, not Bluetooth across countries.
- Either party can be on Wi-Fi or mobile data.
- A recipient can be offline; the server queues the encrypted envelope until the recipient reconnects, subject to configured expiry and storage limits.
- The app should clearly indicate when mobile data may be used and allow users to disable online delivery or restrict it to Wi-Fi.
- Anonymous local identity and international delivery are different requirements. To route a message to a person abroad, Zuno needs a stable recipient identifier or an explicit invitation/link mechanism. This can be a Zuno ID without requiring a phone number.
- End-to-end encryption and key verification must be designed before production deployment. Do not invent a custom cryptographic protocol.

## File sharing

- Nearby files: negotiate a direct, authenticated local connection and stream in chunks.
- Remote files: add a separate opt-in encrypted upload/download flow using internet connectivity; large files may require temporary encrypted object storage.
- Do not silently upload files or relay them through nearby users.
- Require recipient acceptance for files from unknown senders, verify file hashes, enforce size limits, and allow cancellation.
- Do not describe local Wi-Fi as universally interoperable until tested on physical iOS and Android devices.

## Platform constraints

iOS and Android have different Bluetooth, local-network, Wi-Fi and background-execution rules. A shared Flutter interface does not remove these differences. Keep native transport adapters separate and test real devices early. Do not promise always-on background mesh relay or instant delivery while an app is suspended.

## Security and abuse controls

- End-to-end encryption for private message content.
- Device identity and authenticated sessions.
- Rate limits, bounded message size, expiry, hop limits and duplicate suppression.
- Blocking, reporting, contact approval and controls for discovery visibility.
- Secure local key storage and careful backup design.
- Minimal metadata retention, transparent privacy notices and no silent contact uploads.

## Implementation sequence

1. Cross-platform BLE discovery and a tiny text-message proof of concept.
2. Local message persistence and honest delivery states.
3. Internet relay with encrypted envelopes and durable queues.
4. Local high-throughput file transfer.
5. Multi-hop relay and group conversations.
6. Optional profiles, remote file sharing, hardening and pilot testing.

International messaging is an explicit core capability, not a later assumption. The offline and online transports must share one message model and delivery-state system.
