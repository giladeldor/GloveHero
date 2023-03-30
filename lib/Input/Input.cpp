#include "Input.h"

void KeyboardInput ::update() {
    for (auto&& set : working_sets) {
        set.update();
    }

    if (Serial.available()) {
        char c = Serial.read();

        Key key;
        if (c == 'h') {
            key = Key::H;
        } else if (c == 'j') {
            key = Key::J;
        } else if (c == 'k') {
            key = Key::K;
        } else if (c == 'l') {
            key = Key::L;
        } else {
            return;
        }

        working_sets[static_cast<int>(key)].update(true);
    }
}

bool KeyboardInput::isActive(Input input) const {
    Key key = static_cast<Key>(input);

    return working_sets[static_cast<int>(key)].isWorking();
}
