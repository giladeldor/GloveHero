#ifndef BLE_H
#define BLE_H

#include <BLEDevice.h>
#include <Color.h>
#include <Input.h>
#include <Parameters.h>
#include <functional>

class Ble {
    static const char* ledUuids[NUM_INPUTS];

    BLECharacteristic* touchCharacteristic;
    BLECharacteristic* ledCharacteristics[NUM_INPUTS];
    std::function<void()> onConnect = []() {};
    std::function<void()> onDisconnect = []() {};

    class Callbacks : public BLEServerCallbacks {
    private:
        Ble* ble;

    public:
        Callbacks(Ble* ble) : ble(ble) {}

        void onConnect(BLEServer* server, esp_ble_gatts_cb_param_t* param) {
            Serial.println("Connected");
            server->updateConnParams(param->connect.remote_bda, 8, 8, 1, 400);
            ble->onConnect();
            delay(500);
        }

        void onDisconnect(BLEServer* server) {
            Serial.println("Disconnected");
            BLEDevice::startAdvertising();
            ble->onDisconnect();
        }
    };
    Callbacks callbacks{this};

public:
    void setup(std::function<void()> onConnect,
               std::function<void()> onDisconnect);

    void setInput(Input input);

    Color getColor(Input input, int index);
};

#endif