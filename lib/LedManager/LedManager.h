#ifndef LED_MANAGER_H
#define LED_MANAGER_H

#include <Adafruit_NeoPixel.h>
#include <Color.h>
#include <Input.h>

static int toInt(Input input) {
    return static_cast<int>(input);
}

class LedManager {
    Adafruit_NeoPixel pixels;

public:
    LedManager(int ledPin);

    void fillAll(const Color& color);
    void fillAll(int r, int g, int b);

    void fillFinger(Input input, const Color& color);
    void fillFinger(Input input, int r, int g, int b);

    void clearAll();
    void clearFinger(Input input);

    void set(Input input, int pos, int r, int g, int b);
    void set(Input input, int pos, const Color& color);

    void show();
};

#endif