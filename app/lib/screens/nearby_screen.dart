import 'dart:async';

import 'package:flutter/material.dart';

import '../transport/nearby_discovery_service.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  NearbyDiscoveryService? _discovery;
  StreamSubscription<List<NearbyDevice>>? _devicesSubscription;
  List<NearbyDevice> _devices = const <NearbyDevice>[];
  bool _scanning = false;
  bool _advertising = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _toggleScanning() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_scanning) {
        await _discovery?.stopScanning();
        if (mounted) setState(() => _scanning = false);
      } else {
        _discovery ??= NearbyDiscoveryService();
        _devicesSubscription ??= _discovery!.devices.listen((devices) {
          if (mounted) setState(() => _devices = devices);
        });
        await _discovery!.startScanning();
        if (mounted) setState(() => _scanning = true);
      }
    } catch (error) {
      if (mounted) setState(() => _error = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleAdvertising() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      _discovery ??= NearbyDiscoveryService();
      _devicesSubscription ??= _discovery!.devices.listen((devices) {
        if (mounted) setState(() => _devices = devices);
      });
      if (_advertising) {
        await _discovery!.stopAdvertising();
        if (mounted) setState(() => _advertising = false);
      } else {
        await _discovery!.startAdvertising();
        if (mounted) setState(() => _advertising = true);
      }
    } catch (error) {
      if (mounted) setState(() => _error = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _friendlyError(Object error) {
    if (error.toString().contains('permission')) {
      return 'Bluetooth permission is needed to scan. Check your device settings and try again.';
    }
    return 'Bluetooth scanning could not start. Check that Bluetooth is on and try again.';
  }

  @override
  void dispose() {
    _devicesSubscription?.cancel();
    final discovery = _discovery;
    if (discovery != null) unawaited(discovery.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Nearby',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Scan for Bluetooth Low Energy devices nearby. Scanning works without mobile data.',
          style: TextStyle(fontSize: 15, height: 1.4),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3D9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF0D9A4)),
          ),
          child: const Text(
            'Early proof of concept: this broadcasts a public Zuno service UUID and scans for that service. Messaging, peer verification, and file transfer are not connected.',
            style: TextStyle(color: Color(0xFF604A1D), height: 1.4),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _busy ? null : _toggleScanning,
          icon: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(_scanning ? Icons.stop_rounded : Icons.radar_rounded),
          label: Text(
            _busy
                ? 'Please wait…'
                : _scanning
                    ? 'Stop scanning'
                    : 'Scan for Zuno devices',
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _busy ? null : _toggleAdvertising,
          icon: Icon(
            _advertising ? Icons.stop_circle_outlined : Icons.bluetooth_audio,
          ),
          label: Text(
            _advertising ? 'Stop making this phone discoverable' : 'Make this phone discoverable',
          ),
        ),
        if (_advertising)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Zuno presence is being broadcast publicly over Bluetooth. No messages or personal IDs are included.',
              style: TextStyle(fontSize: 12, color: Color(0xFF69736E)),
            ),
          ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Discovered devices',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            Text('${_devices.length}'),
          ],
        ),
        const SizedBox(height: 8),
        if (_devices.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Text(
              'No devices found yet. Start scanning and keep another Bluetooth device nearby.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF69736E), height: 1.4),
            ),
          )
        else
          ..._devices.map(
            (device) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.bluetooth_rounded),
                ),
                title: Text(device.name),
                subtitle: Text('Signal ${device.rssi} dBm'),
                trailing: const Icon(Icons.radio_button_unchecked_rounded),
              ),
            ),
          ),
      ],
    );
  }
}
