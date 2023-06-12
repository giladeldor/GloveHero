import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:glove_hero_app/models/audio_manager.dart';
import 'package:glove_hero_app/models/ble.dart';
import 'package:glove_hero_app/models/touch.dart';
import 'package:glove_hero_app/utils/painter.dart';
import 'package:glove_hero_app/widgets/song_card.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../utils/styles.dart';

class RecordingModePage extends StatefulWidget {
  const RecordingModePage({super.key, required this.song});
  final Song song;
  @override
  State<RecordingModePage> createState() => _RecordingModePageState();
}

class _RecordingModePageState extends State<RecordingModePage>
    with WidgetsBindingObserver {
  late Song _song;
  late BleInput _input;
  final SongTouches _songTouches = SongTouches();
  StreamSubscription<PlayerState>? _onSongEndSubscription;

  @override
  void initState() {
    super.initState();
    _song = widget.song;

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _input = context.read<BleInput>();
      _input.addPressListener(_handleInput);
    });

    Future.delayed(const Duration(seconds: 2)).then((_) async {
      AudioManager.playSong(_song);
      _onSongEndSubscription = AudioManager.onSongEnd(() async {
        final file = await _song.touchFile;
        await file.writeAsString(jsonEncode(_songTouches), flush: true);

        _onSongEndSubscription?.cancel();
      });
    });
  }

  void _handleInput(Input input) {
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) {
      return;
    }

    // TODO: activate LEDs
    if (input == Input.none) {
      final touch = _TouchClassifier.release(AudioManager.position);
      if (touch == null) return;

      _songTouches.addTouch(touch);
    } else {
      _TouchClassifier.press(input, AudioManager.position);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _onSongEndSubscription?.cancel();
        AudioManager.stopSong();

        return Future.value(true);
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: AssetImage("assets/recording-mode-background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(children: [
            Consumer<BleInput>(
              builder: (context, input, child) {
                return CustomPaint(
                  painter: _Painter(input: input.value),
                  child: Container(),
                );
              },
            ),
            Center(
              child: Column(
                children: [
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SongCard(
                          songName: _song.title, songArtPath: _song.artAsset),
                    ),
                  ),
                  const Spacer(flex: 1)
                ],
              ),
            ),
          ]),
        ),
      ),
    );
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

class _TouchClassifier {
  static const int minDuration = 300;
  static Input lastInput = Input.none;
  static int timeStamp = -1;

  static void press(Input input, int timeStamp) {
    if (input == Input.none) return;

    lastInput = input;
    _TouchClassifier.timeStamp = timeStamp;
  }

  static Touch? release(int timeStamp) {
    if (lastInput == Input.none) return null;

    int elapsed = timeStamp - _TouchClassifier.timeStamp;
    if (elapsed < 0) return null;

    return switch (elapsed > minDuration) {
      true => Touch.long(
          timeStamp: _TouchClassifier.timeStamp,
          duration: elapsed,
        ),
      false => Touch.regular(timeStamp: _TouchClassifier.timeStamp),
    };
  }
}

class _Painter extends PainterBase {
  final Input input;

  _Painter({required this.input});

  @override
  void paint(Canvas canvas, Size size) {
    paintInputCircles(
      canvas,
      size,
      activeInput: input,
    );
  }
}
