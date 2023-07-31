# Glove Hero

> :guitar: Glove Up, Rock On! :rocket:

Glove Hero is a project that helps patients rehabilitate their hands with basic motions.  
The project acts as a gamification of the rehabilitation tasks, as the motions are integrated into the game seamlessly.

The project built from two integrated components:
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
