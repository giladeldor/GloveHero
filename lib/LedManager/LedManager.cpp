#include "LedManager.h"
#include <Parameters.h>

LedManager::LedManager(int ledPin)
    : pixels(Adafruit_NeoPixel(NUM_PIXELS, ledPin, NEO_GRB + NEO_KHZ800)) {
    pixels.setBrightness(LED_BRIGHTNESS);
    pixels.begin();
}

void LedManager::fill(const Color& color) {
    fill(color.red, color.green, color.blue);
}

void LedManager::fill(int r, int g, int b) {
    for (size_t i = 0; i < NUM_INPUTS; i++) {
        auto input = static_cast<Input>(i);
        set(input, r, g, b);
    }
}

void LedManager::clear() {
    pixels.clear();
}

void LedManager::clear(Input input) {
    set(input, 0, 0, 0);
}

void LedManager::set(Input input, const Color& color) {
    set(input, color.red, color.green, color.blue);
}

void LedManager::set(Input input, int r, int g, int b) {
    int index = toInt(input);
    if (index == -1)
        return;
    pixels.setPixelColor(index, pixels.Color(r, g, b));
}

void LedManager::show() {
    pixels.show();
}