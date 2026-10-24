import 'package:flutter_test/flutter_test.dart';
import 'package:zuno/models/zuno_message.dart';

void main() {
  final createdAt = DateTime.utc(2026, 1, 1);

  ZunoMessage message({
    MessageStatus status = MessageStatus.draft,
    DateTime? expiresAt,
    MessageTransport? transport,
  }) {
    return ZunoMessage(
      id: 'msg-1',
      senderId: 'zuno-sender',
      recipientId: 'zuno-recipient',
      payload: 'encrypted-envelope',
      createdAt: createdAt,
      expiresAt: expiresAt,
      status: status,
      transport: transport,
    );
  }

  test('queued message can be sent using the nearby transport', () {
    final queued = message().transitionTo(MessageStatus.queued);
    final sending = queued.transitionTo(
      MessageStatus.sending,
      via: MessageTransport.nearby,
    );

    expect(sending.status, MessageStatus.sending);
    expect(sending.transport, MessageTransport.nearby);
    expect(sending.id, 'msg-1');
  });

  test('international relay is not the same as recipient delivery', () {
    final relayed = message()
        .transitionTo(MessageStatus.queued)
        .transitionTo(
          MessageStatus.sending,
          via: MessageTransport.internet,
        )
        .transitionTo(MessageStatus.relayed);

    expect(relayed.status, MessageStatus.relayed);
    expect(relayed.status, isNot(MessageStatus.delivered));

    final delivered = relayed.transitionTo(MessageStatus.delivered);
    expect(delivered.status, MessageStatus.delivered);
  });

  test('sending requires a selected transport', () {
    final queued = message().transitionTo(MessageStatus.queued);

    expect(
      () => queued.transitionTo(MessageStatus.sending),
      throwsArgumentError,
    );
  });

  test('invalid transitions are rejected', () {
    expect(
      () => message().transitionTo(MessageStatus.delivered),
      throwsStateError,
    );
  });

  test('a failed message is terminal', () {
    final failed = message().transitionTo(MessageStatus.failed);

    expect(failed.isTerminal, isTrue);
    expect(
      () => failed.transitionTo(MessageStatus.queued),
      throwsStateError,
    );
  });

  test('expired messages cannot be sent', () {
    final expired = message(
      status: MessageStatus.queued,
      expiresAt: DateTime.utc(2020, 1, 1),
    );

    expect(expired.isExpired, isTrue);
    expect(
      () => expired.transitionTo(
        MessageStatus.sending,
        via: MessageTransport.internet,
      ),
      throwsStateError,
    );
  });
}
