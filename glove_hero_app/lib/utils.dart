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
  int currentPage = 0;
  List<Song> songs = [
    Song("assets/audio/4-am.mp3", 0, 15),
    Song("assets/audio/all-my-life.mp3", 6, 17),
    Song("assets/audio/bad-guy.mp3", 13, 27),
    Song("assets/audio/bohemian-rhapsody.mp3", 50, 70),
    Song("assets/audio/come-as-you-are.mp3", 0, 17),
    Song("assets/audio/company-car.mp3", 28, 43),
    Song("assets/audio/freed-from-desire.mp3", 58, 73),
    Song("assets/audio/good-riddance.mp3", 0, 16),
    Song("assets/audio/yes-i-approached-ido.mp3", 40, 60),
    Song("assets/audio/in-the-end.mp3", 0, 18),
    Song("assets/audio/karma-police.mp3", 0, 27),
    Song("assets/audio/mario.mp3", 0, 17),
    Song("assets/audio/mr-shoko.mp3", 46, 58),
    Song("assets/audio/my-love.mp3", 0, 19),
    Song("assets/audio/nothing-else-matters.mp3", 0, 27),
    Song("assets/audio/pokemon.mp3", 0, 15),
    Song("assets/audio/seven-nation-army.mp3", 48, 73),
    Song("assets/audio/slaves.mp3", 19, 39),
    Song("assets/audio/stairway-to-heaven.mp3", 0, 25),
    Song("assets/audio/staying-alive.mp3", 0, 19),
    Song("assets/audio/sultans-of-swing.mp3", 143, 161),
    Song("assets/audio/the-final-countdown.mp3", 117, 136),
    Song("assets/audio/toxic.mp3", 0, 14),
    Song("assets/audio/under-the-bridge.mp3", 0, 28),
    Song("assets/audio/yo-ya.mp3", 25, 45),
    Song("assets/audio/you-give-love-a-bad-name.mp3", 14, 60)
  ];

  /*void playSong() {
    player.setAsset(song.asset);
    player.play();
  }*/

  void pauseSong() {
    player.pause();
  }

  void playClip(int toAdd) async {
    player.stop();
    currentPage = currentPage += toAdd;
    currentPage = currentPage % 26;
    print(currentPage);
    Song song = songs[currentPage];
    player.setAsset(song.asset);
    player.seek(Duration(seconds: song.clipStart));
    player.play();
    await Future.delayed(Duration(seconds: song.clipEnd - song.clipStart));
    player.stop();
  }
}
