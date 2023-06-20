import 'dart:async';
import 'dart:convert';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
  final int nothing;
  @override
  State<RecordingModePage> createState() => _RecordingModePageState();
}

class _RecordingModePageState extends State<RecordingModePage>
    with WidgetsBindingObserver {
  late Song _song;
  late BleInput _input;
  final SongTouches _songTouches = SongTouches();
  StreamSubscription<PlayerState>? _onSongEndSubscription;
  var _isVisible = true;

  @override
  void initState() {
    super.initState();
    _song = widget.song;

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _input = context.read<BleInput>();
      _input.addPressListener(_handleInput);
    });
  }

  void endSong() {
    _onSongEndSubscription?.cancel();
    showDialog(
      context: context,
      builder: (BuildContext context) => _Dialog(
        song: _song,
        songTouches: _songTouches,
      ),
    ).then((value) => Navigator.of(context)
      ..maybePop()
      ..maybePop());
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
        AudioManager.stop();

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
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SongCard(
                          songName: _song.title, songArtPath: _song.artAsset),
                    ),
                  ),
                  _isVisible
                      ? Flexible(
                          flex: 1,
                          child: _CountDown(
                            onComplete: () {
                              setState(() {
                                _isVisible = false;
                              });
                              AudioManager.playSong(_song);
                              _onSongEndSubscription = AudioManager.onSongEnd(
                                endSong,
                              );
                            },
                          ),
                        )
                      : const Spacer(
                          flex: 1,
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
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
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
}

class _Dialog extends StatelessWidget {
  const _Dialog({
    Key? key,
    required this.song,
    required this.songTouches,
  }) : super(key: key);

  final Song song;
  final SongTouches songTouches;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.check_circle,
        color: Colors.green,
        size: 40,
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      title: const Text(
        "Saved Song Recording!",
        textAlign: TextAlign.center,
      ),
      titleTextStyle: dialogTitleStyle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Please Rate The Difficulty Of The Song:",
            textAlign: TextAlign.center,
            style: dialogTextStyle,
          ),
          RatingBar.builder(
            itemCount: 3,
            itemSize: 50,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              songTouches.setDifficulty(rating.toInt());
            },
          ),
          TextButton(
            onPressed: () async {
              final file = await song.touchFile;
              await file.writeAsString(jsonEncode(songTouches), flush: true);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(200, 255, 255, 255),
    );
  }
}

class _CountDown extends StatefulWidget {
  const _CountDown({
    this.onComplete,
  });
  final Function()? onComplete;

  @override
  State<StatefulWidget> createState() => _CountDownState();
}

class _CountDownState extends State<_CountDown> {
  Function()? onComplete;
  Color _color = Colors.red;
  int _countdown = 2;

  @override
  void initState() {
    super.initState();
    onComplete = widget.onComplete;
  }

  @override
  Widget build(BuildContext context) {
    return CircularCountDownTimer(
      width: MediaQuery.of(context).size.width / 2,
      height: MediaQuery.of(context).size.height / 4,
      duration: 3,
      fillColor: _color,
      ringColor: Colors.grey[500]!,
      isReverse: true,
      textStyle: titleTextStyle,
      onComplete: onComplete,
      timeFormatterFunction: (defaultFormatterFunction, duration) =>
          defaultFormatterFunction(duration + const Duration(seconds: 1)),
      onChange: (timeStamp) {
        if (timeStamp == '2' && _countdown != 1) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            setState(() {
              _color = Colors.yellow;
              _countdown--;
            });
          });
        } else if (timeStamp == '1' && _countdown != 0) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            setState(() {
              _color = const Color.fromARGB(255, 19, 250, 27);
              _countdown--;
            });
          });
        }
      },
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
