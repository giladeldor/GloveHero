#include "Scheduler.h"
#include <Arduino.h>

void Scheduler::clear() {
    callbacks.clear();
}

void Scheduler::execute(long timestamp) {
    for (size_t i = 0; i < callbacks.size(); i++) {
        if (callbacks[i].second <= timestamp) {
            std::pair<std::function<void(long timestamp)>, long> callbackPair =
                callbacks[i];

            callbacks.erase(callbacks.begin() + i);
            callbackPair.first(timestamp);
            i--;
        }
    }
}

void Scheduler::registerCallback(std::function<void(long timestamp)> callback,
                                 long timestamp) {
    callbacks.push_back({callback, timestamp});
}
