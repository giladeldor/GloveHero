import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:glove_hero_app/models/song.dart';
import 'package:glove_hero_app/utils/styles.dart';
import '../widgets/song_card.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final CarouselController _carouselController = CarouselController();
  var _highScores = SongManager.getHighScores(SongManager.songs[0]);

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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: FittedBox(
              child: Text(
                "Leaderboard",
                style: titleTextStyle,
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
                      _highScores =
                          SongManager.getHighScores(SongManager.songs[index]);
                    });
                  },
                ),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 0),
              child: Table(
                  border: TableBorder.all(
                      color: const Color.fromARGB(255, 0, 0, 0), width: 1.5),
                  children: _highScores.scores
                      .map(
                        (score) => TableRow(children: [
                          Center(child: Text(score.name)),
                          Center(child: Text(castHighScore(score.score))),
                        ]),
                      )
                      .toList()))
        ]),
      ),
    );
  }
}

String castHighScore(int score) {
  return score == -1 ? "NO HIGH SCORE" : score.toString();
}
