import 'package:flutter/material.dart';
import 'package:glove_hero_app/song.dart';
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

  void playSong(Song song) {
    player.setAsset(song.asset);
    player.play();
  }

  void pauseSong() {
    player.pause();
  }
}
