import 'dart:ui';

import '../utils/constants.dart';

enum ScoreType {
  good,
  bad,
  miss;

  factory ScoreType.fromDiff(int diff, int offset) {
    if (diff <= offset / 2) {
      return ScoreType.good;
    } else if (diff <= offset) {
      return ScoreType.bad;
    } else {
      return ScoreType.miss;
    }
  }

  int get score => switch (this) {
        ScoreType.good => goodScore,
        ScoreType.bad => badScore,
        ScoreType.miss => missScore,
      };

  Color get color => switch (this) {
        ScoreType.good => const Color.fromARGB(255, 0, 255, 0),
        ScoreType.bad => const Color.fromARGB(255, 0, 0, 255),
        ScoreType.miss => const Color.fromARGB(255, 255, 0, 0),
      };
}
