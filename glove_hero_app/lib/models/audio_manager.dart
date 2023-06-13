import 'package:just_audio/just_audio.dart';
import 'song.dart';

class AudioManager {
  final player = AudioPlayer();
  int currentPlay = 0;
  Future _playOperation = Future.value(null);

  /*void playSong()jkjk {
    player.setAsset(song.asset);
    player.play();
  }*/

  void pauseSong() {
    player.pause();
  }

  void playClip(int index) async {
    _playOperation = _playOperation.then(
      (_) async {
        await player.stop();

        Song song = SongManager.songs[index];
        await player.setVolume(song.volume);
        await player.setAsset(song.audioAsset);
        await player.setClip(
            start: Duration(seconds: song.previewSpan.start),
            end: Duration(seconds: song.previewSpan.end));
        player.play();
      },
    );
  }

  void dispose() {
    player.dispose();
  }
}
