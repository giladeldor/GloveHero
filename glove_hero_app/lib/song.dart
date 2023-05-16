// ignore_for_file: prefer_const_constructors

import 'dart:ffi';
import 'dart:io';

class HighScore {
  String name = '';
  int score = -1;

  setHighScore(String name, int score) {
    this.name = name;
    this.score = score;
  }
}

class Song {
  List<Uint8> touches = List<Uint8>.empty();
  int currentTouch = -1;
  late File songFile;
  var highScores = [
    HighScore(),
    HighScore(),
    HighScore(),
    HighScore(),
    HighScore(),
    HighScore(),
    HighScore(),
    HighScore(),
    HighScore(),
    HighScore(),
  ];
}
