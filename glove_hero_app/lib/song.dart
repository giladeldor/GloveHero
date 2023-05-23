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
