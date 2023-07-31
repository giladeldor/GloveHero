# Glove Hero

> :guitar: Glove Up, Rock On! :rocket:

Glove Hero is a project that helps patients rehabilitate their hands with basic motions.  
The project acts as a gamification of rehabilitation tasks, as the motions are integrated into the game seamlessly.

The project was made from two integrated components:
1. The glove - a custom built glove that acts as the physical medium with which the player (patient) interacts.
2. The app - a Flutter app which allows the player to play a ["Guitar Hero"-like](https://www.youtube.com/watch?v=i50jKW1b8HM&t=70s) game and keep track of scores and statistics regarding their rehabilitaion.

An in-depth explanation of the project can be found in the [project wiki](https://github.com/giladeldor/GloveHero/wiki).

## Team Members

![eran-icon](https://github.com/giladeldor/GloveHero/assets/22302978/1a657363-c950-4d24-a38e-2215eac331c4)&nbsp;&nbsp;&nbsp;![nadav-icon](https://github.com/giladeldor/GloveHero/assets/22302978/b4070950-c4de-4249-8e5f-76873dddab16)&nbsp;&nbsp;&nbsp;![gilad-icon](https://github.com/giladeldor/GloveHero/assets/22302978/27feb8b4-39f7-4a30-988f-33fbe0fa2003)  

## Poster
![image](https://github.com/giladeldor/GloveHero/assets/22302978/626832c3-43cf-4d85-8504-d0f30e9773eb)

## Libraries

### Esp32:
* [Adafruit NeoPixel](https://github.com/adafruit/Adafruit_NeoPixel) - 1.11.0  
  Used for interfacing with the RGB leds on the glove.
* [EspSoftwareSerial](https://registry.platformio.org/libraries/plerup/EspSoftwareSerial) - 8.0.1  
  Used for communicating with the RedMP3 player (not used in the final product).

### Flutter:
* [provider](https://pub.dev/packages/provider) - 6.0.5  
  Used for state management.
* [flutter_reactive_ble](https://pub.dev/packages/flutter_reactive_ble) - 5.0.3  
  Used for BLE communication with the glove.
* [permission_handler](https://pub.dev/packages/permission_handler) - 10.2.0
* [flutter_spinkit](https://pub.dev/packages/flutter_spinkit) - 5.2.0
* [carousel_slider](https://pub.dev/packages/carousel_slider) - 4.2.1
* [just_audio](https://pub.dev/packages/just_audio) - 0.9.33  
  Used for audio management.
* [path_provider](https://pub.dev/packages/path_provider) - 2.0.15
* [circular_countdown_timer](https://pub.dev/packages/circular_countdown_timer)  
  We use [our own fork](https://github.com/ceranco/circular_countdown_timer) which fixes a bug (PR [here](https://github.com/MuhammadUsamaSiddiqui/circular_countdown_timer/pull/56)).
* [flutter_rating_bar](https://pub.dev/packages/flutter_rating_bar) - 4.0.1
* [auto_size_text](https://pub.dev/packages/auto_size_text) - 3.0.0

## Files and folders

* `README.md` - this file.
* `clang-format` - enforces a common coding style for C/C++ files.
* `glove_hero_app/` - contains the source code and assets of the flutter application.
  * `assets/` - contains all the assets for the app.
    * `audio/` - contains all of the audio files (songs) used in the game.
	* `backgrounds/` - contains the background images we use in the various screens of the app.
	* `default-touches/` - contains default recordings for some of the songs in the app.
	* `song-art/` - contains the images displayed for each song.
  * `fonts/` - contains the fonts used in the app.
  * `lib/` - contains the source code of the app.
    * `models/` - contains the logic model of the app.
	* `utils/` - contains various utilities used throughout the app.
	  * `constants.dart` - contains all the constants used in the app.
	* `widgets/` - contains the custom widgets we use in the app.
	* `pages/` - contains the pages that comprise the app.
	  
* `glove_hero_glove/` - contains the assets and firmware for the glove.
  * `assets/GloveHero.fzz` - the fritzing circuit of the glove.
  * `lib/` - the various support libraries and classes used in the firmware.
    * `Parameters/Parameters.h` - all the constants used in the firmware.
	* `Ble/` - abstraction for the BLE communication.
	* `Color/` - color POD.
	* `Input/` - abstraction for handling input (both from the glove and from the keyboard for testing).
	* `LedManager/` - abstraction for interacting with the leds.
	* `PracticeMode/` - implemented the offline practice mode.
	* `RedMP3/` - implements the protocol for communicating with the MP3 player (not used in final project).
	* `Scheduler/` - a very basic task scheduler.
  * `src/main.cpp` - the firmware loop.
  * `test/` - the various tests we used.
    * `ble_test.cpp` - a basic BLE example.
	* `glove_test.cpp` - tests that the glove recognizes touches correctly.
	* `keyboard_test.cpp` - tests that the keyboard input mock works, should be used with the `keyboard_input.py` script.
	* `led_test.cpp` - checks that all of the leds on the glove work correctly.
	* `mp3_test.cpp` - checks that the mp3 works (not used).
	* `ble_app_test/` - a POC test app that comminucates with the ESP32 using BLE.
  * `tools/` - tools we built to help development.
    * `keyboard_input.py` - used to mock the actual touch-pins as input to the ESP32.
	* `upload.sh` - uploads the firmware to the ESP32.
	* `requirements.txt` - the python requirements for the `keyboard_input.py` script, install using `pip`.

