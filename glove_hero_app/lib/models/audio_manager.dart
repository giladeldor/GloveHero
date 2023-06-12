import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'song.dart';

class AudioManager {
  static final _player = AudioPlayer();
  static Future _playOperation = Future.value(null);

  static int get position {
    if (_player.playing) return -1;

    return _player.position.inMilliseconds;
  }

  static void playSong(Song song) {
    _player.setAsset(song.audioAsset);
    _player.play();
  }

  static void stopSong() {
    _player.stop();
  }

  static void pauseSong() {
    _player.pause();
  }

  static void playClip(int index) async {
    _playOperation = _playOperation.then(
      (_) async {
        await _player.stop();

        Song song = SongManager.songs[index];
        await _player.setVolume(song.volume);
        await _player.setAsset(song.audioAsset);
        await _player.setClip(
            start: Duration(seconds: song.previewSpan.start),
            end: Duration(seconds: song.previewSpan.end));
        _player.play();
      },
    );
  }

  static void dispose() {
    _player.dispose();
  }

  static StreamSubscription<PlayerState> onSongEnd(void Function() callback) =>
      _player.playerStateStream
          .where((event) => event.processingState == ProcessingState.completed)
          .listen((_) => callback());
}
