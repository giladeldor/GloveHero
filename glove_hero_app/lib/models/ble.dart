import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

enum BleConnectionState {
  disconnected,
  connecting,
  connected,
}

enum BleState {
  on,
  bluetoothPermissionDenied,
  bluetoothDisabled,
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

  factory Input.fromIdx(int idx) => switch (idx) {
        0 => Input.input1,
        1 => Input.input2,
        2 => Input.input3,
        3 => Input.input4,
        _ => Input.none
      };

  int get idx => switch (this) {
        Input.none => -1,
        Input.input1 => 0,
        Input.input2 => 1,
        Input.input3 => 2,
        Input.input4 => 3
      };
}

class BleModel {
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

  QualifiedCharacteristic? _touchCharacteristic;

  QualifiedCharacteristic? _pinkyLedCharacteristic;
  QualifiedCharacteristic? _ringLedCharacteristic;
  QualifiedCharacteristic? _middleLedCharacteristic;
  QualifiedCharacteristic? _indexLedCharacteristic;

  Color? _pinkyColor;
  Color get pinkyColor => _pinkyColor!;
  set pinkyColor(Color value) {
    _pinkyColor = value;
    _ble.writeCharacteristicWithResponse(
      _pinkyLedCharacteristic!,
      value: [pinkyColor.red, pinkyColor.green, pinkyColor.blue],
    );
  }

  Color? _ringColor;
  Color get ringColor => _ringColor!;
  set ringColor(Color value) {
    _ringColor = value;
    _ble.writeCharacteristicWithResponse(
      _ringLedCharacteristic!,
      value: [ringColor.red, ringColor.green, ringColor.blue],
    );
  }

  Color? _middleColor;
  Color get middleColor => _middleColor!;
  set middleColor(Color value) {
    _middleColor = value;
    _ble.writeCharacteristicWithResponse(
      _middleLedCharacteristic!,
      value: [middleColor.red, middleColor.green, middleColor.blue],
    );
  }

  Color? _indexColor;
  Color get indexColor => _indexColor!;
  set indexColor(Color value) {
    _indexColor = value;
    _ble.writeCharacteristicWithResponse(
      _indexLedCharacteristic!,
      value: [indexColor.red, indexColor.green, indexColor.blue],
    );
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

  Future<bool> _requestBluetoothPermission() async {
    final bluetoothScanPermission = await Permission.bluetoothScan.request();
    final bluetoothConnectPermission =
        await Permission.bluetoothConnect.request();

    return bluetoothScanPermission.isGranted &&
        bluetoothConnectPermission.isGranted;
  }

  final BleConnection connection = BleConnection();
  final BleInput input = BleInput();
  Future<BleState> get state async {
    if (!await _requestBluetoothPermission()) {
      return BleState.bluetoothPermissionDenied;
    }

    final status = await _ble.statusStream
        .where((status) => status != BleStatus.unknown)
        .first;
    if (status != BleStatus.ready) {
      return BleState.bluetoothDisabled;
    }

    return BleState.on;
  }

  Future<void> connect() async {
    if (await state != BleState.on ||
        connection.state != BleConnectionState.disconnected) {
      return;
    }

    connection.state = BleConnectionState.connecting;
    await for (final device in _ble.scanForDevices(
      withServices: [_serviceUuid],
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
                input._value = Input.fromIdx(data.first);
              },
            );

            await _ble.readCharacteristic(_touchCharacteristic!);
            _pinkyColor = await _getColorValue(_pinkyLedCharacteristic);
            _ringColor = await _getColorValue(_ringLedCharacteristic);
            _middleColor = await _getColorValue(_middleLedCharacteristic);
            _indexColor = await _getColorValue(_indexLedCharacteristic);

            connection.state = BleConnectionState.connected;
            break;

          default:
        }
      });
      break;
    }
  }

  Future<void> disconnect() async {
    await _connectionStream?.cancel();
    connection.state = BleConnectionState.disconnected;
    input._value = Input.none;
  }

  void dispose() {
    _connectionStream?.cancel();
  }
}

class BleConnection extends ChangeNotifier {
  BleConnectionState _state = BleConnectionState.disconnected;

  BleConnectionState get state => _state;

  set state(BleConnectionState value) {
    if (value == _state) {
      return;
    }

    _state = value;
    notifyListeners();
  }
}

class BleInput extends ChangeNotifier {
  Input __value = Input.none;

  Input get value => __value;

  final Map<void Function(Input), void Function()> _touchListeners = {};
  final Map<void Function(Input), void Function()> _pressListeners = {};

  set _value(Input value) {
    if (value == __value) {
      return;
    }

    __value = value;
    notifyListeners();
  }

  void addPressListener(void Function(Input input) callback) {
    listener() {
      callback(value);
    }

    _pressListeners[callback] = listener;
    super.addListener(listener);
  }

  void removePressListener(void Function(Input) callback) {
    final listener = _pressListeners.remove(callback);
    if (listener == null) return;
    removeListener(listener);
  }

  void addTouchListener(void Function(Input input) callback) {
    listener() {
      if (value == Input.none) return;
      callback(value);
    }

    _touchListeners[callback] = listener;
    super.addListener(listener);
  }

  void removeTouchListener(void Function(Input) callback) {
    final listener = _touchListeners.remove(callback);
    if (listener == null) return;
    removeListener(listener);
  }
}
