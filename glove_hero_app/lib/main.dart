import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/song.dart';
import 'models/ble.dart';
import 'pages/menu_page.dart';
import 'widgets/redirect_to_record_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final bleModel = BleModel();
  // TODO: Create a system for connecting / disconnecting and handling failures.
  bleModel.connect();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: bleModel),
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
        child: MenuPage(),
        // child: Test(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return RedirectToRecordDialog(song: SongManager.songs[0]);
  }
}
