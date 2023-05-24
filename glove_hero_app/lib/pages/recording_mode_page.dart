import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:glove_hero_app/utils.dart';

class RecordingModePage extends StatefulWidget {
  const RecordingModePage({super.key});

  @override
  State<RecordingModePage> createState() => _RecordingModePageState();
}

class _RecordingModePageState extends State<RecordingModePage> {
  final CarouselController _carouselController = CarouselController();

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
            ),
          ),
        ),
      ),
    );
  }
}

class SongCard extends StatelessWidget {
  const SongCard({
    super.key,
    required this.songName,
    required this.songArtPath,
    this.onPressed,
  });

  final String songName;
  final String songArtPath;
  final void Function()? onPressed;

  static List<SongCard> songs(void Function()? onPressed) => [
        SongCard(
          songName: "4 AM",
          songArtPath: "assets/song-art/4-am.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "All My\nLife",
          songArtPath: "assets/song-art/all-my-life.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "Bad Guy",
          songArtPath: "assets/song-art/bad-guy.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "Bohemian\nRhapsody",
          songArtPath: "assets/song-art/bohemian-rhapsody.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "Come as \nYou Are",
          songArtPath: "assets/song-art/come-as-you-are.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "Company Car",
          songArtPath: "assets/song-art/company-car.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "Freed from\nDesire",
          songArtPath: "assets/song-art/freed-from-desire.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "Good Riddance",
          songArtPath: "assets/song-art/good-riddance.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "I Approached\nIdo",
          songArtPath: "assets/song-art/yes-i-approached-ido.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "In The End",
          songArtPath: "assets/song-art/in-the-end.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "Karma Police",
          songArtPath: "assets/song-art/karma-police.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "Mario Theme",
          songArtPath: "assets/song-art/mario.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "Mr. Shoko",
          songArtPath: "assets/song-art/mr-shoko.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "My Love",
          songArtPath: "assets/song-art/my-love.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "Nothing Else\nMatters",
          songArtPath: "assets/song-art/nothing-else-matters.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "Pokemon",
          songArtPath: "assets/song-art/pokemon.png",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "Seven Nation\nArmy",
          songArtPath: "assets/song-art/seven-nation-army.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "Slaves",
          songArtPath: "assets/song-art/slaves.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "Stairway to\nHeaven",
          songArtPath: "assets/song-art/stairway-to-heaven.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "Staying Alive",
          songArtPath: "assets/song-art/staying-alive.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "The Final\nCountdown",
          songArtPath: "assets/song-art/the-final-countdown.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "Toxic",
          songArtPath: "assets/song-art/toxic.png",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "Under the\nBridge",
          songArtPath: "assets/song-art/under-the-bridge.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "Yo-Ya",
          songArtPath: "assets/song-art/yo-ya.jpg",
          onPressed: onPressed,
        ),
        SongCard(
          songName: "YGLABN",
          songArtPath: "assets/song-art/you-give-love-a-bad-name.jpg",
          onPressed: onPressed,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 250, 250, 230),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    songArtPath,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FittedBox(
                  child: Text(
                    songName,
                    textAlign: TextAlign.center,
                    style: menuButtonTextStyle.copyWith(
                      color: Colors.black,
                      fontSize: 25,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
