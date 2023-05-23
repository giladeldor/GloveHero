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
  List<int> touches = List<int>.empty();
  int currentTouch = -1;
  late String asset;
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
