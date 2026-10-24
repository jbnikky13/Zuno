import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno/models/zuno_message.dart';
import 'package:zuno/transport/platform_channel_nearby_adapter.dart';
import 'package:zuno/transport/transport_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('zuno/test_nearby');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  PlatformChannelNearbyAdapter createAdapter() =>
      PlatformChannelNearbyAdapter(channel: channel);

  ZunoMessage message({DateTime? expiresAt}) => ZunoMessage(
        id: 'message-1',
        senderId: 'sender',
        recipientId: 'recipient',
        payload: 'encrypted-envelope',
        createdAt: DateTime.utc(2026, 1, 1),
        expiresAt: expiresAt,
        status: MessageStatus.queued,
      );

  test('reports unavailable when native handler is missing', () async {
    expect(
      await createAdapter().checkAvailability(),
      TransportAvailability.unavailable,
    );
  });

  test('reports native availability when handler says true', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'isAvailable');
      return true;
    });

    expect(
      await createAdapter().checkAvailability(),
      TransportAvailability.available,
    );
  });

  test('serializes an opaque encrypted envelope and maps routing result',
      () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'sendMessage');
      expect(call.arguments['encryptedPayload'], 'encrypted-envelope');
      expect(call.arguments['recipientId'], 'recipient');
      return 'acceptedForRouting';
    });

    expect(
      await createAdapter().send(message()),
      TransportSendOutcome.acceptedForRouting,
    );
  });

  test('keeps sends retryable when native handler is missing', () async {
    expect(
      await createAdapter().send(message()),
      TransportSendOutcome.temporarilyUnavailable,
    );
  });

  test('rejects expired messages without calling native code', () async {
    var called = false;
    messenger.setMockMethodCallHandler(channel, (call) async {
      called = true;
      return 'acceptedForRouting';
    });

    expect(
      await createAdapter().send(
        message(expiresAt: DateTime.utc(2020, 1, 1)),
      ),
      TransportSendOutcome.rejected,
    );
    expect(called, isFalse);
  });
}
