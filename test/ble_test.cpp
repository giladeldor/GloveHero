#include <Adafruit_NeoPixel.h>
#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>

#define LED_PIN 5
#define NUM_PIXELS 3
#define BAUD_RATE 9600
#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define IDX_CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define COLOR_CHARACTERISTIC_UUID "86c7baf6-9d1f-4004-85aa-70aa37e18055"

static Adafruit_NeoPixel pixels(NUM_PIXELS, LED_PIN, NEO_GRB + NEO_KHZ800);
static int counter = 0;
static unsigned long lastUpdate = 0;
static BLECharacteristic* idxCharacteristic;
static BLECharacteristic* colorCharacteristic;

class Callbacks : public BLEServerCallbacks {
    void onConnect(BLEServer* server) { Serial.println("Connected"); }

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
    BLEServer* server = BLEDevice::createServer();
    server->setCallbacks(&callbacks);

    BLEService* service = server->createService(SERVICE_UUID);
    idxCharacteristic = service->createCharacteristic(
        IDX_CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_READ |
                                     BLECharacteristic::PROPERTY_WRITE |
                                     BLECharacteristic::PROPERTY_NOTIFY);
    colorCharacteristic = service->createCharacteristic(
        COLOR_CHARACTERISTIC_UUID,
        BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE);

    idxCharacteristic->setValue("Hello World");
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
    auto current = millis();
    pixels.clear();

    if (current - lastUpdate > 1000) {
        lastUpdate = current;
        int idx = ++counter % 3;

        idxCharacteristic->setValue(String(idx).c_str());
        idxCharacteristic->notify();
    }

    auto data = colorCharacteristic->getValue();
    uint32_t red = data.c_str()[0];
    uint32_t green = data.c_str()[1];
    uint32_t blue = data.c_str()[2];

    String str;
    str += "Red: ";
    str += red;
    str += "\nGreen: ";
    str += green;
    str += "\nBlue: ";
    str += blue;
    str += "\n";

    Serial.println(str);
    int idx = counter % 3;
    pixels.setPixelColor(idx, pixels.Color(red, green, blue));

    pixels.show();
}