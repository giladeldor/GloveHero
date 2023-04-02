#!/usr/bin/env python3

# This script is used to replace the glove as an input for the device.
# Usefull for mocking the glove.
#
# Installation:
#  pip install -r requirements.txt
#
# Usage:
#  ./keyboard_input.py
#
# Use hjkl for inputs 1-4 respectively.
# In the device code use `KeyboardInput` to respond to these events.

from pynput import keyboard
from serial import Serial

serial = Serial("/dev/ttyUSB0", 9600)


def on_press(key):
    try:
        if key.char == "h":
            serial.write(b"h")
        elif key.char == "j":
            serial.write(b"j")
        elif key.char == "k":
            serial.write(b"k")
        elif key.char == "l":
            serial.write(b"l")
    except:
        pass


def on_release(key):
    try:
        if key.char == "h":
            serial.write(b"H")
        elif key.char == "j":
            serial.write(b"J")
        elif key.char == "k":
            serial.write(b"K")
        elif key.char == "l":
            serial.write(b"L")
    except:
        pass


if __name__ == "__main__":
    with keyboard.Listener(on_press=on_press, on_release=on_release) as listener:
        listener.join()
