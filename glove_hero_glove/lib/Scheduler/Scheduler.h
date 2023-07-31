#ifndef SCHEDULER_H
#define SCHEDULER_H

#include <functional>
#include <vector>

class Scheduler final {
private:
    std::vector<std::pair<std::function<void(long timestamp)>, long>> callbacks;

public:
    void clear();

    void execute(long timestamp);

    void registerCallback(std::function<void(long timestamp)> callback,
                          long timestamp);
};

#endif