import 'dart:async';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';

/// BLE discovery and advertising for the first Zuno presence proof of concept.
///
/// Advertisements contain only a public service UUID and the short app name.
/// They must never contain message content or personal identity information.
class NearbyDiscoveryService {
  NearbyDiscoveryService({CentralManager? central, PeripheralManager? peripheral})
      : _central = central ?? CentralManager(),
        _peripheral = peripheral ?? PeripheralManager();

  static final UUID serviceUuid =
      UUID.fromString('7b8e6d10-9a32-4c57-8f61-2d8e3a0c5f71');

  final CentralManager _central;
  final PeripheralManager _peripheral;
  final Map<String, NearbyDevice> _devices = <String, NearbyDevice>{};
  final StreamController<List<NearbyDevice>> _devicesController =
      StreamController<List<NearbyDevice>>.broadcast();

  StreamSubscription<DiscoveredEventArgs>? _discoveredSubscription;
  bool _disposed = false;
  bool _scanning = false;
  bool _advertising = false;

  Stream<List<NearbyDevice>> get devices => _devicesController.stream;
  bool get isScanning => _scanning;
  bool get isAdvertising => _advertising;

  Future<void> startScanning() async {
    _ensureNotDisposed();
    if (_scanning) return;

    final authorized = await _central.authorize();
    if (!authorized) {
      throw StateError('Bluetooth permission was not granted for scanning.');
    }

    _discoveredSubscription ??= _central.discovered.listen((event) {
      final id = event.peripheral.uuid.toString();
      final name = event.advertisement.name?.trim();
      _devices[id] = NearbyDevice(
        id: id,
        name: name == null || name.isEmpty ? 'Nearby Zuno device' : name,
        rssi: event.rssi,
      );
      _publish();
    });

    await _central.startDiscovery(serviceUUIDs: <UUID>[serviceUuid]);
    _scanning = true;
  }

  Future<void> stopScanning() async {
    if (!_scanning) return;
    await _central.stopDiscovery();
    _scanning = false;
  }

  Future<void> startAdvertising() async {
    _ensureNotDisposed();
    if (_advertising) return;

    final authorized = await _peripheral.authorize();
    if (!authorized) {
      throw StateError('Bluetooth permission was not granted for advertising.');
    }

    await _peripheral.startAdvertising(
      Advertisement(name: 'Zuno', serviceUUIDs: <UUID>[serviceUuid]),
    );
    _advertising = true;
  }

  Future<void> stopAdvertising() async {
    if (!_advertising) return;
    await _peripheral.stopAdvertising();
    _advertising = false;
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('Nearby discovery service has been disposed.');
    }
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
    if (_advertising) {
      try {
        await _peripheral.stopAdvertising();
      } catch (_) {
        // Disposal should still release the Dart subscriptions.
      }
    }
    _scanning = false;
    _advertising = false;
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
