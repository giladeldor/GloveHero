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

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final _carouselController = CarouselController();
  SongStatistics _statistics = SongStatistics();

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
                    child: Image.asset("assets/statistics-glove.png"),
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
                ],
          ),
        ),
      ),
    );
  }

  ({double left, double bottom}) _positionOf(Input input) {
    final centerWidth = MediaQuery.of(context).size.width / 2;

    final ({double left, double bottom}) position = switch (input) {
      Input.input1 => (left: centerWidth - 125, bottom: 340),
      Input.input2 => (left: centerWidth - 75, bottom: 370),
      Input.input3 => (left: centerWidth - 22, bottom: 390),
      Input.input4 => (left: centerWidth + 23, bottom: 365),
      _ => (left: 0, bottom: 0)
    };

    return position;
  }

  Color _getPercentColor(int percent) {
    if (percent < 50) {
      return Colors.red;
    } else if (percent < 75) {
      return const Color.fromARGB(255, 254, 183, 78);
    } else if (percent < 90) {
      return Colors.yellow;
    } else {
      return const Color.fromARGB(255, 100, 221, 113);
    }
  }

  Widget _getPercentWidget(int percent, Input input) {
    percent = min(percent, 99);
    return Positioned(
      left: _positionOf(input).left,
      bottom: _positionOf(input).bottom,
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
