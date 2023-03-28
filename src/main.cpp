#include <Adafruit_NeoPixel.h>

#define LED_PIN 5
#define NUM_PIXELS 3
#define DELAY_VAL 200

Adafruit_NeoPixel pixels(NUM_PIXELS, LED_PIN, NEO_GRB + NEO_KHZ800);

void setup() {
    pixels.setBrightness(30);
    pixels.begin();
}

void loop() {
    pixels.clear();
    pixels.show();

    delay(DELAY_VAL);

    for (int i = 0; i < NUM_PIXELS; i++) {
        pixels.setPixelColor(i, pixels.Color(0, 150, 0));
        pixels.show();

        delay(DELAY_VAL);
    }
}