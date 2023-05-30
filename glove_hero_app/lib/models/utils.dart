import 'package:flutter/material.dart';
import 'package:glove_hero_app/models/song.dart';
import 'package:just_audio/just_audio.dart';

const titleTextStyle = TextStyle(
  fontFamily: "Karmatic",
  fontSize: 45,
  color: Color.fromARGB(255, 255, 240, 254),
);

const menuButtonTextStyle = TextStyle(
  fontFamily: "Karmatic",
  fontSize: 30,
  color: Color.fromARGB(255, 242, 255, 235),
);

const menuButtonDisabledTextStyle = TextStyle(
  fontFamily: "Karmatic",
  fontSize: 30,
  color: Colors.grey,
);

class AudioManager {
  final player = AudioPlayer();
  int currentPlay = 0;

  /*void playSong() {
    player.setAsset(song.asset);
    player.play();
  }*/

  void pauseSong() {
    player.pause();
  }

  void playClip(int index) async {
    player.stop();
    print(index);
    Song song = SongManager.songs[index];
    currentPlay++;
    if (currentPlay < 0) {
      currentPlay = 1;
    }
    int thisPlay = currentPlay;
    player.setAsset(song.asset);
    player.seek(Duration(seconds: song.clipStart));
    player.play();

    await Future.delayed(Duration(seconds: song.clipEnd - song.clipStart));
    if (thisPlay == currentPlay) {
      player.stop();
    }
  }
}
