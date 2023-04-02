#ifndef _INPUT_H
#define _INPUT_H

#include <Arduino.h>

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

#endif /* _INPUT_H */
