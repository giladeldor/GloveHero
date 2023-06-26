import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'high_score.dart';

class Song {
  const Song({
    required this.name,
    required this.previewSpan,
    required this.volume,
    String? title,
  }) : title = title ?? name;

  final String name;
  final String title;
  final PreviewSpan previewSpan;
  final double volume;

  String get audioAsset => "assets/audio/$_assetTitle.mp3";
  String get artAsset => "assets/song-art/$_assetTitle.jpg";
  Future<File> get touchFile async {
    return File("${await _localDir}/touches/$_assetTitle.json")
        .create(recursive: true);
  }

  Future<File> get highScoreFile async {
    return File("${await _localDir}/high-scores/$_assetTitle.json")
        .create(recursive: true);
  }

  Future<String> get _localDir async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  String get _assetTitle =>
      name.replaceAll(".", "").split(' ').join('-').toLowerCase();
}

class PreviewSpan {
  const PreviewSpan({required this.start, required this.end});

  final int start;
  final int end;
  Duration get duration => Duration(seconds: end - start);
}

class SongManager {
  static const List<Song> songs = [
    Song(
      name: "4 AM",
      previewSpan: PreviewSpan(start: 0, end: 15),
      volume: 0.5,
    ),
    Song(
      name: "All My Life",
      previewSpan: PreviewSpan(start: 6, end: 17),
      volume: 0.5,
    ),
    Song(
      name: "Bad Guy",
      previewSpan: PreviewSpan(start: 14, end: 27),
      volume: 1.5,
    ),
    Song(
      name: "Bohemian Rhapsody",
      previewSpan: PreviewSpan(start: 50, end: 70),
      volume: 0.7,
    ),
    Song(
      name: "Come as You Are",
      previewSpan: PreviewSpan(start: 0, end: 17),
      volume: 0.5,
    ),
    Song(
      name: "Company Car",
      previewSpan: PreviewSpan(start: 28, end: 44),
      volume: 1,
    ),
    Song(
      name: "Freed from Desire",
      previewSpan: PreviewSpan(start: 58, end: 73),
      volume: 0.7,
    ),
    Song(
      name: "Good Riddance",
      previewSpan: PreviewSpan(start: 0, end: 16),
      volume: 0.5,
    ),
    Song(
      name: "I Approached Ido",
      previewSpan: PreviewSpan(start: 40, end: 60),
      volume: 0.5,
    ),
    Song(
      name: "In The End",
      previewSpan: PreviewSpan(start: 0, end: 18),
      volume: 0.4,
    ),
    Song(
      name: "Mario Theme",
      previewSpan: PreviewSpan(start: 0, end: 17),
      volume: 1.3,
    ),
    Song(
      name: "Mr. Shoko",
      previewSpan: PreviewSpan(start: 46, end: 58),
      volume: 1.5,
    ),
    Song(
      name: "My Love",
      previewSpan: PreviewSpan(start: 0, end: 19),
      volume: 0.4,
    ),
    Song(
      name: "No Surprises",
      previewSpan: PreviewSpan(start: 0, end: 25),
      volume: 1,
    ),
    Song(
      name: "Nothing Else Matters",
      previewSpan: PreviewSpan(start: 0, end: 27),
      volume: 2,
    ),
    Song(
      name: "Pokemon",
      previewSpan: PreviewSpan(start: 0, end: 15),
      volume: 2.5,
    ),
    Song(
      name: "Seven Nation Army",
      previewSpan: PreviewSpan(start: 48, end: 73),
      volume: 1.7,
    ),
    Song(
      name: "Slaves",
      previewSpan: PreviewSpan(start: 19, end: 39),
      volume: 0.7,
    ),
    Song(
      name: "Stairway to Heaven",
      previewSpan: PreviewSpan(start: 0, end: 25),
      volume: 3.5,
    ),
    Song(
      name: "Staying Alive",
      previewSpan: PreviewSpan(start: 0, end: 19),
      volume: 0.5,
    ),
    Song(
      name: "Sultans Of Swing",
      previewSpan: PreviewSpan(start: 143, end: 161),
      volume: 1,
    ),
    Song(
      name: "The Final Countdown",
      previewSpan: PreviewSpan(start: 117, end: 136),
      volume: 1,
    ),
    Song(
      name: "Toxic",
      previewSpan: PreviewSpan(start: 0, end: 14),
      volume: 1,
    ),
    Song(
      name: "Under the Bridge",
      previewSpan: PreviewSpan(start: 0, end: 28),
      volume: 2,
    ),
    Song(
      name: "Yo-Ya",
      previewSpan: PreviewSpan(start: 25, end: 45),
      volume: 1.5,
    ),
    Song(
      name: "You Give Love A Bad Name",
      title: "YGLABN",
      previewSpan: PreviewSpan(start: 14, end: 30),
      volume: 0.7,
    ),
  ];

  static Future<SongHighScores> getHighScores(Song song) async {
    final file = await song.highScoreFile;
    late SongHighScores highScores;

    if (song == songs[4]) {
      highScores = SongHighScores();
      highScores.addScore(HighScore(name: "NAD", score: 100));
      highScores.addScore(HighScore(name: "EC", score: 100));
      highScores.addScore(HighScore(name: "GLD", score: 50));
      highScores.addScore(HighScore(name: "NAD", score: 150));
      highScores.addScore(HighScore(name: "EC", score: 175));
      highScores.addScore(HighScore(name: "GLD", score: 200));
      highScores.addScore(HighScore(name: "NAD", score: 221));
      highScores.addScore(HighScore(name: "EC", score: 300));
      highScores.addScore(HighScore(name: "GLD", score: 1));
      highScores.addScore(HighScore(name: "FCK", score: 75));
      return highScores;
    }

    try {
      highScores =
          SongHighScores.fromJson(jsonDecode(await file.readAsString()));
    } catch (_) {
      highScores = SongHighScores();
      await file.writeAsString(jsonEncode(highScores));
    }
    return highScores;
  }
}
