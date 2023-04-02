/*
 * 33: Ring finger (broken)
 * 25: Middle finger
 * 12: Index finger top
 * 14: Thumb
 * 27: Index finger bottom
 */

#include "Arduino.h"

#define TOUCH_PIN 32

void setup() {
    Serial.begin(9600);
}

void loop() {
    Serial.println(touchRead(TOUCH_PIN));
    delay(200);
}