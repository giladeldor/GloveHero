import 'package:flutter/material.dart';
import 'package:glove_hero_app/models/ble.dart';
import 'package:glove_hero_app/models/controller_action.dart';
import 'package:glove_hero_app/widgets/glove_controls.dart';

import '../models/song.dart';
import '../pages/recording_mode_page.dart';
import '../pages/single_player_mode_page.dart';
import '../utils/styles.dart';

class RedirectToRecordDialog extends StatefulWidget {
  const RedirectToRecordDialog({
    Key? key,
    required this.song,
  }) : super(key: key);

  final Song song;

  @override
  State<RedirectToRecordDialog> createState() => _RedirectToRecordDialogState();
}

class _RedirectToRecordDialogState extends State<RedirectToRecordDialog> {
  _ActionPicker _actionPicker = _ActionPicker.yes;

  @override
  Widget build(BuildContext context) {
    const chosenStyle = ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(
        Color.fromARGB(40, 73, 69, 69),
      ),
    );

    return GloveControls(
      onTouch: _onTouch,
      child: AlertDialog(
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
                  onPressed: _onYes,
                  style:
                      _actionPicker == _ActionPicker.yes ? chosenStyle : null,
                  child: const Text("Yes"),
                ),
                TextButton(
                  onPressed: _onNo,
                  style: _actionPicker == _ActionPicker.no ? chosenStyle : null,
                  child: const Text("No"),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(200, 255, 255, 255),
      ),
    );
  }

  Future<void> _onYes() async {
    await Navigator.maybePop(context);

    if (context.mounted) {
      await Navigator.maybePop(context);

      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecordingModePage(song: widget.song),
          ),
        );
      }
    }
  }

  void _onNo() {
    Navigator.maybePop(context);
  }

  _onTouch(Input input) {
    final action = MenuAction.fromInput(input);

    switch (action) {
      case MenuAction.up:
        setState(() {
          _actionPicker = _ActionPicker.yes;
        });
        break;
      case MenuAction.down:
        setState(() {
          _actionPicker = _ActionPicker.no;
        });
        break;
      case MenuAction.select:
        if (_actionPicker == _ActionPicker.yes) {
          _onYes();
        } else {
          _onNo();
        }
        break;
      default:
        break;
    }
  }
}

enum _ActionPicker {
  yes,
  no,
}
