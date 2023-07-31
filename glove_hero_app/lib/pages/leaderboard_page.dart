import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:glove_hero_app/models/high_score.dart';
import 'package:glove_hero_app/models/song.dart';
import 'package:glove_hero_app/utils/styles.dart';
import 'package:glove_hero_app/widgets/glove_controls.dart';
import '../models/ble.dart';
import '../models/controller_action.dart';
import '../widgets/song_card.dart';

/// A page that displays the high scores for each song.
class LeaderboardPage extends StatefulWidget {
  LeaderboardPage({super.key, Song? initialSong})
      : initialSong = initialSong ?? SongManager.songs[0];

  final Song initialSong;

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final CarouselController _carouselController = CarouselController();
  Future<SongHighScores> _highScores =
      SongManager.getHighScores(SongManager.songs[0]);

  final List<String> stringFromIndex = ["ST", "ND", "RD", "TH"];

  @override
  void initState() {
    int index = SongManager.songs.indexOf(widget.initialSong);
    _carouselController.onReady
        .then((value) => _carouselController.jumpToPage(index));

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
              image: AssetImage(
                "assets/backgrounds/leaderboard-background.jpg",
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: FittedBox(
                child: Text(
                  "Leaderboard",
                  style: leaderBoardTitle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 0),
              child: Align(
                alignment: Alignment.center,
                child: CarouselSlider(
                  items: SongCard.songs(onPressed: () {
                    _carouselController.nextPage();
                  }),
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    height: 350,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _highScores =
                            SongManager.getHighScores(SongManager.songs[index]);
                      });
                    },
                  ),
                ),
              ),
            ),
            FutureBuilder(
              future: _highScores,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                    child: Table(
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      children: snapshot.data!.scores.indexed.map(
                        (element) {
                          final (index, score) = element;
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  (index + 1).toString() +
                                      stringFromIndex[min(index, 3)],
                                  textAlign: TextAlign.center,
                                  style: highScoreTextStyle,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Center(
                                  child: Text(
                                    score.name,
                                    style: highScoreTextStyle,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Center(
                                  child: Text(_castHighScore(score.score),
                                      style: highScoreTextStyle),
                                ),
                              ),
                            ],
                          );
                        },
                      ).toList()
                        ..insert(
                          0,
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  "RANK",
                                  style: highScoreTitle,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(5),
                                child: Center(
                                  child: Text(
                                    "NAME",
                                    style: highScoreTitle,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(5),
                                child: Center(
                                  child: Text("SCORE", style: highScoreTitle),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ),
                  );
                } else {
                  return const Text("Wait");
                }
              },
            )
          ]),
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
      case MenuAction.back:
        Navigator.of(context).maybePop();
        break;
      default:
        break;
    }
  }

  String _castHighScore(int score) {
    return score == -1 ? "NO HIGH SCORE" : score.toString();
  }
}
