import 'package:flutter/material.dart';
import 'package:glove_hero_app/ble.dart';
import 'package:glove_hero_app/pages/recording_mode_page.dart';
import 'package:provider/provider.dart';
import '../utils.dart';
import 'leaderboard_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  _MenuButtonID? _selectedButton;
  Input _lastInput = Input.none;

  void _handleUpdate(BleModel model) {
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) {
      return;
    }

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
          case _MenuAction.select:
            _handleSelect(_selectedButton);
            break;
          default:
        }
      }
    }
  }

  void _handleSelect(_MenuButtonID? id) {
    switch (id) {
      case _MenuButtonID.singlePlayer:
        print("Single player");
        // Navigator.pushNamed(context, "/single-player");
        break;
      case _MenuButtonID.multiplayer:
        print("Multiplayer");
        // Navigator.pushNamed(context, "/multiplayer");
        break;
      case _MenuButtonID.recordingMode:
        print("Recording mode");
        Future.microtask(() {
          _lastInput = Input.none;
          return Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const RecordingModePage(),
            ),
          );
        });
        break;
      case _MenuButtonID.leaderboard:
        print("Leaderboard");
        Future.microtask(() {
          _lastInput = Input.none;
          return Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LeaderboardPage(),
            ),
          );
        });
        break;
      case _MenuButtonID.statistics:
        print("Statistics");
        // Navigator.pushNamed(context, "/statistics");
        break;
      default:
    }
  }

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
            _handleUpdate(model);

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
                    onPressed: () {
                      setState(() {
                        _selectedButton = null;
                      });
                      _handleSelect(_MenuButtonID.singlePlayer);
                    },
                    selected: _selectedButton,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _MenuButton(
                    id: _MenuButtonID.multiplayer,
                    onPressed: () {
                      setState(() {
                        _selectedButton = null;
                      });
                      _handleSelect(_MenuButtonID.multiplayer);
                    },
                    selected: _selectedButton,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _MenuButton(
                    id: _MenuButtonID.recordingMode,
                    onPressed: () {
                      setState(() {
                        _selectedButton = null;
                      });
                      _handleSelect(_MenuButtonID.recordingMode);
                    },
                    selected: _selectedButton,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _MenuButton(
                    id: _MenuButtonID.leaderboard,
                    onPressed: () {
                      setState(() {
                        _selectedButton = null;
                      });
                      _handleSelect(_MenuButtonID.leaderboard);
                    },
                    selected: _selectedButton,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _MenuButton(
                    id: _MenuButtonID.statistics,
                    onPressed: () {
                      setState(() {
                        _selectedButton = null;
                      });
                      _handleSelect(_MenuButtonID.statistics);
                    },
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
