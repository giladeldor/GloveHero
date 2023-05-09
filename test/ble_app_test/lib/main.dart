import 'dart:async';
import 'dart:convert';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Permission.bluetoothScan.request();
  await Permission.bluetoothConnect.request();

  final bleModel = BleModel();

  runApp(
    ChangeNotifierProvider(
      create: (context) => bleModel,
      child: const BleApp(),
    ),
  );
}

class BleApp extends StatelessWidget {
  const BleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Consumer<BleModel>(
        builder: (context, bleModel, child) {
          late Widget body;
          switch (bleModel.connectionState) {
            case ConnectionState.disconnected:
              body = const DisconnectedScreen();
              break;
            case ConnectionState.connecting:
              body = const ConnectingScreen();
              break;
            case ConnectionState.connected:
              body = const ConnectedScreen();
              break;
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text("BLE Test"),
            ),
            backgroundColor: Colors.white,
            body: body,
            floatingActionButton: _getFab(bleModel),
          );
        },
      );

  Widget _getFab(BleModel bleModel) {
    void Function()? onPressed;
    late IconData icon;

    switch (bleModel.connectionState) {
      case ConnectionState.disconnected:
        onPressed = bleModel.connect;
        icon = Icons.bluetooth;
        break;
      case ConnectionState.connecting:
        icon = Icons.bluetooth_connected;
        break;
      case ConnectionState.connected:
        icon = Icons.bluetooth_disabled;
        onPressed = bleModel.disconnect;
        break;
      default:
    }

    return FloatingActionButton(
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}

class DisconnectedScreen extends StatelessWidget {
  const DisconnectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.center,
      child: Text(
        "Connect to continue",
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      ),
    );
  }
}

class ConnectingScreen extends StatelessWidget {
  const ConnectingScreen({super.key});

  @override
  Widget build(BuildContext context) => SpinKitFoldingCube(
        color: Theme.of(context).colorScheme.primaryContainer,
      );
}

class ConnectedScreen extends StatelessWidget {
  const ConnectedScreen({super.key});

  @override
  Widget build(BuildContext context) => Consumer<BleModel>(
        builder: (context, bleModel, child) {
          final text = "Value:    ${bleModel.idxValue}";

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ColorPicker(
                color: bleModel.color,
                onColorChanged: (value) => bleModel.color = value,
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              )
            ],
          );
        },
      );
}

enum ConnectionState {
  disconnected,
  connecting,
  connected,
}

class BleModel extends ChangeNotifier {
  static final Uuid _serviceUuid =
      Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
  static final Uuid _touchCharacteristicUuid =
      Uuid.parse("beb5483e-36e1-4688-b7f5-ea07361b26a8");
  static final Uuid _colorCharacteristicUuid =
      Uuid.parse("86c7baf6-9d1f-4004-85aa-70aa37e18055");

  final _ble = FlutterReactiveBle();

  StreamSubscription<ConnectionStateUpdate>? _connectionStream;

  ConnectionState __connectionState = ConnectionState.disconnected;
  ConnectionState get connectionState => __connectionState;

  set _connectionState(ConnectionState state) {
    if (state == __connectionState) {
      return;
    }

    __connectionState = state;
    notifyListeners();
  }

  QualifiedCharacteristic? _touchCharacteristic;
  String __touchValue = "";

  String get idxValue => __touchValue;

  set _touchValue(String value) {
    if (value == __touchValue) {
      return;
    }

    __touchValue = value;
    notifyListeners();
  }

  QualifiedCharacteristic? _colorCharacteristic;
  Color? _color;

  Color get color => _color!;

  set color(Color value) {
    _color = value;
    _ble.writeCharacteristicWithResponse(
      _colorCharacteristic!,
      value: [color.red, color.green, color.blue],
    );
    notifyListeners();
  }

  Future<Color> _getColorValue() async {
    final value = await _ble.readCharacteristic(_colorCharacteristic!);
    return Color.fromARGB(
      255,
      value[0],
      value[1],
      value[2],
    );
  }

  void connect() async {
    _connectionState = ConnectionState.connecting;
    await for (final device in _ble.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    )) {
      if (device.name != "GloveHero") {
        continue;
      }

      _connectionStream =
          _ble.connectToDevice(id: device.id).listen((event) async {
        switch (event.connectionState) {
          case DeviceConnectionState.connected:
            assert(event.deviceId == device.id);

            _touchCharacteristic = QualifiedCharacteristic(
              characteristicId: _touchCharacteristicUuid,
              serviceId: _serviceUuid,
              deviceId: event.deviceId,
            );
            _colorCharacteristic = QualifiedCharacteristic(
              characteristicId: _colorCharacteristicUuid,
              serviceId: _serviceUuid,
              deviceId: event.deviceId,
            );

            _ble.subscribeToCharacteristic(_touchCharacteristic!).listen(
              (data) {
                _touchValue = utf8.decode(data);
              },
            );

            final s = await _ble.readCharacteristic(_touchCharacteristic!);
            _color = await _getColorValue();
            _connectionState = ConnectionState.connected;
            break;

          default:
        }
      });
      break;
    }
  }

  void disconnect() async {
    await _connectionStream?.cancel();
    _connectionState = ConnectionState.disconnected;
    _touchValue = "";
  }

  @override
  void dispose() {
    super.dispose();
    _connectionStream?.cancel();
  }
}
