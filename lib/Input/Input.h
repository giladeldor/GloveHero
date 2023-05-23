#ifndef _INPUT_H
#define _INPUT_H

#include <Arduino.h>

#define NUM_INPUTS 4

enum class Input { None = -1, Input1, Input2, Input3, Input4 };

enum class InputState {
    Active,
    Inactive,
};

class KeyboardInput {
public:
    KeyboardInput();

    Input update();

    InputState inputState(Input input) const;

private:
    enum class Key { L = 0, K, J, H };

private:
    InputState key_state[NUM_INPUTS];
    Input current;
};

class GloveInput {
public:
    GloveInput(int pinky_pin, int ring_pin, int middle_pin, int index_pin);

    Input update();

    InputState inputState(Input input) const;

private:
    enum class Finger { Pinky = 0, Ring, Middle, Index };

    InputState finger_state[NUM_INPUTS];
    int pins[NUM_INPUTS];
};

#endif /* _INPUT_H */
