import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../models/audio_manager.dart';
import '../models/ble.dart';
import '../models/touch.dart';
import '../widgets/countdown.dart';
import '../widgets/save_recording_dialog.dart';
import '../widgets/glove_controls.dart';
import '../widgets/song_card.dart';
import '../utils/functions.dart';
import '../utils/painter.dart';

class RecordingModePage extends StatefulWidget {
  const RecordingModePage({super.key, required this.song});
  final Song song;

  @override
  State<RecordingModePage> createState() => _RecordingModePageState();
}

class _RecordingModePageState extends State<RecordingModePage> {
  final SongTouches _songTouches = SongTouches();
  StreamSubscription<PlayerState>? _onSongEndSubscription;
  var _isVisible = true;

  void endSong() {
    _onSongEndSubscription?.cancel();
    showDialog(
      context: context,
      builder: (BuildContext context) => SaveRecordingDialog(
        song: widget.song,
        songTouches: _songTouches,
      ),
    ).then((value) => Navigator.of(context)
      ..maybePop()
      ..maybePop());
  }

  void _onPress(Input input) {
    if (context.mounted && !(ModalRoute.of(context)?.isCurrent ?? true)) {
      return;
    }
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
    return GloveControls(
      onPress: _onPress,
      onLifecycleChange: audioOnLifecycleChange,
      onPop: () => _onSongEndSubscription?.cancel(),
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
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SongCard(
                        songName: widget.song.title,
                        songArtPath: widget.song.artAsset,
                      ),
                    ),
                  ),
                  _isVisible
                      ? Flexible(
                          flex: 1,
                          child: CountDown(
                            onComplete: () {
                              setState(() {
                                _isVisible = false;
                              });
                              AudioManager.playSong(widget.song);
                              _onSongEndSubscription = AudioManager.onSongEnd(
                                endSong,
                              );
                            },
                          ),
                        )
                      : const Spacer(flex: 1),
                  const Spacer(flex: 1)
                ],
              ),
            ),
          ]),
        ),
      ),
    );
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
          input: lastInput,
          timeStamp: _TouchClassifier.timeStamp,
          duration: elapsed,
        ),
      false => Touch.regular(
          input: lastInput,
          timeStamp: _TouchClassifier.timeStamp,
        ),
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
