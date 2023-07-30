import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/styles.dart';
import '../models/ble.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/hills-background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: List.generate(
                Input.values.length - 1,
                (index) => _getPercentWidget(0, Input.values[index + 1]),
              ) +
              [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset("assets/statistics-glove.png"),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FittedBox(
                        alignment: Alignment.center,
                        child: Text(
                          "Statistics",
                          style: titleTextStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
}
