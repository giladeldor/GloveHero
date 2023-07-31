#ifndef LED_MANAGER_H
#define LED_MANAGER_H

#include <Adafruit_NeoPixel.h>
#include <Color.h>
#include <Input.h>

/// @brief Manages the LEDs on the glove.
class LedManager {
    Adafruit_NeoPixel pixels;

public:
    /// @brief Construct a new LedManager object.
    /// @param ledPin The data pin that the LEDs are connected to.
    LedManager(int ledPin);

    /// @brief Fills all of the LEDs with the given color.
    /// @param color The color to fill the LEDs with.
    void fill(const Color& color);
    /// @brief Fills all of the LEDs with the given color.
    /// @param r The red component of the color.
    /// @param g The green component of the color.
    /// @param b The blue component of the color.
    void fill(int r, int g, int b);

    /// @brief Clear all of the LEDs.
    void clear();
    /// @brief Clears the LED matching the given input.
    /// @param input The input to clear the LED for.
    void clear(Input input);

    /// @brief Sets the color of the LED matching the given input.
    /// @param input The input to set the color for.
    /// @param r The red component of the color.
    /// @param g The green component of the color.
    /// @param b The blue component of the color.
    void set(Input input, int r, int g, int b);
    /// @brief Sets the color of the LED matching the given input.
    /// @param input The input to set the color for.
    /// @param color The color to set the LED to.
    void set(Input input, const Color& color);

    /// @brief Shows the colors on the LEDs according to the various fill, clear
    /// and set calls.
    void show();
};

#endif