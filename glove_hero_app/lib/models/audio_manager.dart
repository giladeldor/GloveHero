import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'song.dart';

/// A static class to manage the audio for the game.
///
/// [onSongEnd] can be subscribed to to get a callback when the song ends.
abstract class AudioManager {
  static final _player = AudioPlayer();
  static Future _playOperation = Future.value(null);

  static int get position {
    if (!_player.playing) return -1;

    return _player.position.inMilliseconds;
  }

  /// Play the audio for the given [song].
  static void playSong(Song song) {
    _player.setAsset(song.audioAsset);
    _player.play();
  }

  /// Continue playing the audio.
  static void play() {
    _player.play();
  }

  /// Stop playing the audio (and don't save the position).
  static void stop() {
    _player.stop();
  }

  /// Pause the audio.
  static void pause() {
    _player.pause();
  }

  /// Plays the clip (small portion) of the audio for the given [song].
  static void playClip(Song song) {
    _playOperation = _playOperation.then((_) async {
      await _player.setVolume(song.volume);
      await _player.setAsset(song.audioAsset);
      await _player.setClip(
          start: Duration(seconds: song.previewSpan.start),
          end: Duration(seconds: song.previewSpan.end));
      _player.play();
    }, onError: (_) {});
  }

  /// Clean up the audio player.
  static void dispose() {
    _player.dispose();
  }

  /// Returns a [StreamSubscription] that will call [callback] when the song ends.
  static StreamSubscription<PlayerState> onSongEnd(void Function() callback) =>
      _player.playerStateStream
          .where((event) => event.processingState == ProcessingState.completed)
          .listen((_) => callback());
}
