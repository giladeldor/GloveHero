#include "LedManager.h"

constexpr int numPixels = 12;

LedManager::LedManager(int ledPin)
    : pixels(Adafruit_NeoPixel(numPixels, ledPin, NEO_GRB + NEO_KHZ800)) {
    pixels.setBrightness(18);
    pixels.begin();
}

void LedManager::fillAll(const Color& color) {
    fillAll(color.red, color.green, color.blue);
}

void LedManager::fillAll(int r, int g, int b) {
    for (size_t i = 0; i < NUM_INPUTS; i++) {
        auto input = static_cast<Input>(i);
        fillFinger(input, r, g, b);
    }
}

void LedManager::fillFinger(Input input, const Color& color) {
    fillFinger(input, color.red, color.green, color.blue);
}

void LedManager::fillFinger(Input input, int r, int g, int b) {
    int index = toInt(input);
    if (index == -1)
        return;
    pixels.fill(pixels.Color(r, g, b), index * 3, 3);
}

void LedManager::clearAll() {
    pixels.clear();
}

void LedManager::clearFinger(Input input) {
    int index = toInt(input);
    if (index == -1)
        return;
    pixels.fill(index * 3, 3);
}

void LedManager::set(Input input, int pos, const Color& color) {
    set(input, pos, color.red, color.green, color.blue);
}

void LedManager::set(Input input, int pos, int r, int g, int b) {
    int index = toInt(input);
    if (index == -1)
        return;
    pixels.setPixelColor(index * 3 + pos, pixels.Color(r, g, b));
}

void LedManager::show() {
    pixels.show();
}