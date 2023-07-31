import 'dart:ui';

import '../utils/constants.dart';

/// The possible score types.
enum ScoreType {
  good,
  bad,
  miss;

  /// Computes the [ScoreType] from the given [diff] and [offset].
  factory ScoreType.fromDiff(int diff, int offset) {
    if (diff <= offset / 2) {
      return ScoreType.good;
    } else if (diff <= offset) {
      return ScoreType.bad;
    } else {
      return ScoreType.miss;
    }
  }

  /// The score corresponding to the [ScoreType].
  int get score => switch (this) {
        ScoreType.good => goodScore,
        ScoreType.bad => badScore,
        ScoreType.miss => missScore,
      };

  /// The color corresponding to the [ScoreType].
  Color get color => switch (this) {
        ScoreType.good => goodColor,
        ScoreType.bad => badColor,
        ScoreType.miss => missColor,
      };
}
