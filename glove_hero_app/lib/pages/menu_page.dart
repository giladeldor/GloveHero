import 'package:flutter/material.dart';
import 'package:glove_hero_app/ble.dart';
import 'package:provider/provider.dart';
import '../utils.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  _MenuButtonID? _selectedButton;
  Input _lastInput = Input.none;

  @override
  Widget build(BuildContext context) {
    const buttonPadding = EdgeInsets.symmetric(vertical: 8, horizontal: 0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/menu-background.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Consumer<BleModel>(
          builder: (context, model, child) {
            print(model.connectionState);
            if (model.input != _lastInput) {
              _lastInput = model.input;

              if (_selectedButton == null) {
                _selectedButton = _MenuButtonID.singlePlayer;
              } else {
                final action = _MenuAction.fromInput(_lastInput);
                switch (action) {
                  case _MenuAction.up:
                    _selectedButton = _selectedButton?.up;
                    break;
                  case _MenuAction.down:
                    _selectedButton = _selectedButton?.down;
                    break;
                  default:
                }
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 40.0, bottom: 16.0),
                  child: Text(
                    "Glove Hero",
                    style: titleTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: buttonPadding,
                  child: _MenuButton(
                    id: _MenuButtonID.singlePlayer,
                    onPressed: () {},
                    selected: _selectedButton,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _MenuButton(
                    id: _MenuButtonID.multiplayer,
                    selected: _selectedButton,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _MenuButton(
                    id: _MenuButtonID.recordingMode,
                    selected: _selectedButton,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _MenuButton(
                    id: _MenuButtonID.leaderboard,
                    onPressed: () {},
                    selected: _selectedButton,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _MenuButton(
                    id: _MenuButtonID.statistics,
                    selected: _selectedButton,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    // ignore: unused_element
    super.key,
    required this.id,
    this.onPressed,
    this.selected,
  });

  final _MenuButtonID id;
  final void Function()? onPressed;
  final _MenuButtonID? selected;

  @override
  Widget build(BuildContext context) {
    final style =
        onPressed == null ? menuButtonDisabledTextStyle : menuButtonTextStyle;

    final label = FittedBox(
      child: Text(
        id.name,
        style: style,
      ),
    );

    return selected == id
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: const ImageIcon(
              AssetImage("assets/hand-selector.png"),
              size: 30,
              color: Colors.white,
            ),
            label: label,
          )
        : OutlinedButton(
            onPressed: onPressed,
            child: label,
          );
  }
}

enum _MenuButtonID {
  singlePlayer,
  multiplayer,
  recordingMode,
  leaderboard,
  statistics;

  String get name => switch (this) {
        singlePlayer => "Single Player",
        multiplayer => "Multiplayer",
        recordingMode => "Recording Mode",
        leaderboard => "Leaderboard",
        statistics => "Statistics",
      };

  _MenuButtonID get up {
    final idx = (index - 1) % _MenuButtonID.values.length;
    return _MenuButtonID.values[idx];
  }

  _MenuButtonID get down {
    final idx = (index + 1) % _MenuButtonID.values.length;
    return _MenuButtonID.values[idx];
  }
}

enum _MenuAction {
  up,
  down,
  select;

  static _MenuAction? fromInput(Input input) {
    return switch (input) {
      Input.input4 => up,
      Input.input3 => down,
      Input.input2 => select,
      _ => null,
    };
  }
}
