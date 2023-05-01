#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>

#define TOUCH_PIN 32

#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

class Callbacks : public BLEServerCallbacks {
    void onConnect(BLEServer* server) { Serial.println("Connected"); }

    void onDisconnect(BLEServer* server) { Serial.println("Disconnected"); }
};

Callbacks callbacks;

void setup() {
    Serial.begin(9600);
    Serial.println("Starting BLE work!");

    BLEDevice::init("GloveHero");
    BLEServer* server = BLEDevice::createServer();
    server->setCallbacks(&callbacks);
    BLEService* service = server->createService(SERVICE_UUID);
    BLECharacteristic* characteristic = service->createCharacteristic(
        CHARACTERISTIC_UUID,
        BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE);

    characteristic->setValue("Hello World");
    service->start();

    BLEAdvertising* advertising = BLEDevice::getAdvertising();
    advertising->addServiceUUID(SERVICE_UUID);
    advertising->setScanResponse(true);
    advertising->setMinPreferred(0x06);
    advertising->setMinPreferred(0x12);
    BLEDevice::startAdvertising();

    Serial.println("Finished setting up.");
}

void loop() {
    delay(200);
}