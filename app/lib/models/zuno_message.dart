enum MessageStatus {
  draft,
  queued,
  sending,
  relayed,
  delivered,
  read,
  expired,
  failed,
}

enum MessageTransport {
  nearby,
  internet,
}

class ZunoMessage {
  const ZunoMessage({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.payload,
    required this.createdAt,
    required this.status,
    this.transport,
    this.expiresAt,
  });

  final String id;
  final String senderId;
  final String recipientId;

  /// Opaque payload. Production code must store an end-to-end encrypted envelope,
  /// never plaintext private message content, in this field.
  final String payload;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final MessageStatus status;
  final MessageTransport? transport;

  bool get isTerminal =>
      status == MessageStatus.read ||
      status == MessageStatus.expired ||
      status == MessageStatus.failed;

  bool get isExpired =>
      expiresAt != null && !DateTime.now().isBefore(expiresAt!);

  ZunoMessage transitionTo(
    MessageStatus next, {
    MessageTransport? via,
  }) {
    if (!_allowedTransitions[status]!.contains(next)) {
      throw StateError('Invalid message status transition: $status -> $next');
    }

    if (next == MessageStatus.sending && via == null && transport == null) {
      throw ArgumentError('A transport is required when sending a message.');
    }

    if (isExpired && next != MessageStatus.expired) {
      throw StateError('An expired message cannot advance to $next.');
    }

    return ZunoMessage(
      id: id,
      senderId: senderId,
      recipientId: recipientId,
      payload: payload,
      createdAt: createdAt,
      expiresAt: expiresAt,
      status: next,
      transport: via ?? transport,
    );
  }

  static const Map<MessageStatus, Set<MessageStatus>> _allowedTransitions = {
    MessageStatus.draft: {MessageStatus.queued, MessageStatus.failed},
    MessageStatus.queued: {
      MessageStatus.sending,
      MessageStatus.expired,
      MessageStatus.failed,
    },
    MessageStatus.sending: {
      MessageStatus.queued,
      MessageStatus.relayed,
      MessageStatus.delivered,
      MessageStatus.expired,
      MessageStatus.failed,
    },
    MessageStatus.relayed: {
      MessageStatus.delivered,
      MessageStatus.expired,
      MessageStatus.failed,
    },
    MessageStatus.delivered: {
      MessageStatus.read,
      MessageStatus.expired,
    },
    MessageStatus.read: {},
    MessageStatus.expired: {},
    MessageStatus.failed: {},
  };
}
