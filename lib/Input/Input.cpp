#include "Input.h"

KeyboardInput::KeyboardInput() {
    for (size_t i = 0; i < static_cast<int>(Key::Count); i++) {
        key_state[i] = InputState::Inactive;
    }
}

void KeyboardInput::update() {
    if (Serial.available()) {
        char c = Serial.read();

        switch (c) {
            case 'h':
                key_state[static_cast<int>(Key::H)] = InputState::Active;
                break;
            case 'H':
                key_state[static_cast<int>(Key::H)] = InputState::Inactive;
                break;

            case 'j':
                key_state[static_cast<int>(Key::J)] = InputState::Active;
                break;
            case 'J':
                key_state[static_cast<int>(Key::J)] = InputState::Inactive;
                break;

            case 'k':
                key_state[static_cast<int>(Key::K)] = InputState::Active;
                break;
            case 'K':
                key_state[static_cast<int>(Key::K)] = InputState::Inactive;
                break;

            case 'l':
                key_state[static_cast<int>(Key::L)] = InputState::Active;
                break;
            case 'L':
                key_state[static_cast<int>(Key::L)] = InputState::Inactive;
                break;
        }
    }
}

InputState KeyboardInput::inputState(Input input) const {
    Key key = static_cast<Key>(input);

    return key_state[static_cast<int>(key)];
}

GloveInput::GloveInput() {
    for (size_t i = 0; i < static_cast<int>(Finger::Count); i++) {
        finger_state[i] = InputState::Inactive;
    }
}

void GloveInput::update() {
    if (Serial.available()) {
        char c = Serial.read();

        switch (c) {
            case 'p':
                finger_state[static_cast<int>(Finger::P)] = InputState::Active;
                break;
            case 'P':
                finger_state[static_cast<int>(Finger::P)] =
                    InputState::Inactive;
                break;

            case 'r':
                finger_state[static_cast<int>(Finger::R)] = InputState::Active;
                break;
            case 'R':
                finger_state[static_cast<int>(Finger::R)] =
                    InputState::Inactive;
                break;

            case 'm':
                finger_state[static_cast<int>(Finger::M)] = InputState::Active;
                break;
            case 'M':
                finger_state[static_cast<int>(Finger::M)] =
                    InputState::Inactive;
                break;

            case 'i':
                finger_state[static_cast<int>(Finger::I)] = InputState::Active;
                break;
            case 'I':
                finger_state[static_cast<int>(Finger::I)] =
                    InputState::Inactive;
                break;
        }
    }
}

InputState GloveInput::inputState(Input input) const {
    Finger finger = static_cast<Finger>(input);

    return finger_state[static_cast<int>(finger)];
}
