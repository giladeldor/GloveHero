import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'ble.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Permission.bluetoothScan.request();
  await Permission.bluetoothConnect.request();

  final bleModel = BleModel();

  runApp(
    ChangeNotifierProvider(
      create: (context) => bleModel,
      child: const GloveHeroApp(),
    ),
  );
}

class GloveHeroApp extends StatelessWidget {
  const GloveHeroApp({super.key});

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
            case BleConnectionState.disconnected:
              body = const DisconnectedScreen();
              break;
            case BleConnectionState.connecting:
              body = const ConnectingScreen();
              break;
            case BleConnectionState.connected:
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
      case BleConnectionState.disconnected:
        onPressed = bleModel.connect;
        icon = Icons.bluetooth;
        break;
      case BleConnectionState.connecting:
        icon = Icons.bluetooth_connected;
        break;
      case BleConnectionState.connected:
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
              ElevatedButton(
                onPressed: () {},
                child: const Text("Disco"),
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
