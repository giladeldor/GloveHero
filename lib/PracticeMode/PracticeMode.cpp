#include "PracticeMode.h"

constexpr long defaultTimePerRound = 350 * 3;
constexpr long offset = 150;
constexpr long timePerRoundDiff = 25;
constexpr int maxActive = 3;
constexpr int numStartCallbacks = 5;
constexpr int numEndCallbacks = 7;
constexpr int minTimePerRound = 150;

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
        return [=](long) { ledManager->clear(); };
    }

    return [=](long) {
        for (int j = 0; j < NUM_INPUTS; j++) {
            ledManager->set(static_cast<Input>(j), colors[iteration]);
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
        return [=](long) { ledManager->fill(color.red, 0, 0); };
    }

    return [=](long) { ledManager->clear(); };
}

std::function<void(long timestamp)> PracticeMode::showLightCallback(
    Input input,
    Color color) {
    return [=](long) { ledManager->set(input, color); };
}

std::function<void(long timestamp)> PracticeMode::clearLightsCallback(
    Input input) {
    return [=](long) { ledManager->clear(input); };
}

std::function<void(long timestamp)> PracticeMode::setLightCallback(Input input,
                                                                   int pos) {
    return [=](long) { ledManager->set(input, {255, 255, 255}); };
}

std::function<void(long timestamp)> PracticeMode::clearLightCallback(
    Input input,
    int pos) {
    return [=](long) { ledManager->clear(input); };
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
    scheduler.clear();

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
    return state == State::Game && numActive() < maxActive && rand() % 2 == 0;
}

int PracticeMode::getInactiveTouchIdx() const {
    int counter = rand() % (NUM_INPUTS - numActive());

    for (size_t i = 0; i < NUM_INPUTS; i++) {
        auto&& touch = touches[i];
        if (!touch.getValid() && counter-- == 0) {
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
    ledManager->clear();
    scheduler.clear();

    // Initialize touches.
    for (size_t i = 0; i < touches.size(); i++) {
        touches[i] = Touch();
    }

    changeToStart(timestamp);
}

void PracticeMode::execute() {
    long timestamp = millis();
    scheduler.execute(timestamp);

    if (state == State::Game) {
        Input input = glove->update();
        if (input != lastInput) {
            lastInput = input;
            touch(input, timestamp);
        }

        // New round.
        if (timestamp - lastUpdate >= timePerRound) {
            lastUpdate = timestamp;
            for (size_t i = 0; i < NUM_INPUTS; i++) {
                auto&& touch = touches[i];
                if (touch.getValid() && !touch.next(timestamp)) {
                    changeToEnd(timestamp);
                }
            }

            if (shouldAddTouch()) {
                auto idx = getInactiveTouchIdx();
                touches[idx].setValid(true, timestamp);
                for (int i = 0; i < 3; i++) {
                    scheduler.registerCallback(
                        setLightCallback(static_cast<Input>(idx), i),
                        timestamp + timePerRound * i);
                    scheduler.registerCallback(
                        clearLightCallback(static_cast<Input>(idx), i),
                        timestamp + timePerRound * (i + 1));
                }
            }
        }
    }

    ledManager->show();
}

void PracticeMode::handleTouch(Input input, ScoreType score, long timestamp) {
    Color color = {255, 220, 0};
    if (score == ScoreType::Good) {
        color = {0, 255, 0};
        timePerRound =
            max<int>(minTimePerRound, timePerRound - timePerRoundDiff);
    }

    scheduler.registerCallback(showLightCallback(input, color), timestamp);
    scheduler.registerCallback(clearLightsCallback(input), timestamp + 100);
}

void PracticeMode::touch(Input input, long timestamp) {
    Touch touch = touches[toInt(input)];
    if (!touch.getValid()) {
        changeToEnd(timestamp);
        return;
    }

    ScoreType score = touch.reactToTouch(input, timestamp);
    switch (score) {
        case ScoreType::Miss:
            changeToEnd(timestamp);
            break;

        case ScoreType::Bad:
            handleTouch(input, ScoreType::Bad, timestamp);
            break;

        case ScoreType::Good:
            handleTouch(input, ScoreType::Good, timestamp);
            break;

        default:
            break;
    }

    touch.setValid(false, timestamp);
}

Touch::Touch() : position(Position::Start), valid(false) {}

bool Touch::next(long timestamp) {
    if (!valid || position == Position::End)
        return false;

    lastUpdate = timestamp;
    position = static_cast<Position>(static_cast<int>(position) + 1);
    return true;
}

ScoreType Touch::reactToTouch(Input input, long timestamp) {
    if (position != Position::End)
        return ScoreType::Miss;

    int diff = abs(lastUpdate - timestamp);
    if (diff <= offset / 2)
        return ScoreType::Good;
    if (diff <= offset)
        return ScoreType::Bad;

    return ScoreType::Miss;
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

Touch::Position Touch::getPosition() const {
    return position;
}