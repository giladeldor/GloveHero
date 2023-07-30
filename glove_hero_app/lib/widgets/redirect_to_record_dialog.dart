import 'package:flutter/material.dart';

import '../models/song.dart';
import '../pages/recording_mode_page.dart';
import '../pages/single_player_mode_page.dart';
import '../utils/styles.dart';

class RedirectToRecordDialog extends StatelessWidget {
  const RedirectToRecordDialog({
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
