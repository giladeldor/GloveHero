import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:glove_hero_app/models/touch.dart';
import 'package:glove_hero_app/utils/painter.dart';
import 'package:glove_hero_app/utils/styles.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../models/audio_manager.dart';
import '../models/ble.dart';
import '../models/song.dart';
import '../utils/constants.dart';

class SinglePlayerModePage extends StatefulWidget {
  const SinglePlayerModePage({super.key, required this.song});
  final Song song;

  @override
  State<SinglePlayerModePage> createState() => _SinglePlayerModePageState();
}

class _SinglePlayerModePageState extends State<SinglePlayerModePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _score = 0;
  Song get _song => widget.song;
  SongTouches? _songTouches;
  late List<Touch>? _touches;
  late StreamSubscription<PlayerState>? _onSongEndSubscription;
  late BleInput _input;
  late BleModel _bleModel;
  var _events = <_TouchEvent>[];
  Touch? _longTouch;
  int _lastUpdate = 0;
  final HashMap<Touch, _ScoreType> _scores = HashMap();
  Future<void> _colorFuture = Future.value();
  late Ticker _ticker;

  void endSong() {
    _onSongEndSubscription?.cancel();
    Navigator.of(context).maybePop();
  }

  @override
  void initState() {
    super.initState();

    _song.touchFile.then((file) {
      try {
        _songTouches = SongTouches.fromJson(
          jsonDecode(
            file.readAsStringSync(),
          ),
        );
      } catch (_) {
        _songTouches = SongTouches();
        for (var i = 0; i < 50; i++) {
          _songTouches!.addTouch(Touch.regular(
              input: Input.fromIdx(Random().nextInt(4)),
              timeStamp: i * Random().nextInt(500) + 100));
        }
      }
      _touches = _songTouches!.touches.toList();

      AudioManager.playSong(_song);
      _onSongEndSubscription = AudioManager.onSongEnd(
        endSong,
      );

      _ticker = createTicker((_) {
        // Redraw each frame.
        _tick();
        setState(() {});
      });
      _ticker.start();
    });

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bleModel = context.read<BleModel>();
      _input = context.read<BleInput>();
      _input.addPressListener(_handleInput);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: AssetImage("assets/recording-mode-background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Consumer<BleInput>(
                builder: (context, input, child) {
                  return CustomPaint(
                    painter: _Painter(
                      input: input.value,
                      timestamp: AudioManager.position,
                      touches: _songTouches ?? SongTouches(),
                    ),
                    child: Container(),
                  );
                },
              ),
              Center(
                child: _TitleScoreBar(
                  song: _song,
                  score: _score,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    AudioManager.stop();
    _onSongEndSubscription?.cancel();
    _input.removePressListener(_handleInput);

    return true;
  }

  @override
  void dispose() {
    _ticker.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _input.removePressListener(_handleInput);

    super.dispose();
  }

  void _handleInput(Input input) {
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) {
      return;
    }

    _events.add(
      _TouchEvent(
        input: input,
        timestamp: AudioManager.position,
      ),
    );
  }

  void _tick() {
    // TODO: seperate logic into a game model.
    final timeStamp = AudioManager.position;

    final events = _events;
    _events = [];

    if (_touches!.isEmpty) return;

    for (var event in events) {
      _longTouch = null;

      final nextTouch = _touches!.indexed.where((element) {
        final (_, touch) = element;
        return touch.input == event.input;
      }).firstOrNull;
      if (nextTouch == null) continue;

      final (index, touch) = nextTouch;
      final diff = (touch.timeStamp - event.timestamp).abs();
      final scoreType = _ScoreType.fromDiff(diff, touchOffset);

      if (scoreType != _ScoreType.miss && touch.type == TouchType.long) {
        _longTouch = touch;
        _lastUpdate = timeStamp;
      }

      _scores[touch] = scoreType;
      _score += scoreType.score;

      _setColor(touch, scoreType);

      if (scoreType != _ScoreType.miss) {
        _touches!.removeRange(0, index + 1);
      }
    }

    if (_longTouch != null) {
      final endStamp = _longTouch!.timeStamp + _longTouch!.duration!;
      if (timeStamp > endStamp) {
        _longTouch = null;
      } else {
        final elapsed = timeStamp - _lastUpdate;
        if (elapsed >= 50) {
          _lastUpdate = timeStamp;
          final score = (elapsed / 50).floor() * 10;
          _score += score;
        }
      }
    }

    while (_touches!.isNotEmpty &&
        _touches!.first.timeStamp < timeStamp - touchOffset) {
      final touch = _touches!.removeAt(0);
      _scores[touch] = _ScoreType.miss;

      _setColor(touch, _ScoreType.miss);
    }
  }

  void _setColor(Touch touch, _ScoreType scoreType) {
    _colorFuture = _colorFuture
        .then(
      (_) => _bleModel.setColor(
        input: touch.input,
        color: scoreType.color,
      ),
    )
        .then(
      (_) async {
        final delay = touch.type == TouchType.long ? touch.duration! : 100;
        await Future.delayed(Duration(milliseconds: delay));
        _bleModel.setColor(
          input: touch.input,
          color: Colors.black,
        );
      },
    );
  }
}

class _TitleScoreBar extends StatelessWidget {
  const _TitleScoreBar({
    required this.song,
    required this.score,
  });

  final Song song;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: AutoSizeText(
                  song.title,
                  textAlign: TextAlign.center,
                  style: titleTextStyle.copyWith(fontSize: 30),
                  maxLines: 2,
                  wrapWords: false,
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ),
                  child: _Score(score: score),
                ),
              )
            ],
          ),
        ),
        const Spacer(flex: 1)
      ],
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({
    required this.score,
  });

  final int score;

  @override
  Widget build(BuildContext context) {
    return Text(
      "Score\n$score",
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: "Karmatic",
        color: Color.fromARGB(255, 250, 244, 193),
        fontSize: 30,
      ),
    );
  }
}

class _Painter extends PainterBase {
  final Input input;
  final int timestamp;
  final SongTouches touches;

  _Painter({
    required this.input,
    required this.timestamp,
    required this.touches,
  });

  @override
  void paint(Canvas canvas, Size size) {
    paintInputCircles(canvas, size, activeInput: input);
    for (var touch in touches.getTouchesInWindow(
      timestamp,
      windowSize,
      touchOffset,
    )) {
      paintTouch(
        canvas,
        size,
        touch: touch,
        timeStamp: timestamp,
        window: windowSize,
      );
    }
  }
}

class _TouchEvent {
  final Input input;
  final int timestamp;

  _TouchEvent({
    required this.input,
    required this.timestamp,
  });
}

enum _ScoreType {
  good,
  bad,
  miss;

  factory _ScoreType.fromDiff(int diff, int offset) {
    if (diff <= offset / 2) {
      return _ScoreType.good;
    } else if (diff <= offset) {
      return _ScoreType.bad;
    } else {
      return _ScoreType.miss;
    }
  }

  int get score => switch (this) {
        _ScoreType.good => goodScore,
        _ScoreType.bad => badScore,
        _ScoreType.miss => missScore,
      };

  Color get color => switch (this) {
        _ScoreType.good => const Color.fromARGB(255, 0, 255, 0),
        _ScoreType.bad => const Color.fromARGB(255, 0, 0, 255),
        _ScoreType.miss => const Color.fromARGB(255, 255, 0, 0),
      };
}
