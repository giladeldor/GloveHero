#ifndef PRACTICE_MODE_H
#define PRACTICE_MODE_H

#include <LedManager.h>
#include <Scheduler.h>
#include <time.h>
#include <array>

enum class ScoreType { Hit, Miss };

static inline String toString(ScoreType score) {
    switch (score) {
        case ScoreType::Hit:
            return "Hit";
        case ScoreType::Miss:
            return "Miss";
        default:
            return "Unknown";
    }
}

class TouchStage {
private:
    int stage = 0;
    static constexpr int numStages = 4;
    static std::array<Color, numStages> colors;

public:
    static constexpr int getNumStages();

    bool next();

    int getStage() const;

    bool readyToTouch() const;

    bool missed() const;

    const Color& getColor() const;

    static const Color& getColor(int stage);
};

class Touch {
private:
    TouchStage stage;
    bool valid;

public:
    Touch();

    bool getValid() const;

    void setValid(bool valid);

    bool next(long timestamp);

    ScoreType reactToTouch(long timestamp) const;

    const Color& getColor() const;

    const TouchStage& getStage() const;
};

class PracticeMode {
private:
    enum class State { Start, End, Game };
    static Color missColor;

private:
    LedManager* ledManager;
    std::array<Touch, NUM_INPUTS> touches;
    InputBase* glove;
    Scheduler scheduler;
    long timePerRound;
    long lastUpdate;
    State state;
    Input lastInput;

    using Callback = std::function<void(long timestamp)>;

    Callback clearCallback();
    Callback fillColorCallback(Color color);

    void changeToStart(long timestamp);

    void changeToGame(long timestamp);

    void changeToEnd(long timestamp);

    int numActive() const;

    bool shouldAddTouch() const;

    int getInactiveTouchIdx() const;

    void handleTouch(Input input, long timestamp);

    void touch(Input input, long timestamp);

public:
    void setup(LedManager* ledManager, InputBase* glove);

    void startGame();

    void execute();
};

#endif