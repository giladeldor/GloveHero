#ifndef _INPUT_H
#define _INPUT_H

#include <Arduino.h>

enum class Input {
    Input1 = 0,
    Input2,
    Input3,
    Input4,
};

template <unsigned int N>
class WorkingSet {
public:
    void update(bool working = false) {
        if (working) {
            counter = N;
            return;
        }

        counter = max(0, counter - 1);
    }

    bool isWorking() const { return counter > 0; }

private:
    int counter = 0;
};

class KeyboardInput {
public:
    void update();

    bool isActive(Input input) const;

private:
    enum class Key { H = 0, J, K, L, Count };

private:
    WorkingSet<5> working_sets[static_cast<int>(Key::Count)];
};

#endif /* _INPUT_H */
