#include "Ble.h"

const char* Ble::ledUuids[NUM_INPUTS] = {
    PINKY_LED_CHARACTERISTIC_UUID, RING_LED_CHARACTERISTIC_UUID,
    MIDDLE_LED_CHARACTERISTIC_UUID, INDEX_LED_CHARACTERISTIC_UUID};

void Ble::setup(std::function<void()> onConnect,
                std::function<void()> onDisconnect) {
    this->onConnect = onConnect;
    this->onDisconnect = onDisconnect;

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

void Ble::setInput(Input input) {
    int touchValue = static_cast<int>(input);
    touchCharacteristic->setValue(touchValue);
    touchCharacteristic->notify();
}

Color Ble::getColor(Input input) {
    int index = toInt(input);
    if (index < 0) {
        return Color(0, 0, 0);
    }

    auto data = ledCharacteristics[index]->getValue();
    return Color::fromData(data.c_str());
}
