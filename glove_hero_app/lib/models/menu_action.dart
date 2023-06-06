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
