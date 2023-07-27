import 'package:flutter/widgets.dart';
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
