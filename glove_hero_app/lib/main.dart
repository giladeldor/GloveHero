import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glove_hero_app/models/song.dart';
import 'package:glove_hero_app/pages/recording_mode_page.dart';
import 'package:glove_hero_app/pages/single_player_mode_page.dart';
import 'package:provider/provider.dart';
import 'models/ble.dart';
import 'pages/menu_page.dart';

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
      home: SafeArea(
        // child: MenuPage(),
        // child: RecordingModePage(song: SongManager.songs[11]),
        child: SinglePlayerModePage(song: SongManager.songs[11]),
      ),
    );
  }
}
