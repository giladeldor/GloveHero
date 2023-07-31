import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:glove_hero_app/models/score.dart';
import 'package:glove_hero_app/models/song.dart';
import 'package:glove_hero_app/models/statistics.dart';
import 'package:glove_hero_app/widgets/glove_controls.dart';

import '../models/controller_action.dart';
import '../utils/styles.dart';
import '../models/ble.dart';
import '../widgets/song_card.dart';

/// A page that displays the statistics for each finger and each song.
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final _carouselController = CarouselController();
  SongStatistics _statistics = SongStatistics();

  @override
  void initState() {
    StatisticsManager.getStatistics(SongManager.songs[0])
        .then((value) => setState(() => _statistics = value));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GloveControls(
      onTouch: _onTouch,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/backgrounds/hills-background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: Input.realValues
                    .map((input) => _getPercentWidget(
                          _statistics.getPercent(input, ScoreType.good) +
                              _statistics.getPercent(input, ScoreType.bad),
                          input,
                        ))
                    .toList() +
                [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: 430,
                      child: Image.asset(
                        "assets/statistics-glove.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0),
                        child: FittedBox(
                          alignment: Alignment.center,
                          child: Text(
                            "Statistics",
                            style: titleTextStyle,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: CarouselSlider(
                          items: SongCard.songs(onPressed: () {
                            _carouselController.nextPage();
                          }),
                          carouselController: _carouselController,
                          options: CarouselOptions(
                            height: 300,
                            aspectRatio: 16 / 9,
                            viewportFraction: 0.8,
                            initialPage: 0,
                            enableInfiniteScroll: true,
                            reverse: false,
                            enlargeCenterPage: true,
                            scrollDirection: Axis.horizontal,
                            onPageChanged: (index, reason) async {
                              _statistics =
                                  await StatisticsManager.getStatistics(
                                SongManager.songs[index],
                              );
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () async {
                            await StatisticsManager.reset();
                            setState(() {
                              _statistics = SongStatistics();
                            });
                          },
                          icon: const Icon(Icons.delete),
                          iconSize: 60,
                          color: const Color.fromARGB(255, 56, 55, 100),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: _positionOfNumPlays().bottom,
                    child: Text(
                      "Plays:\n\n${_statistics.numPlays}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'HighScore'),
                    ),
                  ),
                ],
          ),
        ),
      ),
    );
  }

  ({double left, double bottom}) _positionOfInput(Input input) {
    final centerWidth = MediaQuery.of(context).size.width / 2;

    final ({double left, double bottom}) position = switch (input) {
      Input.input1 => (left: centerWidth - 125, bottom: 300),
      Input.input2 => (left: centerWidth - 75, bottom: 325),
      Input.input3 => (left: centerWidth - 22, bottom: 350),
      Input.input4 => (left: centerWidth + 23, bottom: 325),
      _ => (left: 0, bottom: 0)
    };

    return position;
  }

  ({double? left, double? bottom}) _positionOfNumPlays() {
    return (left: null, bottom: 110);
  }

  Color _getPercentColor(int percent) {
    if (percent < 40) {
      return Colors.red;
    } else if (percent < 60) {
      return const Color.fromARGB(255, 254, 183, 78);
    } else if (percent < 80) {
      return Colors.yellow;
    } else {
      return const Color.fromARGB(255, 100, 221, 113);
    }
  }

  Widget _getPercentWidget(int percent, Input input) {
    percent = min(percent, 99);
    return Positioned(
      left: _positionOfInput(input).left,
      bottom: _positionOfInput(input).bottom,
      child: Text(
        "${percent.toString().padLeft(2, '0')}%",
        style: TextStyle(
            color: _getPercentColor(percent),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'HighScore'),
      ),
    );
  }

  _onTouch(Input input) {
    final action = MenuAction.fromInput(input);

    switch (action) {
      case MenuAction.up:
        _carouselController.nextPage();
        break;
      case MenuAction.down:
        _carouselController.previousPage();
        break;
      case MenuAction.back:
        Navigator.of(context).maybePop();
        break;
      default:
    }
  }
}
