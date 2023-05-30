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
  late int clipStart;
  late int clipEnd;
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

  Song(this.asset, this.clipStart, this.clipEnd);
}
