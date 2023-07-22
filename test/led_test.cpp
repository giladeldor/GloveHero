#include <Adafruit_NeoPixel.h>

#define LED_PIN 26
#define NUM_PIXELS 4
#define BAUD_RATE 9600

Adafruit_NeoPixel pixels(NUM_PIXELS, LED_PIN, NEO_GRB + NEO_KHZ800);

void setup() {
    Serial.begin(BAUD_RATE);

    pixels.setBrightness(30);
    pixels.begin();
}

void loop() {
    pixels.clear();
    pixels.show();

    for (int i = 0; i < NUM_PIXELS; i++) {
        pixels.setPixelColor(
            i, pixels.Color(rand() % 255, rand() % 255, rand() % 255));
    }

    pixels.show();
    delay(500);
}
