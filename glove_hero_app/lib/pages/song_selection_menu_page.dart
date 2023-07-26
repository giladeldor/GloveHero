import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:glove_hero_app/models/song.dart';
import 'package:glove_hero_app/models/touch.dart';
import 'package:glove_hero_app/pages/single_player_mode_page.dart';
import 'package:provider/provider.dart';
import '../models/audio_manager.dart';
import '../models/ble.dart';
import '../models/controller_action.dart';
import '../utils/styles.dart';
import '../widgets/song_card.dart';
import 'recording_mode_page.dart';

class SongSelectionMenuPage extends StatefulWidget {
  const SongSelectionMenuPage({super.key, required this.isRecordingMode});
  final bool isRecordingMode;

  @override
  State<SongSelectionMenuPage> createState() => _SongSelectionMenuPageState();
}

class _SongSelectionMenuPageState extends State<SongSelectionMenuPage>
    with WidgetsBindingObserver {
  late BleInput _input;
  final CarouselController _carouselController = CarouselController();
  int songIndex = 0;
  late final bool _isRecordingMode;

  @override
  void initState() {
    super.initState();
    _isRecordingMode = widget.isRecordingMode;

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
        break;
      case MenuAction.back:
        Navigator.of(context).pop();
        break;
      default:
        break;
    }
  }

  void redirectToRecording(Song song) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => _Dialog(
        song: song,
      ),
    );
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
                onPressed: () {
                  bool ok = true;
                  AudioManager.stop();
                  if (_isRecordingMode) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RecordingModePage(
                                song: SongManager.songs[songIndex])));
                  } else {
                    SongManager.songs[songIndex].touchFile.then(
                      (file) {
                        try {
                          SongTouches.fromJson(
                              jsonDecode(file.readAsStringSync()));
                        } catch (_) {
                          redirectToRecording(SongManager.songs[songIndex]);
                          ok = false;
                        }
                        if (ok) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SinglePlayerModePage(
                                      song: SongManager.songs[songIndex])));
                        }
                      },
                    );
                  }
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

class _Dialog extends StatelessWidget {
  const _Dialog({
    Key? key,
    required this.song,
  }) : super(key: key);

  final Song song;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      title: const Text(
        "Song Recording Doesn't Exist",
        textAlign: TextAlign.center,
      ),
      titleTextStyle: songSelectionDialogTitleStyle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Would You Like To Record It?",
            textAlign: TextAlign.center,
            style: dialogTextStyle,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecordingModePage(
                        song: song,
                      ),
                    ),
                  );
                },
                child: const Text("Yes"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("No"),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(200, 255, 255, 255),
    );
  }
}
