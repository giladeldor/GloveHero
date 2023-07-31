#include <Adafruit_NeoPixel.h>
#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <Ble.h>
#include <Input.h>
#include <LedManager.h>
#include <Parameters.h>
#include <PracticeMode.h>

enum class State { PracticeMode, Connected };

static GloveInput glove(PINKY_PIN,
                        RING_FINGER_PIN,
                        MIDDLE_FINGER_PIN,
                        INDEX_PIN);
// static KeyboardInput glove;

static Input lastInput;
static State state;
static LedManager ledManager(LED_PIN);
static Ble ble;
static PracticeMode practiceMode;

void setup() {
    Serial.begin(BAUD_RATE);
    practiceMode.setup(&ledManager, &glove);
    ble.setup([&]() { state = State::Connected; },
              [&]() {
                  ble.clearColors();
                  state = State::PracticeMode;
                  practiceMode.startGame();
              });

    state = State::PracticeMode;
    practiceMode.startGame();
}

void loop() {
    if (state == State::Connected) {
        Input input = glove.update();
        if (input != lastInput) {
            lastInput = input;
            ble.setInput(input);
        }

        // Update leds according to characteristics.
        for (int i = 0; i < NUM_INPUTS; i++) {
            Input input = static_cast<Input>(i);
            Color color = ble.getColor(input);
            ledManager.set(input, color);
        }
        ledManager.show();
    }

    else if (state == State::PracticeMode) {
        practiceMode.execute();
    }
}