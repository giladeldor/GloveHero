#include <Adafruit_NeoPixel.h>
#include <Input.h>

#define LED_PIN 5
#define NUM_PIXELS 3
#define BAUD_RATE 9600

Adafruit_NeoPixel pixels(NUM_PIXELS, LED_PIN, NEO_GRB + NEO_KHZ800);
KeyboardInput input;

void setup() {
    Serial.begin(BAUD_RATE);

    pixels.setBrightness(30);
    pixels.begin();
}

void loop() {
    input.update();

    pixels.clear();
    pixels.show();

    if (input.inputState(Input::Input1) == InputState::Active) {
        pixels.setPixelColor(0, pixels.Color(150, 0, 0));
    }
    if (input.inputState(Input::Input2) == InputState::Active) {
        pixels.setPixelColor(1, pixels.Color(0, 150, 0));
    }
    if (input.inputState(Input::Input3) == InputState::Active) {
        pixels.setPixelColor(2, pixels.Color(0, 0, 150));
    }

    pixels.show();
    delay(20);
}
