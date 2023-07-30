import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../models/song.dart';
import '../models/touch.dart';
import '../utils/styles.dart';

class SaveRecordingDialog extends StatelessWidget {
  const SaveRecordingDialog({
    Key? key,
    required this.song,
    required this.songTouches,
  }) : super(key: key);

  final Song song;
  final SongTouches songTouches;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              songTouches.setDifficulty(rating.toInt());
            },
          ),
          TextButton(
            onPressed: () async {
              final file = await song.touchFile;
              await file.writeAsString(jsonEncode(songTouches), flush: true);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(200, 255, 255, 255),
    );
  }
}
