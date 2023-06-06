class Touch {
  final TouchType type;
  final int timeStamp;
  final int? duration;

  Touch.regular({required this.timeStamp})
      : type = TouchType.regular,
        duration = null;

  Touch.long({required this.timeStamp, required this.duration})
      : type = TouchType.long;
}

enum TouchType { regular, long }
