#include <Adafruit_NeoPixel.h>
#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>

#define LED_PIN 5
#define TOUCH_PIN 13
#define NUM_PIXELS 3
#define BAUD_RATE 9600
#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define TOUCH_CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define COLOR_CHARACTERISTIC_UUID "86c7baf6-9d1f-4004-85aa-70aa37e18055"

static Adafruit_NeoPixel pixels(NUM_PIXELS, LED_PIN, NEO_GRB + NEO_KHZ800);
static int idx = 0;
static unsigned long lastUpdate = 0;
static BLECharacteristic* touchCharacteristic;
static BLECharacteristic* colorCharacteristic;
static bool isOn = false;

class Callbacks : public BLEServerCallbacks {
    void onConnect(BLEServer* server, esp_ble_gatts_cb_param_t* param) {
        Serial.println("Connected, Peer MTU size: " +
                       String(server->getPeerMTU(param->connect.conn_id)) +
                       " Server MTU size: " + BLEDevice::getMTU());
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
    colorCharacteristic = service->createCharacteristic(
        COLOR_CHARACTERISTIC_UUID,
        BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE);

    touchCharacteristic->setValue("Hello World");
    uint8_t color[3] = {244, 67, 54};
    colorCharacteristic->setValue(color, 3);
    service->start();

    BLEAdvertising* advertising = BLEDevice::getAdvertising();
    advertising->addServiceUUID(SERVICE_UUID);
    advertising->setScanResponse(true);
    advertising->setMinPreferred(0x06);
    advertising->setMinPreferred(0x12);
    BLEDevice::startAdvertising();

    lastUpdate = millis();
}

void loop() {
    bool touch = touchRead(TOUCH_PIN) == 0;
    if (touch && !isOn) {
        isOn = true;
        touchCharacteristic->setValue("TOUCH");

    } else if (!touch && isOn) {
        isOn = false;
        touchCharacteristic->setValue("RELEASE");

        pixels.clear();
    }

    if (isOn) {
        auto data = colorCharacteristic->getValue();
        uint32_t red = data.c_str()[0];
        uint32_t green = data.c_str()[1];
        uint32_t blue = data.c_str()[2];
        pixels.fill(pixels.Color(red, green, blue));
    }

    auto current = millis();
    if (current - lastUpdate >= 5) {
        lastUpdate = current;
        touchCharacteristic->notify();
    }
    pixels.show();
}