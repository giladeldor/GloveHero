#ifndef PRACTICE_MODE_H
#define PRACTICE_MODE_H

#include <LedManager.h>
#include <Scheduler.h>
#include <time.h>
#include <array>

enum class ScoreType { Good, Bad, Miss };

class Touch {
public:
    enum class Position { Start, Middle, End };

private:
    long lastUpdate;
    Position position;
    bool valid;

public:
    Touch();

    bool getValid() const;

    void setValid(bool valid, long timestamp);

    bool next(long timestamp);

    ScoreType reactToTouch(Input input, long timestamp);

    Position getPosition() const;
};

class PracticeMode {
private:
    enum class State { Start, End, Game };

private:
    LedManager* ledManager;
    std::array<Touch, 4> touches;
    InputBase* glove;
    Scheduler scheduler;
    long timePerRound;
    long lastUpdate;
    State state;
    Input lastInput;

    std::function<void(long timestamp)> startGameCallback(int iteration);

    std::function<void(long timestamp)> endGameCallback(int iteration);

    std::function<void(long timestamp)> showLightCallback(Input input,
                                                          Color color);

    std::function<void(long timestamp)> clearLightsCallback(Input input);

    std::function<void(long timestamp)> setLightCallback(Input input, int pos);

    std::function<void(long timestamp)> clearLightCallback(Input input,
                                                           int pos);

    void changeToStart(long timestamp);

    void changeToGame(long timestamp);

    void changeToEnd(long timestamp);

    int numActive() const;

    bool shouldAddTouch() const;

    int getInactiveTouchIdx() const;

    void handleTouch(Input input, ScoreType score, long timestamp);

public:
    void setup(LedManager* ledManager, InputBase* glove);

    void startGame();

    void execute();

    void touch(Input input, long timestamp);
};

#endif