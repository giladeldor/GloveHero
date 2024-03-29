import 'ble.dart';

/// The possible menu actions matching the glove inputs.
enum MenuAction {
  up,
  down,
  select,
  back;

  /// Returns the [MenuAction] corresponding to the given [Input].
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
