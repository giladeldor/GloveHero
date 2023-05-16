import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:glove_hero_app/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'ble.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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
            backgroundColor: Colors.white,
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/menu-background.jpeg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: const MenuScreen(),
            ),
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

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const buttonPadding = EdgeInsets.symmetric(vertical: 8, horizontal: 16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 36.0, bottom: 16.0),
          child: const Text(
            "Glove Hero",
            style: titleTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: buttonPadding,
          child: MenuButton(
            title: "Single Player",
            onPressed: () {},
            selected: true,
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: MenuButton(
            title: "Multiplayer",
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: MenuButton(
            title: "Recording Mode",
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: MenuButton(
            title: "Leaderboard",
            onPressed: () {},
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: MenuButton(
            title: "Statistics",
          ),
        ),
      ],
    );
  }
}

class MenuButton extends StatelessWidget {
  const MenuButton({
    super.key,
    required this.title,
    this.onPressed,
    this.selected = false,
  });

  final String title;
  final void Function()? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = onPressed == null
        ? Colors.grey
        : const Color.fromARGB(255, 242, 255, 235);

    final label = FittedBox(
      child: Text(
        title,
        style: titleTextStyle.copyWith(
          fontSize: 25,
          color: color,
        ),
      ),
    );

    return selected
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: ImageIcon(
              AssetImage("assets/hand-selector.png"),
              size: 30,
              color: color,
            ),
            label: label,
          )
        : OutlinedButton(
            onPressed: onPressed,
            child: label,
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
