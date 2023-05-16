import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

enum BleConnectionState {
  disconnected,
  connecting,
  connected,
}

enum Input {
  none,

  /// Pinky
  input1,

  /// Ring finger
  input2,

  /// Middle finger
  input3,

  /// Index finger
  input4;

  factory Input.fromIdx(int idx) {
    switch (idx) {
      case 1:
        return Input.input1;
      case 2:
        return Input.input2;
      case 3:
        return Input.input3;
      case 4:
        return Input.input4;
      default:
        return Input.none;
    }
  }

  int get idx {
    switch (this) {
      case Input.none:
        return 0;
      case Input.input1:
        return 1;
      case Input.input2:
        return 2;
      case Input.input3:
        return 3;
      case Input.input4:
        return 4;
    }
  }
}

class BleModel extends ChangeNotifier {
  static final Uuid _serviceUuid =
      Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
  static final Uuid _touchCharacteristicUuid =
      Uuid.parse("beb5483e-36e1-4688-b7f5-ea07361b26a8");
  static final Uuid _pinkyLedCharacteristicUuid =
      Uuid.parse("86c7baf6-9d1f-4004-85aa-70aa37e18055");
  static final Uuid _ringLedCharacteristicUuid =
      Uuid.parse("90e39454-d50d-4d86-9595-0e05bd709709");
  static final Uuid _middleLedCharacteristicUuid =
      Uuid.parse("9bcc732e-c684-42c8-8229-33ba787d7ba6");
  static final Uuid _indexLedCharacteristicUuid =
      Uuid.parse("e6297d4b-cfb8-4a9a-a650-3ce33b9cbef0");

  final _ble = FlutterReactiveBle();

  StreamSubscription<ConnectionStateUpdate>? _connectionStream;

  BleConnectionState __connectionState = BleConnectionState.disconnected;
  BleConnectionState get connectionState => __connectionState;

  set _connectionState(BleConnectionState state) {
    if (state == __connectionState) {
      return;
    }

    __connectionState = state;
    notifyListeners();
  }

  QualifiedCharacteristic? _touchCharacteristic;
  Input __touchValue = Input.none;

  Input get idxValue => __touchValue;

  set _touchValue(Input value) {
    if (value == __touchValue) {
      return;
    }

    __touchValue = value;
    notifyListeners();
  }

  QualifiedCharacteristic? _pinkyLedCharacteristic;
  Color? _pinkyColor;

  Color get pinkyColor => _pinkyColor!;

  set pinkyColor(Color value) {
    _pinkyColor = value;
    _ble.writeCharacteristicWithResponse(
      _pinkyLedCharacteristic!,
      value: [pinkyColor.red, pinkyColor.green, pinkyColor.blue],
    );
    notifyListeners();
  }

  QualifiedCharacteristic? _ringLedCharacteristic;
  Color? _ringColor;

  Color get ringColor => _ringColor!;

  set ringColor(Color value) {
    _ringColor = value;
    _ble.writeCharacteristicWithResponse(
      _ringLedCharacteristic!,
      value: [ringColor.red, ringColor.green, ringColor.blue],
    );
    notifyListeners();
  }

  QualifiedCharacteristic? _middleLedCharacteristic;
  Color? _middleColor;

  Color get middleColor => _middleColor!;

  set middleColor(Color value) {
    _middleColor = value;
    _ble.writeCharacteristicWithResponse(
      _middleLedCharacteristic!,
      value: [middleColor.red, middleColor.green, middleColor.blue],
    );
    notifyListeners();
  }

  QualifiedCharacteristic? _indexLedCharacteristic;
  Color? _indexColor;

  Color get indexColor => _indexColor!;

  set indexColor(Color value) {
    _indexColor = value;
    _ble.writeCharacteristicWithResponse(
      _indexLedCharacteristic!,
      value: [indexColor.red, indexColor.green, indexColor.blue],
    );
    notifyListeners();
  }

  Future<Color> _getColorValue(QualifiedCharacteristic? characteristic) async {
    final value = await _ble.readCharacteristic(characteristic!);
    return Color.fromARGB(
      255,
      value[0],
      value[1],
      value[2],
    );
  }

  void connect() async {
    _connectionState = BleConnectionState.connecting;
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
            _pinkyLedCharacteristic = QualifiedCharacteristic(
              characteristicId: _pinkyLedCharacteristicUuid,
              serviceId: _serviceUuid,
              deviceId: event.deviceId,
            );
            _ringLedCharacteristic = QualifiedCharacteristic(
              characteristicId: _ringLedCharacteristicUuid,
              serviceId: _serviceUuid,
              deviceId: event.deviceId,
            );
            _middleLedCharacteristic = QualifiedCharacteristic(
              characteristicId: _middleLedCharacteristicUuid,
              serviceId: _serviceUuid,
              deviceId: event.deviceId,
            );
            _indexLedCharacteristic = QualifiedCharacteristic(
              characteristicId: _indexLedCharacteristicUuid,
              serviceId: _serviceUuid,
              deviceId: event.deviceId,
            );

            _ble.subscribeToCharacteristic(_touchCharacteristic!).listen(
              (data) {
                _touchValue = Input.fromIdx(data.first);
              },
            );

            await _ble.readCharacteristic(_touchCharacteristic!);
            _pinkyColor = await _getColorValue(_pinkyLedCharacteristic);
            _ringColor = await _getColorValue(_ringLedCharacteristic);
            _middleColor = await _getColorValue(_middleLedCharacteristic);
            _indexColor = await _getColorValue(_indexLedCharacteristic);
            _connectionState = BleConnectionState.connected;
            break;

          default:
        }
      });
      break;
    }
  }

  void disconnect() async {
    await _connectionStream?.cancel();
    _connectionState = BleConnectionState.disconnected;
    _touchValue = Input.none;
  }

  @override
  void dispose() {
    super.dispose();
    _connectionStream?.cancel();
  }
}
