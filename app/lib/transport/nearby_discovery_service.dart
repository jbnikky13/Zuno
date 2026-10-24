import 'dart:async';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';

/// A small BLE discovery layer. It discovers radio peripherals only; it does
/// not prove that a device is running Zuno or that it can exchange messages.
class NearbyDiscoveryService {
  NearbyDiscoveryService({CentralManager? central})
      : _central = central ?? CentralManager();

  final CentralManager _central;
  final Map<String, NearbyDevice> _devices = <String, NearbyDevice>{};
  final StreamController<List<NearbyDevice>> _devicesController =
      StreamController<List<NearbyDevice>>.broadcast();

  StreamSubscription<DiscoveredEventArgs>? _discoveredSubscription;
  bool _disposed = false;
  bool _scanning = false;

  Stream<List<NearbyDevice>> get devices => _devicesController.stream;
  bool get isScanning => _scanning;
  String get radioState => _central.state.toString();

  Future<void> startScanning() async {
    if (_disposed) {
      throw StateError('Nearby discovery service has been disposed.');
    }
    if (_scanning) return;

    final authorized = await _central.authorize();
    if (!authorized) {
      throw StateError('Bluetooth permission was not granted.');
    }

    _discoveredSubscription ??= _central.discovered.listen((event) {
      final id = event.peripheral.uuid.toString();
      final name = event.advertisement.name?.trim();
      _devices[id] = NearbyDevice(
        id: id,
        name: name == null || name.isEmpty ? 'Unnamed Bluetooth device' : name,
        rssi: event.rssi,
      );
      _publish();
    });

    await _central.startDiscovery();
    _scanning = true;
  }

  Future<void> stopScanning() async {
    if (!_scanning) return;
    await _central.stopDiscovery();
    _scanning = false;
  }

  void _publish() {
    if (!_devicesController.isClosed) {
      _devicesController.add(
        List<NearbyDevice>.unmodifiable(_devices.values.toList()
          ..sort((a, b) => b.rssi.compareTo(a.rssi))),
      );
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    if (_scanning) {
      try {
        await _central.stopDiscovery();
      } catch (_) {
        // Disposal should still release the Dart subscriptions.
      }
    }
    _scanning = false;
    await _discoveredSubscription?.cancel();
    await _devicesController.close();
  }
}

class NearbyDevice {
  const NearbyDevice({
    required this.id,
    required this.name,
    required this.rssi,
  });

  final String id;
  final String name;
  final int rssi;
}
