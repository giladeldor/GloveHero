#include "RedMP3.h"

#define TX 5
#define RX 19

RedMP3 player(RX, TX);

void setup() {
    Serial.begin(9600);
    player.setVolume(15);
}

void loop() {
    if (Serial.available()) {
        char key = (char)Serial.read();
        if (key == '1') {
            player.playWithFileName(1, 1);
        } else if (key == '2') {
            player.playWithFileName(1, 2);
        } else if (key == 'p') {
            player.pause();
        } else if (key == 'c') {
            player.play();
        } else if (key == 'w') {
            player.volumeUp();
        } else if (key == 's') {
            player.volumeDown();
        }
    }
}