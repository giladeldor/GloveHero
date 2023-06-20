#ifndef COLOR_H
#define COLOR_H

#include <stdint.h>

struct Color {
    uint8_t red;
    uint8_t green;
    uint8_t blue;

    Color(uint8_t red, uint8_t green, uint8_t blue);

    static Color fromData(const char* data);
};

#endif