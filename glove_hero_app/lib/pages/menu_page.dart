import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:glove_hero_app/models/ble.dart';

import 'package:glove_hero_app/pages/controls_page.dart';
import 'package:glove_hero_app/pages/recording_mode_page.dart';
import 'package:glove_hero_app/pages/song_selection_menu_page.dart';
import 'package:provider/provider.dart';
import '../models/controller_action.dart';
import '../models/song.dart';
import '../models/touch.dart';
import '../utils/styles.dart';
import 'leaderboard_page.dart';
import 'recording_mode_page.dart';
import 'single_player_mode_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late BleInput _input;
  _MenuButtonID? _selectedButton;

  void _handleInput(Input input) {
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) {
      return;
    }

    if (_selectedButton == null) {
      _selectedButton = _MenuButtonID.singlePlayer;
    } else {
      final action = MenuAction.fromInput(input);
      switch (action) {
        case MenuAction.up:
          _selectedButton = _selectedButton?.up;
          break;
        case MenuAction.down:
          _selectedButton = _selectedButton?.down;
          break;
        case MenuAction.select:
          _handleSelect(_selectedButton);
          break;
        default:
      }
    }

    setState(() {});
  }

  void _handleSelect(_MenuButtonID? id) {
    switch (id) {
      case _MenuButtonID.singlePlayer:
        _redirectToSinglePlayer();
        break;
      case _MenuButtonID.multiplayer:
        // Navigator.pushNamed(context, "/multiplayer");
        break;
      case _MenuButtonID.recordingMode:
        _redirectoToRecord();
        break;
      case _MenuButtonID.leaderboard:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LeaderboardPage(),
          ),
        );
        break;
      case _MenuButtonID.statistics:
        // Navigator.pushNamed(context, "/statistics");
        break;
      case _MenuButtonID.controls:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const ControlsPage(),
        ));
        break;
      default:
    }
  }

  void _redirectoToRecord() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SongSelectionMenuPage(
          onSelect: (song) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecordingModePage(song: song),
              ),
            );
          },
        ),
      ),
    );
  }

  void _redirectToSinglePlayer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SongSelectionMenuPage(
          onSelect: (song) {
            song.touchFile.then(
              (file) {
                try {
                  SongTouches.fromJson(jsonDecode(file.readAsStringSync()));
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SinglePlayerModePage(song: song),
                    ),
                  );
                } catch (_) {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) =>
                        _RedirectToRecordDialog(song: song),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _input = context.read<BleInput>();
      _input.addTouchListener(_handleInput);
    });
  }

  @override
  Widget build(BuildContext context) {
    const buttonPadding = EdgeInsets.symmetric(vertical: 8, horizontal: 0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/menu-background.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Consumer<BleConnection>(
          builder: (context, connection, child) {
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
                    onPressed:
                        true || connection.state == BleConnectionState.connected
                            ? () {
                                setState(() {
                                  _selectedButton = null;
                                });
                                _handleSelect(_MenuButtonID.singlePlayer);
                              }
                            : null,
                    selected: _selectedButton,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _MenuButton(
                    id: _MenuButtonID.multiplayer,
                    onPressed: connection.state == BleConnectionState.connected
                        ? () {
                            setState(() {
                              _selectedButton = null;
                            });
                            _handleSelect(_MenuButtonID.multiplayer);
                          }
                        : null,
                    selected: _selectedButton,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _MenuButton(
                      id: _MenuButtonID.recordingMode,
                      onPressed: /*connection.state == BleConnectionState.connected
                        ? */
                          () {
                        setState(() {
                          _selectedButton = null;
                        });
                        _handleSelect(_MenuButtonID.recordingMode);
                      }
                      /*: null,
                    selected: _selectedButton,*/
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _MenuButton(
                    id: _MenuButtonID.controls,
                    onPressed: () {
                      setState(() {
                        _selectedButton = null;
                      });
                      _handleSelect(_MenuButtonID.controls);
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

  @override
  void dispose() {
    super.dispose();

    _input.removeTouchListener(_handleInput);
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
  statistics,
  controls;

  String get name => switch (this) {
        singlePlayer => "Single Player",
        multiplayer => "Multiplayer",
        recordingMode => "Recording Mode",
        leaderboard => "Leaderboard",
        statistics => "Statistics",
        controls => "Controls"
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

class _RedirectToRecordDialog extends StatelessWidget {
  const _RedirectToRecordDialog({
    Key? key,
    required this.song,
  }) : super(key: key);

  final Song song;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      title: const Text(
        "Song Recording Doesn't Exist",
        textAlign: TextAlign.center,
      ),
      titleTextStyle: songSelectionDialogTitleStyle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Would You Like To Record It?",
            textAlign: TextAlign.center,
            style: dialogTextStyle,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecordingModePage(
                        song: song,
                      ),
                    ),
                  );
                },
                child: const Text("Yes"),
              ),
              TextButton(
                onPressed: () {
                  // Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SinglePlayerModePage(
                        song: song,
                      ),
                    ),
                  );
                },
                child: const Text("No"),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(200, 255, 255, 255),
    );
  }
}
