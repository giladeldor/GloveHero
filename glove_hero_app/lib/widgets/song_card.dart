import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:glove_hero_app/models/song.dart';
import '../models/touch.dart';
import '../utils/styles.dart';

class SongCard extends StatelessWidget {
  SongCard({
    super.key,
    required this.song,
    this.onPressed,
  })  : songName = song.name,
        songArtPath = song.artAsset;

  final String songName;
  final String songArtPath;
  final Song song;
  final void Function()? onPressed;

  static List<SongCard> songs({void Function()? onPressed}) => SongManager.songs
      .map(
        (song) => SongCard(
          song: song,
          onPressed: onPressed,
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 250, 250, 230),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            songArtPath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AutoSizeText(
                  songName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  wrapWords: false,
                  style: menuButtonTextStyle.copyWith(
                    color: Colors.black,
                    fontSize: 25,
                  ),
                ),
              ),
              FutureBuilder(
                future: song.touchFile,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final file = snapshot.data!;
                    late SongTouches touches;

                    try {
                      touches = SongTouches.fromJson(
                        jsonDecode(
                          file.readAsStringSync(),
                        ),
                      );
                    } catch (_) {
                      touches = SongTouches();
                    }

                    return RatingBarIndicator(
                      itemCount: 3,
                      rating: touches.difficulty.toDouble(),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
