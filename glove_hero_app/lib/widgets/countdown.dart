import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';

import '../utils/styles.dart';

/// A countdown timer that changes color as it counts down.
class CountDown extends StatefulWidget {
  /// Creates a [CountDown] widget.
  ///
  /// [onComplete] is called when the countdown reaches 0.
  const CountDown({super.key, this.onComplete});
  final Function()? onComplete;

  @override
  State<StatefulWidget> createState() => _CountDownState();
}

class _CountDownState extends State<CountDown> {
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
