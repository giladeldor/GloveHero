#ifndef LED_MANAGER_H
#define LED_MANAGER_H

#include <Adafruit_NeoPixel.h>
#include <Color.h>
#include <Input.h>

class LedManager {
    Adafruit_NeoPixel pixels;

public:
    LedManager(int ledPin);

    void fill(const Color& color);
    void fill(int r, int g, int b);

    void clear();
    void clear(Input input);

    void set(Input input, int r, int g, int b);
    void set(Input input, const Color& color);

    void show();
};

#endif