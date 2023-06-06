import 'package:flutter/material.dart';
import 'package:glove_hero_app/models/song.dart';
import '../styles.dart';

class SongCard extends StatelessWidget {
  const SongCard({
    super.key,
    required this.songName,
    required this.songArtPath,
    this.onPressed,
  });

  final String songName;
  final String songArtPath;
  final void Function()? onPressed;

  static List<SongCard> songs(void Function()? onPressed) => SongManager.songs
      .map(
        (song) => SongCard(
          songName: song.title,
          songArtPath: song.artAsset,
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    songArtPath,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FittedBox(
                  child: Text(
                    songName,
                    textAlign: TextAlign.center,
                    style: menuButtonTextStyle.copyWith(
                      color: Colors.black,
                      fontSize: 25,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
