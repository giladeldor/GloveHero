import 'dart:collection';
import 'ble.dart';

/// A single touch, defined by the input, the type of touch, the time stamp and
/// the duration.
class Touch {
  final Input input;
  final TouchType type;
  final int timeStamp;
  final int? duration;

  Touch.regular({required this.input, required this.timeStamp})
      : type = TouchType.regular,
        duration = null;

  Touch.long({
    required this.input,
    required this.timeStamp,
    required this.duration,
  }) : type = TouchType.long;

  Touch.fromJson(Map<String, dynamic> json)
      : input = Input.fromIdx(json["input"]),
        type = TouchType.fromString(json["type"]),
        timeStamp = json['timeStamp'],
        duration = json['duration'];

  Map<String, dynamic> toJson() => {
        'input': input.idx,
        'type': type.toString(),
        'timeStamp': timeStamp,
        'duration': duration,
      };
}

/// Represents all of the touches for a single song.
class SongTouches {
  final List<Touch> _touches;
  late int difficulty;
  UnmodifiableListView<Touch> get touches => UnmodifiableListView(_touches);

  SongTouches()
      : _touches = [],
        difficulty = 0;

  SongTouches.fromJson(Map<String, dynamic> json)
      : _touches = (json['touches'] as List<dynamic>)
            .map((e) => Touch.fromJson(e))
            .toList(),
        difficulty = json['difficulty'];

  Map<String, dynamic> toJson() => {
        'touches': _touches,
        'difficulty': difficulty,
      };

  void addTouch(Touch touch) {
    _touches.add(touch);
  }

  void setDifficulty(int rating) {
    difficulty = rating;
  }

  List<Touch> getTouchesInWindow(int timestamp, int windowSize, int offset) {
    return _touches
        .where((touch) =>
            touch.timeStamp + (touch.duration ?? 0) >= timestamp - offset &&
            touch.timeStamp <= timestamp + windowSize)
        .toList();
  }
}

/// The type of touch, either regular or long.
enum TouchType {
  regular,
  long;

  static final Map<String, TouchType> _stringToType = Map.fromIterable(
    TouchType.values,
    key: (val) => val.toString(),
  );

  factory TouchType.fromString(String string) => _stringToType[string]!;
}
