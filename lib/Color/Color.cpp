#include "Color.h"

Color::Color(uint8_t red, uint8_t green, uint8_t blue)
    : red(red), green(green), blue(blue) {}

Color Color::fromData(const char* data) {
    uint8_t red = data[0];
    uint8_t green = data[1];
    uint8_t blue = data[2];

    return Color{
        red,
        green,
        blue,
    };
}