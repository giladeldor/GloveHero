#ifndef LED_MANAGER_H
#define LED_MANAGER_H

#include <Adafruit_NeoPixel.h>
#include "../Input/Input.h"

#define LED_PIN 5
#define NUM_PIXELS 12

static int toInt(Input input) {
    return static_cast<int>(input);
}

class LedManager {
    Adafruit_NeoPixel pixels;

    public:
        LedManager() : pixels(Adafruit_NeoPixel(NUM_PIXELS, LED_PIN, NEO_GRB + NEO_KHZ800)) {
            pixels.setBrightness(30);
            pixels.begin();
        }

        void fillFinger(Input input, int r = 0, int g = 0, int b = 0) {
            int index = toInt(input);
            if (index == -1) return;
            pixels.fill(pixels.Color(r, g, b), index * 3, 3);
            pixels.show();
        }

        void clearFinger(Input input) {
            int index = toInt(input);
            if (index == -1) return;
            pixels.fill(index * 3, 3);
            pixels.show();
        }

        void clearAll() {
            pixels.clear();
            pixels.show();            
        }

        void set(Input input, int pos, int r = 0, int g = 0, int b = 0) {
            int index = toInt(input);
            if (index == -1) return;
            pixels.setPixelColor(index * 3 + pos, pixels.Color(r, g, b));
        }
};

#endif