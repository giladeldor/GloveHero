import 'dart:ui';

/// The window in which we consider a touch to be "caught".
const touchOffset = 100;

/// The score for a good touch.
const goodScore = 100;

/// The score for a bad touch.
const badScore = 50;

/// The score for a miss.
const missScore = 0;

/// The color for a good touch.
const goodColor = Color.fromARGB(255, 0, 255, 0);

/// The color for a bad touch.
const badColor = Color.fromARGB(255, 0, 0, 255);

/// The color for a miss.
const missColor = Color.fromARGB(255, 255, 0, 0);

/// The window of time in which we show the touches on the screen.
///
/// Decrease this value to make the touches go faster.
const windowSize = 2500;
