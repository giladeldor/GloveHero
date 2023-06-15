#ifndef GAME_MANAGER_H
#define GAME_MANAGER_H

#include "LedManager.h"
#define BAUD_RATE 9600

enum class ScoreType { Miss = 0, Bad, Good };

class GameManager {
    LedManager ledManager;
    int milliPerLed;

    public:
        GameManager() : ledManager(LedManager()) {}
        
        void startGame() {
            Serial.begin(BAUD_RATE);
            ledManager.clearAll();
            // TODO: add starting milliPerLed, offset
            // TODO: add light to start game
            delay(1000); // delay the start of the game so the player can prepare
        }

        void reactToTouch(Input input, ScoreType scoreType) {
            if (input == Input::None) return;

            int r, g, b;
            if (scoreType == ScoreType::Miss) {
                // TODO: add red lights
                startGame();
                return;
            } else if (scoreType == ScoreType::Bad) {
                r = 219, g = 255, b = 51;
            } else {
                r = 51, g = 255, b = 87;
            }

            ledManager.fillFinger(input, r, g, b);
        }

        void addTouch() {

        }
};

#endif