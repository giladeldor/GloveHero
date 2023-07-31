import 'dart:convert';
import 'dart:io';

import '../utils/functions.dart';
import 'ble.dart';
import 'score.dart';
import 'song.dart';

/// The statistics for a single input.
class InputStatistics {
  InputStatistics()
      : _scores = {},
        _totalTouches = 0;

  /// Merges two [InputStatistics] objects into a new one.
  InputStatistics.merge(
      {required InputStatistics stats1, required InputStatistics stats2})
      : _scores = {
          for (final scoreType in ScoreType.values)
            scoreType: (stats1._scores[scoreType] ?? 0) +
                (stats2._scores[scoreType] ?? 0),
        },
        _totalTouches = stats1._totalTouches + stats2._totalTouches;

  final Map<ScoreType, int> _scores;
  int _totalTouches;

  void addScore(ScoreType scoreType) {
    _scores.update(scoreType, (value) => value + 1, ifAbsent: () => 1);
    _totalTouches++;
  }

  int get totalTouches => _totalTouches;
  int getPercent(ScoreType scoreType) =>
      (_scores[scoreType] ?? 0) *
      100 ~/
      (_totalTouches == 0 ? 1 : _totalTouches);

  Map<String, dynamic> toJson() => {
        'scores': _scores.map(
          (key, value) => MapEntry(
            key.index.toString(),
            value,
          ),
        ),
        'totalTouches': _totalTouches,
      };

  InputStatistics.fromJson(Map<String, dynamic> json)
      : _scores = {
          for (final entry in json['scores'].entries)
            ScoreType.values[int.parse(entry.key)]: entry.value,
        },
        _totalTouches = json['totalTouches'];
}

/// The statistics for a single song.
class SongStatistics {
  final int numPlays;
  final Map<Input, InputStatistics> _statistics;

  SongStatistics({this.numPlays = 0}) : _statistics = {};

  SongStatistics.merge(
      {required SongStatistics stats1, required SongStatistics stats2})
      : numPlays = stats1.numPlays + stats2.numPlays,
        _statistics = {
          for (final input in Input.realValues)
            input: InputStatistics.merge(
              stats1: stats1._statistics[input] ?? InputStatistics(),
              stats2: stats2._statistics[input] ?? InputStatistics(),
            ),
        };

  void addScore(Input input, ScoreType scoreType) {
    _statistics
        .update(input, (value) => value, ifAbsent: () => InputStatistics())
        .addScore(scoreType);
  }

  int getPercent(Input input, ScoreType scoreType) =>
      _statistics[input]?.getPercent(scoreType) ?? 0;

  Map<String, dynamic> toJson() => {
        'numPlays': numPlays,
        'statistics': {
          for (final entry in _statistics.entries)
            entry.key.idx.toString(): entry.value.toJson(),
        }
      };

  SongStatistics.fromJson(Map<String, dynamic> json)
      : numPlays = json['numPlays'] ?? 0,
        _statistics = {
          for (final entry in json['statistics'].entries)
            Input.fromIdx(int.parse(entry.key)): InputStatistics.fromJson(
              entry.value,
            ),
        };
}

/// Manager for the statistics of all songs in the game.
class StatisticsManager {
  static Map<Song, SongStatistics>? __statistics;

  static Future<Map<Song, SongStatistics>> get _statistics async {
    if (__statistics != null) return __statistics!;

    final file = await _statisticsFile;
    if (await file.exists()) {
      try {
        final json = jsonDecode(await file.readAsString());
        __statistics = {
          for (final entry in json.entries)
            SongManager.getSongByName(entry.key):
                SongStatistics.fromJson(entry.value),
        };
      } catch (_) {}
    }

    __statistics ??= {};
    return __statistics!;
  }

  static Future<File> get _statisticsFile async {
    final file = File("${await localDir}/statistics.json");
    return await file.create(recursive: true);
  }

  static Future<void> _saveStatistics() async {
    final file = await _statisticsFile;
    await file.create(recursive: true);

    final json = {
      for (final entry in (await _statistics).entries)
        entry.key.name: entry.value.toJson(),
    };

    await file.writeAsString(
      jsonEncode(json),
    );
  }

  static Future<SongStatistics> getStatistics(Song song) async {
    return (await _statistics)[song] ?? SongStatistics();
  }

  static Future<void> addStatistics(
    Song song,
    SongStatistics statistics,
  ) async {
    final stats = await _statistics;
    stats.update(
      song,
      (value) => SongStatistics.merge(stats1: value, stats2: statistics),
      ifAbsent: () => statistics,
    );
    await _saveStatistics();
  }

  static Future<void> reset() async {
    await (await _statisticsFile).delete();
    __statistics = null;
  }
}
