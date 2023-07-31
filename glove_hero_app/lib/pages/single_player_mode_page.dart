// ignore_for_file: unused_field

import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:glove_hero_app/models/single_player_game.dart';
import 'package:glove_hero_app/widgets/get_name_dialog.dart';
import 'package:provider/provider.dart';

import 'leaderboard_page.dart';
import '../models/touch.dart';
import '../utils/painter.dart';
import '../utils/styles.dart';
import '../widgets/countdown.dart';
import '../widgets/glove_controls.dart';
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
    with SingleTickerProviderStateMixin {
  bool _isVisible = true;
  Song get _song => widget.song;
  late BleModel _bleModel;
  final _events = <TouchEvent>[];
  Touch? _longTouch;
  late Ticker _ticker;
  late SinglePlayerGame _game;

  @override
  void initState() {
    super.initState();

    _game = SinglePlayerGame(
      song: _song,
      onGetName: _onGetName,
      onSongEnd: _onSongEnd,
    );
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
                              _startSong();
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
                      touches: _game.songTouches,
                    ),
                    child: Container(),
                  );
                },
              ),
              Center(
                child: _TitleScoreBar(
                  song: _song,
                  score: _game.score,
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

  Future<String> _onGetName() async => await showDialog(
        context: context,
        builder: (BuildContext context) => const GetNameDialog(),
      );

  Future<void> _onSongEnd() async {
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

  void _startSong() async {
    await _game.start(_bleModel);

    _ticker = createTicker((_) {
      // Redraw each frame.
      _tick();
      setState(() {});
    });
    _ticker.start();
  }

  void _onPop() async {
    await _game.cleanUp();
  }

  void _onPress(Input input) {
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) {
      return;
    }

    _events.add(
      TouchEvent(
        input: input,
        timestamp: AudioManager.position,
      ),
    );
  }

  void _tick() {
    _game.tick(_events);
    _events.clear();
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
