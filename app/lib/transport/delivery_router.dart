import '../models/zuno_message.dart';
import 'transport_adapter.dart';

/// Selects an available route without pretending that selection sends a message.
///
/// Nearby is preferred by default to preserve offline-first behavior. If it is
/// unavailable, an internet adapter can be selected for international delivery.
class DeliveryRouter {
  const DeliveryRouter();

  Future<ZunoTransportAdapter?> selectRoute({
    required Iterable<ZunoTransportAdapter> adapters,
    bool preferNearby = true,
  }) async {
    final candidates = adapters.toList()
      ..sort((a, b) => _priority(a.kind, preferNearby)
          .compareTo(_priority(b.kind, preferNearby)));

    for (final adapter in candidates) {
      if (await adapter.checkAvailability() ==
          TransportAvailability.available) {
        return adapter;
      }
    }

    return null;
  }

  int _priority(MessageTransport kind, bool preferNearby) {
    if (preferNearby) {
      return kind == MessageTransport.nearby ? 0 : 1;
    }
    return kind == MessageTransport.internet ? 0 : 1;
  }
}
