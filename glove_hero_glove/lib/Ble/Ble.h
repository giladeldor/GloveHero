#ifndef _BLE_H
#define _BLE_H

#include <BLEDevice.h>
#include <Color.h>
#include <Input.h>
#include <Parameters.h>
#include <functional>

/// @brief BLE interface for the GloveHero.
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
    /// @brief Setup the BLE server.
    /// @param onConnect call this function when a device connects.
    /// @param onDisconnect call this function when a device disconnects.
    void setup(std::function<void()> onConnect,
               std::function<void()> onDisconnect);

    /// @brief Sets the advertised input state.
    /// @param input
    void setInput(Input input);

    /// @brief Clears all of the colors on the glove.
    void clearColors();

    /// @brief Gets the color for the LED of the given input.
    /// @param input The input to get the color for.
    /// @return The color of the LED.
    Color getColor(Input input);
};

#endif /* _BLE_H */
