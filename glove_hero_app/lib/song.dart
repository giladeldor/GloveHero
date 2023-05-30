class HighScore {
  String name = 'NO HIGH SCORE';
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
  late String name;
  List<HighScore> highScores = [
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

  Song({required this.asset, required this.name});
}

class SongManager {
  static List<Song> songs = [
    Song(
          name: "4 AM",
          asset: "assets/audio/4-AM.mp3"
        ),
        Song(
          name: "All My Life",
          asset: "assets/audio/all-my-life.mp3"
        ),
        Song(
          name: "Bad Guy",
          asset: "assets/audio/bad-guy.mp3"
        ),
        Song(
          name: "Bohemian Rhapsody",
          asset: "assets/audio/bohemian-rhapsody.mp3"
        ),
        Song(
          name: "Come as You Are",
          asset: "assets/audio/come-as-you-are.mp3"
        ),
        Song(
          name: "Company Car",
          asset: "assets/audio/company-car.mp3"
        ),
        Song(
          name: "Freed from Desire",
          asset: "assets/audio/freed-from-desire.mp3"
        ),
        Song(
          name: "Good Riddance",
          asset: "assets/audio/good-riddance.mp3"
        ),
        Song(
          name: "I Approached Ido",
          asset: "assets/audio/yes-i-approached-ido.mp3"
        ),
        Song(
          name: "In The End",
          asset: "assets/audio/in-the-end.mp3"
        ),
        Song(
          name: "Karma Police",
          asset: "assets/audio/karma-police.mp3"
        ),
        Song(
          name: "Mario Theme",
          asset: "assets/audio/mario.mp3"
        ),
        Song(
          name: "Mr. Shoko",
          asset: "assets/audio/mr-shoko.mp3"
        ),
        Song(
          name: "My Love",
          asset: "assets/audio/my-love.mp3"
        ),
        Song(
          name: "Nothing Else Matters",
          asset: "assets/audio/nothing-else-matters.mp3"
        ),
        Song(
          name: "Pokemon",
          asset: "assets/audio/pokemon.mp3"
        ),
        Song(
          name: "Seven Nation Army",
          asset: "assets/audio/seven-nation-army.mp3"
        ),
        Song(
          name: "Slaves",
          asset: "assets/audio/slaves.mp3"
        ),
        Song(
          name: "Stairway to Heaven",
          asset: "assets/audio/stairway-to-heaven.mp3"
        ),
        Song(
          name: "Staying Alive",
          asset: "assets/audio/staying-alive.mp3"
        ),
        Song(
          name: "Sultans Of Swing",
          asset: "assets/audio/sultans-of-swing.mp3"
          ),
        Song(
          name: "The Final Countdown",
          asset: "assets/audio/the-final-countdown.mp3"
        ),
        Song(
          name: "Toxic",
          asset: "assets/audio/toxic.mp3"
        ),
        Song(
          name: "Under the Bridge",
          asset: "assets/audio/under-the-bridge.mp3"
        ),
        Song(
          name: "Yo-Ya",
          asset: "assets/audio/yo-ya.mp3"
        ),
        Song(
          name: "YGLABN",
          asset: "assets/audio/you-give-love-a-bad-name.mp3"
        ),
      ];

  static List<HighScore> getHighScores(songIndex) {
    return songs[songIndex].highScores;
  }
}
