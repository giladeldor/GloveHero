import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:glove_hero_app/models/song.dart';
import 'package:provider/provider.dart';
import '../models/audio_manager.dart';
import '../models/ble.dart';
import '../models/controller_action.dart';
import '../widgets/song_card.dart';
import 'recording_mode_page.dart';

class RecordingModeMenuPage extends StatefulWidget {
  const RecordingModeMenuPage({super.key});

  @override
  State<RecordingModeMenuPage> createState() => _RecordingModeMenuPageState();
}

class _RecordingModeMenuPageState extends State<RecordingModeMenuPage>
    with WidgetsBindingObserver {
  late BleInput _input;
  final CarouselController _carouselController = CarouselController();
  int songIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _input = context.read<BleInput>();
      _input.addTouchListener(_handleInput);
    });
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
    return Scaffold(
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
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RecordingModePage(
                            song: SongManager.songs[songIndex])));
              },
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
    );
  }

  @override
  void dispose() {
    super.dispose();

    _input.removeTouchListener(_handleInput);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        AudioManager.pauseSong();
        break;
      case AppLifecycleState.resumed:
        // audioManager.player.play();
        break;
      default:
        break;
    }
  }

  onPageChange(int index, CarouselPageChangedReason reason) {
    index = songIndex;
    AudioManager.playClip(index);
  }
}
