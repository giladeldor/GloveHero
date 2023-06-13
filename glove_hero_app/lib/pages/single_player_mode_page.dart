import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:glove_hero_app/models/touch.dart';
import 'package:glove_hero_app/utils/painter.dart';
import 'package:glove_hero_app/utils/styles.dart';
import 'package:provider/provider.dart';

import '../models/audio_manager.dart';
import '../models/ble.dart';
import '../models/song.dart';

class SinglePlayerModePage extends StatefulWidget {
  const SinglePlayerModePage({super.key, required this.song});
  final Song song;

  @override
  State<SinglePlayerModePage> createState() => _SinglePlayerModePageState();
}

class _SinglePlayerModePageState extends State<SinglePlayerModePage> {
  int _score = 0;
  Song get _song => widget.song;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  painter: _Painter(
                    input: input.value,
                    timestamp: AudioManager.position,
                    touches: SongTouches(),
                  ),
                  child: Container(),
                );
              },
            ),
            Center(
              child: Column(
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
                            _song.title,
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
                            child: _Score(score: _score),
                          ),
                        )
                      ],
                    ),
                  ),
                  const Spacer(flex: 1)
                ],
              ),
            ),
          ])),
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
  static const windowSize = 3000;

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
    for (var touch in touches.getTouchesInWindow(timestamp, windowSize)) {
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
