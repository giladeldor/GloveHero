import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:glove_hero_app/models/touch.dart';
import 'package:glove_hero_app/utils/painter.dart';
import 'package:glove_hero_app/utils/styles.dart';
import 'package:provider/provider.dart';

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
                  painter: _Painter(input: input.value),
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
  final Input input;

  _Painter({required this.input});

  @override
  void paint(Canvas canvas, Size size) {
    paintInputCircles(canvas, size, activeInput: input);
    paintTouch(
      canvas,
      size,
      touch: Touch.long(
        input: Input.input1,
        timeStamp: 3000,
        duration: 1000,
      ),
      timeStamp: 500,
    );
  }
}
