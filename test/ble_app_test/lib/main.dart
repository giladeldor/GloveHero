import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _foundDeviceWaitingToConnect = false;
  bool _scanStarted = false;
  bool _connected = false;

  late DiscoveredDevice _gloveDevice;
  final FlutterReactiveBle _reactiveBle = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> _scanStream;
  late QualifiedCharacteristic _characteristic;

  static final Uuid _serviceUuid =
      Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
  static final Uuid _characteristicUuid =
      Uuid.parse("beb5483e-36e1-4688-b7f5-ea07361b26a8");

  void _startScan() async {
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();

    setState(() {
      _scanStarted = true;
    });

    _scanStream = _reactiveBle.scanForDevices(
        withServices: [_serviceUuid], scanMode: ScanMode.lowLatency).listen(
      (device) {
        if (device.name == "GloveHero") {
          setState(() {
            _foundDeviceWaitingToConnect = true;
            _gloveDevice = device;
          });
        }
      },
      onError: (Object error) {
        print(error);
      },
    );
  }

  void _connectToDevice() {
    _scanStream.cancel();
    final connectionStream = _reactiveBle.connectToDevice(
      id: _gloveDevice.id,
      connectionTimeout: const Duration(seconds: 2),
    );
    connectionStream.listen((event) {
      switch (event.connectionState) {
        case DeviceConnectionState.connected:
          _characteristic = QualifiedCharacteristic(
            characteristicId: _characteristicUuid,
            serviceId: _serviceUuid,
            deviceId: event.deviceId,
          );

          setState(() {
            _foundDeviceWaitingToConnect = false;
            _connected = true;
          });
          break;

        case DeviceConnectionState.disconnected:
          print("Disconnected");
          break;

        default:
      }
    });
  }

  void _partyTime() async {
    if (_connected) {
      final value = await _reactiveBle.readCharacteristic(_characteristic);
      print(utf8.decode(value));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(),
      persistentFooterButtons: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: _scanStarted ? Colors.grey : Colors.blue,
            onPrimary: Colors.white,
          ),
          onPressed: _scanStarted ? () {} : _startScan,
          child: const Icon(Icons.search),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: _foundDeviceWaitingToConnect ? Colors.blue : Colors.grey,
            onPrimary: Colors.white,
          ),
          onPressed: _foundDeviceWaitingToConnect ? _connectToDevice : () {},
          child: const Icon(Icons.bluetooth),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: _connected ? Colors.blue : Colors.grey,
            onPrimary: Colors.white,
          ),
          onPressed: _connected ? _partyTime : () {},
          child: const Icon(Icons.celebration_rounded),
        ),
      ],
    );
  }
}
