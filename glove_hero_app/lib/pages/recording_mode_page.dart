import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/audio_manager.dart';
import '../models/ble.dart';
import '../models/menu_action.dart';
import '../widgets/song_card.dart';

class RecordingModePage extends StatefulWidget {
  const RecordingModePage({super.key});

  @override
  State<RecordingModePage> createState() => _RecordingModePageState();
}

class _RecordingModePageState extends State<RecordingModePage>
    with WidgetsBindingObserver {
  late BleInput _input;
  final CarouselController _carouselController = CarouselController();
  AudioManager audioManager = AudioManager();

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
            items: SongCard.songs(() {
              print("TEST");
              _carouselController.nextPage();
            }),
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
        audioManager.player.stop();
        break;
      case AppLifecycleState.resumed:
        // audioManager.player.play();
        break;
      default:
        break;
    }
  }

  onPageChange(int index, CarouselPageChangedReason reason) {
    audioManager.playClip(index);
  }
}
