#include <Adafruit_NeoPixel.h>
#include <Parameters.h>

Adafruit_NeoPixel pixels(NUM_PIXELS, LED_PIN, NEO_GRB + NEO_KHZ800);

void setup() {
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
