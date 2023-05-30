import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'models/ble.dart';
import 'pages/menu_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Permission.bluetoothScan.request();
  await Permission.bluetoothConnect.request();

  final bleModel = BleModel();
  // TODO: Create a system for connecting / disconnecting and handling failures.
  bleModel.connect();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: bleModel),
        // Provider.value(value: bleModel.input),
        // Provider.value(value: bleModel.connection),
        ChangeNotifierProvider(create: (context) => bleModel.connection),
        ChangeNotifierProvider(create: (context) => bleModel.input),
      ],
      child: const GloveHeroApp(),
    ),
  );
}

class GloveHeroApp extends StatelessWidget {
  const GloveHeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glove Hero',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SafeArea(
        child: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // return Consumer<BleModel>(
    //     builder: (context, bleModel, child) {
    // late Widget body;
    // switch (bleModel.connectionState) {
    //   case BleConnectionState.disconnected:
    //     body = const DisconnectedScreen();
    //     break;
    //   case BleConnectionState.connecting:
    //     body = const ConnectingScreen();
    //     break;
    //   case BleConnectionState.connected:
    //     body = const ConnectedScreen();
    //     break;
    // }

    return const MenuPage();
    // },
    // );
  }
}
