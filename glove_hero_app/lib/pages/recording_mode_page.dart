import 'dart:async';
import 'dart:convert';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:glove_hero_app/models/audio_manager.dart';
import 'package:glove_hero_app/models/ble.dart';
import 'package:glove_hero_app/models/touch.dart';
import 'package:glove_hero_app/styles.dart';
import 'package:glove_hero_app/widgets/song_card.dart';
import 'package:just_audio/just_audio.dart';
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
  late Song _song;
  late BleInput _input;
  final SongTouches _songTouches = SongTouches();
  StreamSubscription<PlayerState>? _onSongEndSubscription;
  var _isVisible = true;
  int countdown = 2;
  double _rating = 0.0;

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
      builder: (BuildContext context) {
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
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              TextButton(
                onPressed: () async {
                  _songTouches.setDifficulty(_rating.toInt());
                  final file = await _song.touchFile;
                  await file.writeAsString(jsonEncode(_songTouches),
                      flush: true);
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
      },
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
      final touch = TouchClassifier.release(AudioManager.position);
      if (touch == null) return;

      _songTouches.addTouch(touch);
    } else {
      TouchClassifier.press(input, AudioManager.position);
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
                  painter: Painter(input: input.value),
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
                          child: CircularCountDownTimer(
                            width: MediaQuery.of(context).size.width / 2,
                            height: MediaQuery.of(context).size.height / 4,
                            duration: 3,
                            fillColor: const Color.fromARGB(255, 15, 231, 22),
                            ringColor: Colors.grey[500]!,
                            isReverse: true,
                            textStyle: titleTextStyle,
                            onComplete: () {
                              setState(() {
                                _isVisible = false;
                              });
                              endSong();
                              //AudioManager.playSong(_song);
                              //_onSongEndSubscription =
                              //    AudioManager.onSongEnd(endSong);
                            },
                            onChange: (value) {
                              if (value != countdown.toString()) {
                                switch (value) {
                                  case '2':
                                    setState(() {});
                                }
                              }
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

class Painter extends CustomPainter {
  Painter({required this.input});

  final Input input;

  static const Map<Input, Color> inputColors = {
    Input.input1: Colors.green,
    Input.input2: Colors.red,
    Input.input3: Colors.yellow,
    Input.input4: Colors.blue,
  };

  final paintStroke = Paint()
    ..strokeWidth = 5
    ..style = PaintingStyle.stroke;
  final paintFill = Paint()
    ..strokeWidth = 5
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 10;

    // canvas.drawRect(
    //     Rect.fromLTRB(0, size.height - 4 * radius, size.width, size.height),
    //     paintFill..color = Colors.white.withAlpha(200));

    for (final input in Input.values) {
      if (input == Input.none) continue;

      final index = inputCircleIndex(input)!;
      final paint = (this.input == input ? paintFill : paintStroke)
        ..color = inputColors[input]!;
      final center =
          Offset(size.width / 8 * (2 * index + 1), size.height - radius * 2);

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  int? inputCircleIndex(Input input) {
    return switch (input) {
      Input.input1 => 0,
      Input.input2 => 1,
      Input.input3 => 2,
      Input.input4 => 3,
      Input.none => null,
    };
  }
}
