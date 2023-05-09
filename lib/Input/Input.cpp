#include "Input.h"

KeyboardInput::KeyboardInput() {
    for (size_t i = 0; i < NUM_INPUTS; i++) {
        key_state[i] = InputState::Inactive;
    }
}

Input KeyboardInput::update() {
    Input state = Input::None;

    if (Serial.available()) {
        char c = Serial.read();

        switch (c) {
            case 'h':
                key_state[static_cast<int>(Key::H)] = InputState::Active;
                state = Input::Input1;
                break;
            case 'H':
                key_state[static_cast<int>(Key::H)] = InputState::Inactive;
                break;

            case 'j':
                key_state[static_cast<int>(Key::J)] = InputState::Active;
                state = Input::Input2;
                break;
            case 'J':
                key_state[static_cast<int>(Key::J)] = InputState::Inactive;
                break;

            case 'k':
                key_state[static_cast<int>(Key::K)] = InputState::Active;
                state = Input::Input3;
                break;
            case 'K':
                key_state[static_cast<int>(Key::K)] = InputState::Inactive;
                break;

            case 'l':
                key_state[static_cast<int>(Key::L)] = InputState::Active;
                state = Input::Input4;
                break;
            case 'L':
                key_state[static_cast<int>(Key::L)] = InputState::Inactive;
                break;
        }

        return state;
    }
}

InputState KeyboardInput::inputState(Input input) const {
    Key key = static_cast<Key>(input);

    return key_state[static_cast<int>(key)];
}

GloveInput::GloveInput(int pinky_pin,
                       int ring_pin,
                       int middle_pin,
                       int index_pin) {
    for (size_t i = 0; i < NUM_INPUTS; i++) {
        finger_state[i] = InputState::Inactive;
    }

    pins[static_cast<int>(Finger::Pinky)] = pinky_pin;
    pins[static_cast<int>(Finger::Ring)] = ring_pin;
    pins[static_cast<int>(Finger::Middle)] = middle_pin;
    pins[static_cast<int>(Finger::Index)] = index_pin;
}

Input GloveInput::update() {
    Input state = Input::None;
    for (int i = 0; i < NUM_INPUTS; i++) {
        finger_state[i] =
            touchRead(pins[i]) == 0 ? InputState::Active : InputState::Inactive;
        if (finger_state[i] == InputState::Active) {
            state = static_cast<Input>(i);
        }
    }

    return state;
}

InputState GloveInput::inputState(Input input) const {
    Finger finger = static_cast<Finger>(input);

    return finger_state[static_cast<int>(finger)];
}
