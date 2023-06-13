import 'dart:collection';
import 'ble.dart';

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
        'input': input.index,
        'type': type.toString(),
        'timeStamp': timeStamp,
        'duration': duration,
      };
}

class SongTouches {
  final List<Touch> _touches;
  UnmodifiableListView<Touch> get touches => UnmodifiableListView(_touches);

  SongTouches() : _touches = [];

  SongTouches.fromJson(Map<String, dynamic> json)
      : _touches = (json['touches'] as List<dynamic>)
            .map((e) => Touch.fromJson(e))
            .toList();

  Map<String, dynamic> toJson() => {
        'touches': _touches,
      };

  void addTouch(Touch touch) {
    _touches.add(touch);
  }
}

enum TouchType {
  regular,
  long;

  static final Map<String, TouchType> _stringToType = Map.fromIterable(
    TouchType.values,
    key: (val) => val.toString(),
  );

  factory TouchType.fromString(String string) => _stringToType[string]!;
}
