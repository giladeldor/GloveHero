#include <Adafruit_NeoPixel.h>
#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <Input.h>

#define LED_PIN 25
#define NUM_PIXELS 12
#define NUM_PIXELS_PER_INPUT NUM_PIXELS / NUM_INPUTS
#define BAUD_RATE 9600
#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define TOUCH_CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define PINKY_LED_CHARACTERISTIC_UUID "86c7baf6-9d1f-4004-85aa-70aa37e18055"
#define RING_LED_CHARACTERISTIC_UUID "90e39454-d50d-4d86-9595-0e05bd709709"
#define MIDDLE_LED_CHARACTERISTIC_UUID "9bcc732e-c684-42c8-8229-33ba787d7ba6"
#define INDEX_LED_CHARACTERISTIC_UUID "e6297d4b-cfb8-4a9a-a650-3ce33b9cbef0"
#define PINKY 32
#define RING 27
#define MIDDLE 14
#define INDEX 12

static Adafruit_NeoPixel pixels(NUM_PIXELS, LED_PIN, NEO_GRB + NEO_KHZ800);
static int idx = 0;
static BLECharacteristic* touchCharacteristic;
static BLECharacteristic* ledCharacteristics[NUM_INPUTS];
static const char* ledUuids[NUM_INPUTS] = {
    PINKY_LED_CHARACTERISTIC_UUID, RING_LED_CHARACTERISTIC_UUID,
    MIDDLE_LED_CHARACTERISTIC_UUID, INDEX_LED_CHARACTERISTIC_UUID};
static GloveInput glove(PINKY, RING, MIDDLE, INDEX);
// static KeyboardInput glove;
static Input lastInput;

class Callbacks : public BLEServerCallbacks {
    void onConnect(BLEServer* server, esp_ble_gatts_cb_param_t* param) {
        Serial.println("Connected");
        server->updateConnParams(param->connect.remote_bda, 8, 8, 1, 400);
        delay(500);
    }

    void onDisconnect(BLEServer* server) {
        Serial.println("Disconnected");
        BLEDevice::startAdvertising();
    }
};

Callbacks callbacks;

void setup() {
    Serial.begin(BAUD_RATE);
    pixels.begin();
    pixels.setBrightness(30);

    BLEDevice::init("GloveHero");
    BLEDevice::setPower(ESP_PWR_LVL_P9, ESP_BLE_PWR_TYPE_DEFAULT);
    BLEDevice::setPower(ESP_PWR_LVL_P9, ESP_BLE_PWR_TYPE_ADV);
    BLEDevice::setPower(ESP_PWR_LVL_P9, ESP_BLE_PWR_TYPE_SCAN);

    BLEServer* server = BLEDevice::createServer();
    server->setCallbacks(&callbacks);

    BLEService* service = server->createService(SERVICE_UUID);
    touchCharacteristic = service->createCharacteristic(
        TOUCH_CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_READ |
                                       BLECharacteristic::PROPERTY_WRITE |
                                       BLECharacteristic::PROPERTY_NOTIFY);
    int touchValue = static_cast<int>(Input::None);
    touchCharacteristic->setValue(touchValue);

    uint8_t color[3] = {0, 0, 0};
    for (int i = 0; i < NUM_INPUTS; i++) {
        ledCharacteristics[i] = service->createCharacteristic(
            ledUuids[i], BLECharacteristic::PROPERTY_READ |
                             BLECharacteristic::PROPERTY_WRITE);
        ledCharacteristics[i]->setValue(color, 3);
    }

    service->start();

    BLEAdvertising* advertising = BLEDevice::getAdvertising();
    advertising->addServiceUUID(SERVICE_UUID);
    advertising->setScanResponse(true);
    advertising->setMinPreferred(0x06);
    advertising->setMinPreferred(0x12);
    BLEDevice::startAdvertising();
}

void loop() {
    Input input = glove.update();
    if (input != lastInput) {
        lastInput = input;

        int touchValue = static_cast<int>(input);
        touchCharacteristic->setValue(touchValue);
        touchCharacteristic->notify();
    }

    pixels.clear();

    if (input == Input::Input1) {
        pixels.fill(pixels.Color(0, 255, 0), 0, 3);
    } else if (input == Input::Input2) {
        pixels.fill(pixels.Color(255, 0, 0), 3, 3);
    } else if (input == Input::Input3) {
        pixels.fill(pixels.Color(255, 255, 0), 6, 3);
    } else if (input == Input::Input4) {
        pixels.fill(pixels.Color(0, 0, 255), 9, 3);
    }

    // for (int i = 0; i < NUM_INPUTS; i++) {
    //     auto data = ledCharacteristics[i]->getValue();
    //     uint8_t red = data.c_str()[0];
    //     uint8_t green = data.c_str()[1];
    //     uint8_t blue = data.c_str()[2];
    //     if (green > 0)
    //         Serial.println(String(green));

    //     for (int j = 0; j < NUM_PIXELS_PER_INPUT; j++) {
    //         pixels.setPixelColor(i * NUM_PIXELS_PER_INPUT + j,
    //                              pixels.Color(red, green, blue));
    //     }
    // }

    pixels.show();
}