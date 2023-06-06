import 'package:flutter/material.dart';
import 'package:glove_hero_app/models/audio_manager.dart';
import 'package:glove_hero_app/models/ble.dart';
import 'package:glove_hero_app/models/touch.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';

class RecordingModePage extends StatefulWidget {
  const RecordingModePage({super.key, required this.song});
  final Song song;
  @override
  State<RecordingModePage> createState() => _RecordingModePageState();
}

class _RecordingModePageState extends State<RecordingModePage>
    with WidgetsBindingObserver {
  _RecordingModePageState() {
    _song = widget.song;
  }

  late Song _song;
  late BleInput _input;
  List<Touch> touchList = [];

  @override
  Future<void> initState() async {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _input = context.read<BleInput>();
      _input.addPressListener(_handleInput);
    });
    await Future.delayed(const Duration(seconds: 2));
    AudioManager.playSong(_song);
  }

  void _handleInput(Input input) {
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) {
      return;
    }

    // TODO: activate LEDs
    if (input == Input.none) {
      final touch = TouchClassifier.release(AudioManager.position);
      if (touch == null) return;
      touchList.add(touch);
    } else {
      TouchClassifier.press(input, AudioManager.position);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }

  @override
  void dispose() {
    super.dispose();

    _input.removeTouchListener(_handleInput);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        AudioManager.pauseSong();
        break;
      case AppLifecycleState.resumed:
        // audioManager.player.play();
        break;
      default:
        break;
    }
  }
}

class TouchClassifier {
  static const int minDuration = 300;
  static Input lastInput = Input.none;
  static int timeStamp = -1;

  static void press(Input input, int timeStamp) {
    if (input == Input.none) return;

    lastInput = input;
    TouchClassifier.timeStamp = timeStamp;
  }

  static Touch? release(int timeStamp) {
    if (lastInput == Input.none) return null;

    int elapsed = timeStamp - TouchClassifier.timeStamp;
    if (elapsed < 0) return null;

    return switch (elapsed > minDuration) {
      true => Touch.long(
          timeStamp: TouchClassifier.timeStamp,
          duration: elapsed,
        ),
      false => Touch.regular(timeStamp: TouchClassifier.timeStamp),
    };
  }
}
