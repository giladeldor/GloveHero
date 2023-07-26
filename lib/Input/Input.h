#ifndef _INPUT_H
#define _INPUT_H

#include <Arduino.h>

#define NUM_INPUTS 4

enum class Input { None = -1, Input1, Input2, Input3, Input4 };

static int toInt(Input input) {
    return static_cast<int>(input);
}

static String toString(Input input) {
    switch (input) {
        case Input::Input1:
            return "Input1";
        case Input::Input2:
            return "Input2";
        case Input::Input3:
            return "Input3";
        case Input::Input4:
            return "Input4";
        default:
            return "None";
    }
}

enum class InputState {
    Active,
    Inactive,
};

class InputBase {
public:
    virtual ~InputBase() = default;

    virtual Input update() = 0;

    virtual InputState inputState(Input input) const = 0;
};

class KeyboardInput final : public InputBase {
public:
    KeyboardInput();

    virtual Input update() override;

    virtual InputState inputState(Input input) const override;

private:
    enum class Key { L = 0, K, J, H };

private:
    InputState key_state[NUM_INPUTS];
    Input current;
};

class GloveInput final : public InputBase {
public:
    GloveInput(int pinky_pin, int ring_pin, int middle_pin, int index_pin);

    virtual Input update() override;

    virtual InputState inputState(Input input) const override;

private:
    enum class Finger { Pinky = 0, Ring, Middle, Index };

    InputState finger_state[NUM_INPUTS];
    int pins[NUM_INPUTS];
};

#endif /* _INPUT_H */
