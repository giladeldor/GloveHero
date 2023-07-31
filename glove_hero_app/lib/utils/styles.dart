import 'package:flutter/material.dart';
import '../models/ble.dart';

/// The various styles used throughout the app.

const titleTextStyle = TextStyle(
  fontFamily: "Karmatic",
  fontSize: 45,
  color: Color.fromARGB(255, 255, 240, 254),
);

const menuButtonTextStyle = TextStyle(
  fontFamily: "Karmatic",
  fontSize: 30,
  color: Color.fromARGB(255, 242, 255, 235),
);

const menuButtonDisabledTextStyle = TextStyle(
  fontFamily: "Karmatic",
  fontSize: 30,
  color: Colors.grey,
);

const dialogTitleStyle = TextStyle(
  fontFamily: "Dialog",
  fontSize: 75,
  color: Colors.black,
);

const dialogTextStyle = TextStyle(
  fontFamily: "Dialog",
  fontSize: 35,
  color: Colors.black,
);

const Map<Input, Color> inputColors = {
  Input.input1: Colors.green,
  Input.input2: Colors.red,
  Input.input3: Colors.yellow,
  Input.input4: Colors.blue,
};

const songSelectionDialogTitleStyle = TextStyle(
  fontFamily: "Dialog",
  fontSize: 50,
  color: Colors.red,
);

const highScoreTextStyle = TextStyle(
  fontFamily: "HighScore",
  fontSize: 15,
  color: Colors.white,
);

const highScoreTitle = TextStyle(
  fontFamily: "HighScore",
  fontSize: 17,
  color: Colors.white,
  fontWeight: FontWeight.w600,
  decoration: TextDecoration.underline,
  decorationThickness: 2.5,
);

const leaderBoardTitle = TextStyle(
  fontFamily: "Karmatic",
  fontSize: 45,
  fontWeight: FontWeight.bold,
  color: Color.fromARGB(255, 0, 0, 0), // eran is not satisfied
);
