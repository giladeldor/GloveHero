#ifndef COLOR_H
#define COLOR_H

#include <stdint.h>

/// @brief A color POD.
struct Color {
    uint8_t red;
    uint8_t green;
    uint8_t blue;

    /// @brief Construct a new Color object.
    Color(uint8_t red, uint8_t green, uint8_t blue);

    /// @brief Construct a new Color object from the data binary vector.
    static Color fromData(const char* data);
};

#endif