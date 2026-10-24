import 'package:flutter/services.dart';

import '../models/zuno_message.dart';
import 'transport_adapter.dart';

/// Dart-side bridge for a future native nearby transport.
///
/// The Android/iOS method handlers are not implemented yet. Until they exist,
/// this adapter fails closed: availability is false and sends remain retryable.
/// The payload must be an end-to-end encrypted envelope before production use.
class PlatformChannelNearbyAdapter implements ZunoTransportAdapter {
  PlatformChannelNearbyAdapter({
    MethodChannel? channel,
  }) : _channel = channel ?? const MethodChannel('zuno/nearby');

  final MethodChannel _channel;

  @override
  MessageTransport get kind => MessageTransport.nearby;

  @override
  Future<TransportAvailability> checkAvailability() async {
    try {
      final available = await _channel.invokeMethod<bool>('isAvailable');
      return available == true
          ? TransportAvailability.available
          : TransportAvailability.unavailable;
    } on MissingPluginException {
      return TransportAvailability.unavailable;
    } on PlatformException {
      return TransportAvailability.unavailable;
    }
  }

  @override
  Future<TransportSendOutcome> send(ZunoMessage message) async {
    if (message.isExpired) {
      return TransportSendOutcome.rejected;
    }

    try {
      final result = await _channel.invokeMethod<String>(
        'sendMessage',
        <String, Object?>{
          'id': message.id,
          'senderId': message.senderId,
          'recipientId': message.recipientId,
          'encryptedPayload': message.payload,
          'createdAt': message.createdAt.toUtc().toIso8601String(),
          'expiresAt': message.expiresAt?.toUtc().toIso8601String(),
        },
      );

      switch (result) {
        case 'recipientAcknowledged':
          return TransportSendOutcome.recipientAcknowledged;
        case 'acceptedForRouting':
          return TransportSendOutcome.acceptedForRouting;
        case 'temporarilyUnavailable':
        case null:
          return TransportSendOutcome.temporarilyUnavailable;
        case 'rejected':
        default:
          return TransportSendOutcome.rejected;
      }
    } on MissingPluginException {
      return TransportSendOutcome.temporarilyUnavailable;
    } on PlatformException {
      return TransportSendOutcome.temporarilyUnavailable;
    }
  }
}
