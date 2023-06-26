#include "Input.h"

KeyboardInput::KeyboardInput() {
    current = Input::None;
    for (size_t i = 0; i < NUM_INPUTS; i++) {
        key_state[i] = InputState::Inactive;
    }
}

Input KeyboardInput::update() {
    if (Serial.available()) {
        char c = Serial.read();

        switch (c) {
            case 'l':
                key_state[static_cast<int>(Key::L)] = InputState::Active;
                current = Input::Input1;
                break;
            case 'L':
                key_state[static_cast<int>(Key::L)] = InputState::Inactive;
                current = Input::None;
                break;

            case 'k':
                key_state[static_cast<int>(Key::K)] = InputState::Active;
                current = Input::Input2;
                break;
            case 'K':
                key_state[static_cast<int>(Key::K)] = InputState::Inactive;
                current = Input::None;
                break;

            case 'j':
                key_state[static_cast<int>(Key::J)] = InputState::Active;
                current = Input::Input3;
                break;
            case 'J':
                key_state[static_cast<int>(Key::J)] = InputState::Inactive;
                current = Input::None;
                break;

            case 'h':
                key_state[static_cast<int>(Key::H)] = InputState::Active;
                current = Input::Input4;
                break;
            case 'H':
                key_state[static_cast<int>(Key::H)] = InputState::Inactive;
                current = Input::None;
                break;
        }
    }
    return current;
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
            touchRead(pins[i]) < 15 ? InputState::Active : InputState::Inactive;
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
