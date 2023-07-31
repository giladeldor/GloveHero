import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../utils/constants.dart';
import 'audio_manager.dart';
import 'ble.dart';
import 'high_score.dart';
import 'score.dart';
import 'song.dart';
import 'statistics.dart';
import 'touch.dart';

class SinglePlayerGame {
  final Song song;
  final Future<String> Function()? onGetName;
  final void Function()? onSongEnd;
  int score = 0;

  late BleModel _bleModel;
  SongTouches? _songTouches;
  late List<Touch> _touches;
  final _statistics = SongStatistics();
  StreamSubscription<PlayerState>? _onSongEndSubscription;
  Touch? _longTouch;
  int _lastUpdate = 0;

  SongTouches get songTouches => _songTouches ?? SongTouches();

  SinglePlayerGame({required this.song, this.onGetName, this.onSongEnd});

  Future<void> start(BleModel bleModel) async {
    _bleModel = bleModel;
    final file = await song.touchFile;

    try {
      _songTouches = SongTouches.fromJson(
        jsonDecode(
          await file.readAsString(),
        ),
      );
    } catch (_) {
      _songTouches = _genRandomTouches();
    }

    _touches = _songTouches!.touches.toList();

    AudioManager.playSong(song);
    _onSongEndSubscription = AudioManager.onSongEnd(endSong);
  }

  void tick(List<TouchEvent> events) {
    final timeStamp = AudioManager.position;

    if (_touches.isEmpty) return;

    for (var event in events) {
      _longTouch = null;

      final nextTouch = _touches.indexed.where((element) {
        final (_, touch) = element;
        return touch.input == event.input;
      }).firstOrNull;
      if (nextTouch == null) continue;

      final (index, touch) = nextTouch;
      final diff = (touch.timeStamp - event.timestamp).abs();
      final scoreType = ScoreType.fromDiff(diff, touchOffset);

      if (scoreType != ScoreType.miss && touch.type == TouchType.long) {
        _longTouch = touch;
        _lastUpdate = timeStamp;
      }

      _statistics.addScore(touch.input, scoreType);
      score += scoreType.score;

      _setColor(touch, scoreType);

      if (scoreType != ScoreType.miss) {
        _touches.removeRange(0, index + 1);
      }
    }

    if (_longTouch != null) {
      final endStamp = _longTouch!.timeStamp + _longTouch!.duration!;
      if (timeStamp > endStamp) {
        _longTouch = null;
      } else {
        final elapsed = timeStamp - _lastUpdate;
        if (elapsed >= 50) {
          _lastUpdate = timeStamp;
          score += (elapsed / 50).floor() * 10;
        }
      }
    }

    while (_touches.isNotEmpty &&
        _touches.first.timeStamp < timeStamp - touchOffset) {
      final touch = _touches.removeAt(0);
      _statistics.addScore(touch.input, ScoreType.miss);

      _setColor(touch, ScoreType.miss);
    }
  }

  Future<void> cleanUp() async {
    AudioManager.stop();
    await _onSongEndSubscription?.cancel();
  }

  void endSong() async {
    await cleanUp();

    final String name = await (onGetName?.call() ?? Future.value("AAA"));

    final highScores = await SongManager.getHighScores(song);
    highScores.addScore(HighScore(name: name, score: score));

    await SongManager.saveHighScores(song, highScores);
    await StatisticsManager.addStatistics(song, _statistics);

    onSongEnd?.call();
  }

  SongTouches _genRandomTouches() {
    final touches = SongTouches();
    for (var i = 0; i < 50; i++) {
      touches.addTouch(Touch.regular(
          input: Input.fromIdx(Random().nextInt(4)),
          timeStamp: i * Random().nextInt(500) + 100));
    }
    return touches;
  }

  void _setColor(Touch touch, ScoreType scoreType) {
    _bleModel.setColor(input: touch.input, color: scoreType.color);

    final delay = touch.type == TouchType.long ? touch.duration! : 100;
    Future.delayed(Duration(milliseconds: delay)).then((_) {
      _bleModel.setColor(
        input: touch.input,
        color: Colors.black,
      );
    });
  }
}

class TouchEvent {
  final Input input;
  final int timestamp;

  TouchEvent({
    required this.input,
    required this.timestamp,
  });
}
