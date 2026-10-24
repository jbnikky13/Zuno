import 'package:flutter_test/flutter_test.dart';
import 'package:zuno/models/zuno_message.dart';
import 'package:zuno/transport/delivery_router.dart';
import 'package:zuno/transport/transport_adapter.dart';

class FakeTransport implements ZunoTransportAdapter {
  FakeTransport(this.kind, this.availability);

  @override
  final MessageTransport kind;

  final TransportAvailability availability;

  @override
  Future<TransportAvailability> checkAvailability() async => availability;

  @override
  Future<TransportSendOutcome> send(ZunoMessage message) async =>
      TransportSendOutcome.acceptedForRouting;
}

void main() {
  const router = DeliveryRouter();

  test('prefers nearby when both routes are available', () async {
    final nearby = FakeTransport(
      MessageTransport.nearby,
      TransportAvailability.available,
    );
    final internet = FakeTransport(
      MessageTransport.internet,
      TransportAvailability.available,
    );

    final selected = await router.selectRoute(
      adapters: [internet, nearby],
    );

    expect(selected, same(nearby));
  });

  test('falls back to internet when nearby is unavailable', () async {
    final nearby = FakeTransport(
      MessageTransport.nearby,
      TransportAvailability.unavailable,
    );
    final internet = FakeTransport(
      MessageTransport.internet,
      TransportAvailability.available,
    );

    final selected = await router.selectRoute(
      adapters: [nearby, internet],
    );

    expect(selected, same(internet));
  });

  test('returns no route when both transports are unavailable', () async {
    final selected = await router.selectRoute(
      adapters: [
        FakeTransport(
          MessageTransport.nearby,
          TransportAvailability.unavailable,
        ),
        FakeTransport(
          MessageTransport.internet,
          TransportAvailability.unavailable,
        ),
      ],
    );

    expect(selected, isNull);
  });

  test('can prefer internet when explicitly requested', () async {
    final nearby = FakeTransport(
      MessageTransport.nearby,
      TransportAvailability.available,
    );
    final internet = FakeTransport(
      MessageTransport.internet,
      TransportAvailability.available,
    );

    final selected = await router.selectRoute(
      adapters: [nearby, internet],
      preferNearby: false,
    );

    expect(selected, same(internet));
  });
}
