#ifndef SCHEDULER_H
#define SCHEDULER_H

#include <functional>
#include <vector>

/// @brief A basic task scheduler.
class Scheduler final {
private:
    std::vector<std::pair<std::function<void(long timestamp)>, long>> callbacks;

public:
    /// @brief Clears all of the scheduled tasks.
    void clear();

    /// @brief Executes all of the scheduled tasks that are due.
    /// @param timestamp The current timestamp.
    void execute(long timestamp);

    /// @brief Registers a task to be called at the given timestamp.
    /// @param callback The task to call.
    /// @param timestamp The timestamp to call the task at.
    void registerCallback(std::function<void(long timestamp)> callback,
                          long timestamp);
};

#endif