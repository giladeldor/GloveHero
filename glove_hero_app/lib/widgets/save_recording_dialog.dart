import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:glove_hero_app/models/ble.dart';
import 'package:glove_hero_app/models/controller_action.dart';
import 'package:glove_hero_app/widgets/glove_controls.dart';

import '../models/song.dart';
import '../models/touch.dart';
import '../utils/styles.dart';

class SaveRecordingDialog extends StatefulWidget {
  const SaveRecordingDialog({
    Key? key,
    required this.song,
    required this.songTouches,
  }) : super(key: key);

  final Song song;
  final SongTouches songTouches;

  @override
  State<SaveRecordingDialog> createState() => _SaveRecordingDialogState();
}

class _SaveRecordingDialogState extends State<SaveRecordingDialog> {
  int _difficulty = 1;

  @override
  Widget build(BuildContext context) {
    return GloveControls(
      onTouch: _onTouch,
      child: AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 40,
        ),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        title: const Text(
          "Saved Song Recording!",
          textAlign: TextAlign.center,
        ),
        titleTextStyle: dialogTitleStyle,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Please Rate The Difficulty Of The Song:",
              textAlign: TextAlign.center,
              style: dialogTextStyle,
            ),
            RatingBar.builder(
              itemCount: 3,
              itemSize: 50,
              initialRating: _difficulty.toDouble(),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                _difficulty = rating.toInt();
              },
            ),
            TextButton(
              onPressed: _finish,
              child: const Text("OK"),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(200, 255, 255, 255),
      ),
    );
  }

  _onTouch(Input input) {
    final action = MenuAction.fromInput(input);

    switch (action) {
      case MenuAction.up:
        setState(() {
          _difficulty = min(_difficulty + 1, 3);
        });
        break;
      case MenuAction.down:
        setState(() {
          _difficulty = max(_difficulty - 1, 1);
        });
        break;
      case MenuAction.select:
        _finish();
        break;
      default:
        break;
    }
  }

  void _finish() async {
    widget.songTouches.setDifficulty(_difficulty);
    final file = await widget.song.touchFile;
    await file.writeAsString(jsonEncode(widget.songTouches), flush: true);
    if (context.mounted) {
      Navigator.maybePop(context);
    }
  }
}
