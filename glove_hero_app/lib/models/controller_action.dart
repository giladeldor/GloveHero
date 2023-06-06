import 'ble.dart';

enum MenuAction {
  up,
  down,
  select,
  back;

  static MenuAction? fromInput(Input input) {
    return switch (input) {
      Input.input4 => up,
      Input.input3 => down,
      Input.input2 => select,
      Input.input1 => back,
      _ => null,
    };
  }
}

enum PlayAction {
  pinkyFinger,
  ringFinger,
  middleFinger,
  indexFinger,
  release;

  static PlayAction? fromInput(Input input) {
    return switch (input) {
      Input.none => release,
      Input.input1 => pinkyFinger,
      Input.input2 => ringFinger,
      Input.input3 => middleFinger,
      Input.input4 => indexFinger,
    };
  }
}
