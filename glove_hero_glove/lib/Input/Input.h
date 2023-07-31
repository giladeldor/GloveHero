#ifndef _INPUT_H
#define _INPUT_H

#include <Arduino.h>

#define NUM_INPUTS 4

/// @brief The inputs on the glove.
enum class Input {
    None = -1,
    Input1,
    Input2,
    Input3,
    Input4,
};

/// @brief Converts an input to it's integer representation.
/// @param input The input to convert.
/// @return The integer representation of the input.
static int toInt(Input input) {
    return static_cast<int>(input);
}

/// @brief Converts an input to it's string representation.
/// @param input The input to convert.
/// @return The string representation of the input.
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

/// @brief The possible states of an input.
enum class InputState {
    Active,
    Inactive,
};

/// @brief Base class for input-manager classes.
class InputBase {
public:
    virtual ~InputBase() = default;

    /// @brief Update the input state and return the current input.
    /// @return The current input.
    virtual Input update() = 0;

    /// @brief Get the input state of the given input.
    virtual InputState inputState(Input input) const = 0;
};

/// @brief A mock input manager for input given from keyboard over serial.
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

/// @brief The input manager for the glove itself, using the touch pins.
class GloveInput final : public InputBase {
public:
    /// @brief Construct a new GloveInput object.
    /// @param pinky_pin The touch pin for the pinky.
    /// @param ring_pin The touch pin for the ring finger.
    /// @param middle_pin The touch pin for the middle finger.
    /// @param index_pin The touch pin for the index finger.
    GloveInput(int pinky_pin, int ring_pin, int middle_pin, int index_pin);

    virtual Input update() override;

    virtual InputState inputState(Input input) const override;

private:
    enum class Finger { Pinky = 0, Ring, Middle, Index };

    InputState finger_state[NUM_INPUTS];
    int pins[NUM_INPUTS];
};

#endif /* _INPUT_H */
