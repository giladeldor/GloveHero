import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import '../models/audio_manager.dart';

audioOnLifecycleChange(state) {
  switch (state) {
    case AppLifecycleState.inactive:
    case AppLifecycleState.paused:
      AudioManager.pause();
      break;
    case AppLifecycleState.resumed:
      AudioManager.play();
      break;
    default:
      break;
  }
}

Future<String> get localDir async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}
