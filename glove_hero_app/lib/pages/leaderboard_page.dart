import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:glove_hero_app/song.dart';
import 'package:glove_hero_app/utils.dart';
import '../widgets/song_card.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final CarouselController _carouselController = CarouselController();
  List<HighScore> _highScores = SongManager.getHighScores(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/leaderboard-menu-background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 0),
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
                    onPageChanged: (index, reason) {
                      setState(() {
                        _highScores = SongManager.getHighScores(index);
                      });
                    },
                  ),
                ),
              )),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 7, horizontal: 0),
              child: FittedBox(
                  child: Text(
                "Leaderboard",
                style: titleTextStyle,
                textAlign: TextAlign.center,
              ))),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 0),
              child: Table(
                border: TableBorder.all(
                    color: const Color.fromARGB(255, 0, 0, 0), width: 1.5),
                children: [
                  TableRow(children: [
                    Center(child: Text(_highScores[0].name)),
                    Center(child: Text(castHighScore(_highScores[0].score))),
                  ]),
                  TableRow(children: [
                    Center(child: Text(_highScores[1].name)),
                    Center(child: Text(castHighScore(_highScores[1].score))),
                  ]),
                  TableRow(children: [
                    Center(child: Text(_highScores[2].name)),
                    Center(child: Text(castHighScore(_highScores[2].score))),
                  ]),
                  TableRow(children: [
                    Center(child: Text(_highScores[3].name)),
                    Center(child: Text(castHighScore(_highScores[3].score))),
                  ]),
                  TableRow(children: [
                    Center(child: Text(_highScores[4].name)),
                    Center(child: Text(castHighScore(_highScores[4].score))),
                  ]),
                  TableRow(children: [
                    Center(child: Text(_highScores[5].name)),
                    Center(child: Text(castHighScore(_highScores[5].score))),
                  ]),
                  TableRow(children: [
                    Center(child: Text(_highScores[6].name)),
                    Center(child: Text(castHighScore(_highScores[6].score))),
                  ]),
                  TableRow(children: [
                    Center(child: Text(_highScores[7].name)),
                    Center(child: Text(castHighScore(_highScores[7].score))),
                  ]),
                  TableRow(children: [
                    Center(child: Text(_highScores[8].name)),
                    Center(child: Text(castHighScore(_highScores[8].score))),
                  ]),
                  TableRow(children: [
                    Center(child: Text(_highScores[9].name)),
                    Center(child: Text(castHighScore(_highScores[9].score))),
                  ])
                ],
              ))
        ]),
      ),
    );
  }
}

String castHighScore(int score) {
  return score == -1 ? "NO HIGH SCORE" : score.toString();
}
