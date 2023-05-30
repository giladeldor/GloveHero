import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:glove_hero_app/models/utils.dart';
import '../widgets/song_card.dart';

class RecordingModePage extends StatefulWidget {
  const RecordingModePage({super.key});

  @override
  State<RecordingModePage> createState() => _RecordingModePageState();
}

class _RecordingModePageState extends State<RecordingModePage> {
  final CarouselController _carouselController = CarouselController();
  AudioManager audioManager = AudioManager();

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

  onPageChange(int index, CarouselPageChangedReason reason) {
    audioManager.playClip(index);
  }
}
