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

    ScoreType reactToTouch(long timestamp);

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

    std::function<void(long timestamp)> startGameCallback(int iteration);

    std::function<void(long timestamp)> endGameCallback(int iteration);

    void changeToStart(long timestamp);

    void changeToGame(long timestamp);

    void changeToEnd(long timestamp);

    int numActive() const;

    bool shouldAddTouch() const;

    int getInactiveTouchIdx() const;

public:
    void setup(LedManager* ledManager, InputBase* glove);

    void startGame();

    void execute();

    bool detectTouch();

    bool reactToTouch(Input input);

    bool reactToTouch(Input input, ScoreType scoreType);

    void addTouch();

    void passedRound();
};

#endif