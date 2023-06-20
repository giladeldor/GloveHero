#include "PracticeMode.h"

constexpr long defaultTimePerRound = 1000;
constexpr long offset = 150;
constexpr long timePerRoundDiff = 25;
constexpr int maxActive = 3;
constexpr int numStartCallbacks = 5;
constexpr int numEndCallbacks = 7;

std::function<void(long timestamp)> PracticeMode::startGameCallback(
    int iteration) {
    static std::array<Color, 3> colors = {
        Color(255, 0, 0),
        Color(255, 220, 0),
        Color(0, 255, 0),
    };

    if (iteration == 4) {
        return [=](long timestamp) { changeToGame(timestamp); };
    }

    if (iteration == 3) {
        return [=](long) { ledManager->clearAll(); };
    }

    return [=](long) {
        for (int j = 0; j < NUM_INPUTS; j++) {
            ledManager->set(static_cast<Input>(j), iteration,
                            colors[iteration]);
        }
    };
}

std::function<void(long timestamp)> PracticeMode::endGameCallback(
    int iteration) {
    static const Color color(255, 0, 0);

    if (iteration == numEndCallbacks - 1) {
        return [=](long timestamp) { startGame(); };
    }

    if (iteration % 2 == 0) {
        return [=](long) { ledManager->fillAll(color.red, 0, 0); };
    }

    return [=](long) { ledManager->clearAll(); };
}

void PracticeMode::changeToStart(long timestamp) {
    state = State::Start;

    for (int i = 0; i < numStartCallbacks; i++) {
        scheduler.registerCallback(startGameCallback(i), timestamp + i * 750);
    }
}

void PracticeMode::changeToGame(long timestamp) {
    state = State::Game;
    lastUpdate = timestamp;
}

void PracticeMode::changeToEnd(long timestamp) {
    state = State::End;

    for (int i = 0; i < numEndCallbacks; i++) {
        scheduler.registerCallback(endGameCallback(i), timestamp + i * 500);
    }
}

int PracticeMode::numActive() const {
    int counter = 0;
    for (auto&& touch : touches) {
        if (touch.getValid())
            counter++;
    }

    return counter;
}

bool PracticeMode::shouldAddTouch() const {
    return numActive() < maxActive && rand() % 10 < 7;
}

int PracticeMode::getInactiveTouchIdx() const {
    int counter = rand() % (NUM_INPUTS - numActive());

    for (size_t i = 0; i < NUM_INPUTS; i++) {
        auto&& touch = touches[i];
        if (touch.getValid() && counter-- == 0) {
            return i;
        }
    }

    return 0;
}

void PracticeMode::setup(LedManager* ledManager, InputBase* glove) {
    this->ledManager = ledManager;
    this->glove = glove;
}

void PracticeMode::startGame() {
    long timestamp = millis();
    timePerRound = defaultTimePerRound;
    ledManager->clearAll();
    scheduler.clear();

    // Initialize touches.
    for (size_t i = 0; i < touches.size(); i++) {
        touches[i] = {};
    }

    changeToStart(timestamp);
}

void PracticeMode::execute() {
    long timestamp = millis();
    scheduler.execute(timestamp);

    if (state == State::Game) {
        changeToEnd(timestamp);
        // New round.
        // if (timestamp - lastUpdate > timePerRound) {
        //     lastUpdate = timestamp;
        // return;
        // for (size_t i = 0; i < NUM_INPUTS; i++) {
        //     auto&& touch = touches[i];
        //     if (touch.getValid() && !touch.next(timestamp)) {
        //         changeToEnd(timestamp);
        //     }
        // }

        // if (shouldAddTouch()) {
        //     auto idx = getInactiveTouchIdx();
        //     touches[idx].setValid(true, timestamp);
        // }
        // }
    }

    ledManager->show();
}

bool PracticeMode::detectTouch() {
    // Input input = glove.update();
    // if (input != Input::None)
    //     return reactToTouch(input);

    // return false;
}

bool PracticeMode::reactToTouch(Input input) {
    // int index = static_cast<int>(input);
    // if (!touches[index])
    //     return true;

    // ScoreType score = touches[index]->reactToTouch();
    // return reactToTouch(input, score);
}

bool PracticeMode::reactToTouch(Input input, ScoreType scoreType) {
    // int r, g, b;
    // if (scoreType == ScoreType::Miss) {
    //     ledManager.fillFinger(input, 255, 0, 0);
    //     return true;
    // } else if (scoreType == ScoreType::Bad) {
    //     r = 219, g = 255, b = 51;
    // } else {
    //     r = 51, g = 255, b = 87;
    // }
    // ledManager.fillFinger(input, r, g, b);
    // return false;
}

void PracticeMode::addTouch() {
    // Touch* touch = new Touch();
    // if (touches[static_cast<int>(touch->getInput())]) {
    //     delete touch;
    //     return;
    // }

    // touches[static_cast<int>(touch->getInput())] = touch;
}

void PracticeMode::passedRound() {
    // for (int i = 0; i < 0; i++) {
    //     if (touches[i]) {
    //         ledManager.clearFinger(static_cast<Input>(i));
    //         touches[i]->passedRound();
    //         ledManager.set(touches[i]->getInput(),
    //                        2 - touches[i]->getRoundsToTouch(), 0, 0, 0);
    //     }
    // }
    // ledManager.show();
}

Touch::Touch() : position(Position::Start), valid(false) {}

bool Touch::next(long timestamp) {
    if (!valid || position == Position::End)
        return false;

    lastUpdate = timestamp;
    position = static_cast<Position>(static_cast<int>(position) + 1);
    return true;
}

void Touch::setValid(bool valid, long timestamp) {
    this->valid = valid;

    if (valid) {
        lastUpdate = timestamp;
        position = Position::Start;
    }
}

bool Touch::getValid() const {
    return valid;
}

ScoreType Touch::reactToTouch(long timestamp) {
    if (position != Position::End)
        return ScoreType::Miss;

    long diff = abs(timestamp - lastUpdate);
    if (diff <= offset / 2)
        return ScoreType::Good;

    if (diff <= offset)
        return ScoreType::Bad;

    return ScoreType::Miss;
}

Touch::Position Touch::getPosition() const {
    return position;
}