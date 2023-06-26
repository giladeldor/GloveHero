import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:glove_hero_app/models/song.dart';
import 'package:provider/provider.dart';
import '../models/audio_manager.dart';
import '../models/ble.dart';
import '../models/controller_action.dart';
import '../widgets/song_card.dart';

class SongSelectionMenuPage extends StatefulWidget {
  const SongSelectionMenuPage({super.key, required this.onSelect});
  final Function(Song song)? onSelect;

  @override
  State<SongSelectionMenuPage> createState() => _SongSelectionMenuPageState();
}

class _SongSelectionMenuPageState extends State<SongSelectionMenuPage>
    with WidgetsBindingObserver {
  late BleInput _input;
  final CarouselController _carouselController = CarouselController();
  int songIndex = 0;
  late final Function(Song song)? _onSelect;

  void onPress() {
    AudioManager.stop();
    _onSelect?.call(SongManager.songs[songIndex]);
  }

  @override
  void initState() {
    super.initState();
    _onSelect = widget.onSelect;

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _input = context.read<BleInput>();
      _input.addTouchListener(_handleInput);
    });

    AudioManager.playClip(SongManager.songs[songIndex]);
  }

  void _handleInput(Input input) {
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
        Navigator.of(context).pop();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        AudioManager.stop();
        return Future.value(true);
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/recording-page-background.jpeg"),
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
                onPageChanged: onPageChange,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    WidgetsBinding.instance.removeObserver(this);
    _input.removeTouchListener(_handleInput);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        AudioManager.pause();
        break;
      case AppLifecycleState.resumed:
        AudioManager.play();
        break;
      default:
        break;
    }
  }

  onPageChange(int index, CarouselPageChangedReason reason) {
    songIndex = index;
    AudioManager.playClip(SongManager.songs[songIndex]);
  }
}
