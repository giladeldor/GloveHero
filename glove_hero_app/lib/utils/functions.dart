import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import '../models/audio_manager.dart';

/// The default onLifeCycleChange function that pauses and resumes the audio as needed.
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

/// Get the local documents directory for the app.
Future<String> get localDir async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}
