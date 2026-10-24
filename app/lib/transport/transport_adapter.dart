import '../models/zuno_message.dart';

enum TransportAvailability {
  available,
  unavailable,
}

enum TransportSendOutcome {
  /// The transport accepted the message for routing, not necessarily delivery.
  acceptedForRouting,

  /// The peer device acknowledged receipt.
  recipientAcknowledged,

  /// The route is temporarily unavailable; keep the message queued.
  temporarilyUnavailable,

  /// The transport rejected the message for a non-retryable reason.
  rejected,
}

/// Contract shared by nearby Bluetooth and internet-relay adapters.
///
/// This is an interface only. It does not claim that either transport is
/// connected or implemented on a device.
abstract interface class ZunoTransportAdapter {
  MessageTransport get kind;

  Future<TransportAvailability> checkAvailability();

  Future<TransportSendOutcome> send(ZunoMessage message);
}
