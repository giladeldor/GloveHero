#ifndef PARAMETERS_H
#define PARAMETERS_H

// The rate used for serial communication with the ESP32 on the glove (debug
// only).
#define BAUD_RATE 9600

// The pin used for controlling the leds on the glove.
#define LED_PIN 26

// The number of pixels on the glove.
#define NUM_PIXELS 4

// The brightness of the leds on the glove.
#define LED_BRIGHTNESS 20

// The UUIDs used for the BLE service and characteristics.
#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define TOUCH_CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define PINKY_LED_CHARACTERISTIC_UUID "86c7baf6-9d1f-4004-85aa-70aa37e18055"
#define RING_LED_CHARACTERISTIC_UUID "90e39454-d50d-4d86-9595-0e05bd709709"
#define MIDDLE_LED_CHARACTERISTIC_UUID "9bcc732e-c684-42c8-8229-33ba787d7ba6"
#define INDEX_LED_CHARACTERISTIC_UUID "e6297d4b-cfb8-4a9a-a650-3ce33b9cbef0"

// The pins used for the touch sensors on the glove.
#define PINKY_PIN 13
#define RING_FINGER_PIN 12
#define MIDDLE_FINGER_PIN 14
#define INDEX_PIN 27

#endif
