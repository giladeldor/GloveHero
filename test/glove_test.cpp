/*
 * 13: Pinky
 * 12: Ring finger
 * 14: Middle finger
 * 27: Index finger bottom
 */

#include <Parameters.h>
#include "Arduino.h"

std::array<int, 4> pins = {
    PINKY_PIN,
    RING_FINGER_PIN,
    MIDDLE_FINGER_PIN,
    INDEX_PIN,
};

std::array<String, 4> names = {
    "Pinky",
    "Ring finger",
    "Middle finger",
    "Index finger",
};

void setup() {
    Serial.begin(9600);
}

void loop() {
    for (int i = 0; i < pins.size(); i++) {
        Serial.println(String(names[i]) + ": " + String(touchRead(pins[i])));
    }
    Serial.println();
    delay(200);
}