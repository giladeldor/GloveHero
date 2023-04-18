#ifndef _INPUT_H
#define _INPUT_H

#include <Arduino.h>

// change to pin numbers
#define PINKY 13
#define RING 0
#define MIDDLE 23
#define INDEX 12

int touch_pins[4] = {PINKY, RING, MIDDLE, INDEX};

enum class Input {
    Input1 = 0,
    Input2,
    Input3,
    Input4,
};

enum class InputState {
    Active,
    Inactive,
};

class KeyboardInput {
public:
    KeyboardInput();

    void update();

    InputState inputState(Input input) const;

private:
    enum class Key { H = 0, J, K, L, Count };

private:
    InputState key_state[static_cast<int>(Key::Count)]{};
};

class GloveInput {
public:
    GloveInput(int pinky_pin, int ring_pin, int middle_pin, int index_pin);

    void update();
    InputState inputState(Input input) const;

private:
    enum class Finger { Pinky = 0, Ring, Middle, Index, Count };
    InputState finger_state[static_cast<int>(Finger::Count)]{};
    int pins[static_cast<int>(Finger::Count)];
};

#endif /* _INPUT_H */
