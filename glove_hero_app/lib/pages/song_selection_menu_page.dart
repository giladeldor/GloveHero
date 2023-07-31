import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../models/song.dart';
import '../utils/functions.dart';
import '../widgets/glove_controls.dart';
import '../models/audio_manager.dart';
import '../models/ble.dart';
import '../models/controller_action.dart';
import '../widgets/song_card.dart';

/// A page that allows the user to select a song.
///
/// Used for recording mode and single-player mode.
class SongSelectionMenuPage extends StatefulWidget {
  const SongSelectionMenuPage({super.key, required this.onSelect});
  final Function(Song song)? onSelect;

  @override
  State<SongSelectionMenuPage> createState() => _SongSelectionMenuPageState();
}

class _SongSelectionMenuPageState extends State<SongSelectionMenuPage> {
  final CarouselController _carouselController = CarouselController();
  int songIndex = 0;

  void onPress() {
    AudioManager.stop();
    widget.onSelect?.call(SongManager.songs[songIndex]);
  }

  @override
  void initState() {
    super.initState();

    AudioManager.playClip(SongManager.songs[songIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return GloveControls(
      onTouch: _onTouch,
      onPop: () => AudioManager.stop(),
      onLifecycleChange: audioOnLifecycleChange,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "assets/backgrounds/song-selection-background.jpg",
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: CarouselSlider(
              items: SongCard.songs(
                onPressed: onPress,
              ),
              carouselController: _carouselController,
              options: CarouselOptions(
                height: 400,
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
                initialPage: 0,
                enableInfiniteScroll: true,
                reverse: false,
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal,
                onPageChanged: _onPageChange,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTouch(Input input) {
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) {
      return;
    }

    final menuAction = MenuAction.fromInput(input);
    switch (menuAction) {
      case MenuAction.up:
        _carouselController.nextPage();
        break;
      case MenuAction.down:
        _carouselController.previousPage();
        break;
      case MenuAction.select:
        onPress();
        break;
      case MenuAction.back:
        Navigator.of(context).maybePop();
        break;
      default:
        break;
    }
  }

  _onPageChange(int index, CarouselPageChangedReason reason) {
    songIndex = index;
    AudioManager.playClip(SongManager.songs[songIndex]);
  }
}
