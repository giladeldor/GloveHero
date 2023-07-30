import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:glove_hero_app/models/high_score.dart';
import 'package:glove_hero_app/models/statistics.dart';
import 'package:glove_hero_app/widgets/get_name_dialog.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../models/score.dart';
import '../models/touch.dart';
import '../utils/painter.dart';
import '../utils/styles.dart';
import '../widgets/countdown.dart';
import '../widgets/glove_controls.dart';
import '../models/audio_manager.dart';
import '../models/ble.dart';
import '../models/song.dart';
import '../utils/constants.dart';
import 'leaderboard_page.dart';

class SinglePlayerModePage extends StatefulWidget {
  const SinglePlayerModePage({super.key, required this.song});
  final Song song;

  @override
  State<SinglePlayerModePage> createState() => _SinglePlayerModePageState();
}

class _SinglePlayerModePageState extends State<SinglePlayerModePage>
    with SingleTickerProviderStateMixin {
  int _score = 0;

  bool _isVisible = true;
  Song get _song => widget.song;
  SongTouches? _songTouches;
  late List<Touch>? _touches;
  late StreamSubscription<PlayerState>? _onSongEndSubscription;
  late BleModel _bleModel;
  var _events = <_TouchEvent>[];
  Touch? _longTouch;
  int _lastUpdate = 0;
  final _statistics = SongStatistics();
  late Ticker _ticker;

  Future<void> endSong() async {
    _onSongEndSubscription?.cancel();

    final name = await showDialog(
      context: context,
      builder: (BuildContext context) => const GetNameDialog(),
    );

    final highScores = await SongManager.getHighScores(_song);
    highScores.addScore(HighScore(name: name, score: _score));
    await SongManager.saveHighScores(_song, highScores);
    await StatisticsManager.addStatistics(_song, _statistics);

    if (context.mounted) {
      await Navigator.of(context).maybePop().then(
            (_) => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LeaderboardPage(initialSong: _song),
              ),
            ),
          );
    }
  }

  void startSong() {
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
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _bleModel = context.read<BleModel>());
  }

  @override
  Widget build(BuildContext context) {
    return GloveControls(
      onPress: _onPress,
      onPop: _onPop,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: AssetImage("assets/backgrounds/hills-background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              _isVisible
                  ? Flexible(
                      child: Center(
                        child: CountDown(
                          onComplete: () {
                            setState(() {
                              _isVisible = false;
                              startSong();
                            });
                          },
                        ),
                      ),
                    )
                  : const Spacer(),
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

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onPop() {
    AudioManager.stop();
    _onSongEndSubscription?.cancel();
  }

  void _onPress(Input input) {
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
      final scoreType = ScoreType.fromDiff(diff, touchOffset);

      if (scoreType != ScoreType.miss && touch.type == TouchType.long) {
        _longTouch = touch;
        _lastUpdate = timeStamp;
      }

      _statistics.addScore(touch.input, scoreType);
      _score += scoreType.score;

      _setColor(touch, scoreType);

      if (scoreType != ScoreType.miss) {
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
      _statistics.addScore(touch.input, ScoreType.miss);

      _setColor(touch, ScoreType.miss);
    }
  }

  void _setColor(Touch touch, ScoreType scoreType) {
    _bleModel.setColor(input: touch.input, color: scoreType.color);

    final delay = touch.type == TouchType.long ? touch.duration! : 100;
    Future.delayed(Duration(milliseconds: delay)).then((_) {
      _bleModel.setColor(
        input: touch.input,
        color: Colors.black,
      );
    });
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
