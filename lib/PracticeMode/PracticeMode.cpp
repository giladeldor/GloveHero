#include "PracticeMode.h"

constexpr long defaultTimePerRound = 350 * 3;
constexpr long timePerRoundDiff = 25;
constexpr int maxActive = 3;
constexpr int numEndGameFlashes = 3;
constexpr int minTimePerRound = 300;

std::array<Color, TouchStage::numStages> TouchStage::colors = {
    Color(255, 40, 0),
    Color(0, 130, 130),
    Color(0, 255, 0),
    Color(0, 0, 0),
};

Color PracticeMode::missColor = {255, 0, 0};

constexpr int TouchStage::getNumStages() {
    return numStages;
}

bool TouchStage::next() {
    stage = min<int>(stage + 1, numStages - 1);
    return !missed();
}

int TouchStage::getStage() const {
    return stage;
}

bool TouchStage::readyToTouch() const {
    return stage == numStages - 2;
}

bool TouchStage::missed() const {
    return stage == numStages - 1;
}

const Color& TouchStage::getColor() const {
    return getColor(stage);
}

const Color& TouchStage::getColor(int stage) {
    return colors[stage];
}

PracticeMode::Callback PracticeMode::clearCallback() {
    return [=](long) { ledManager->clear(); };
}

PracticeMode::Callback PracticeMode::fillColorCallback(Color color) {
    return [=](long) { ledManager->fill(color); };
}

void PracticeMode::changeToStart(long timestamp) {
    state = State::Start;

    int itr = 0;
    for (; itr < TouchStage::getNumStages(); itr++) {
        scheduler.registerCallback(fillColorCallback(TouchStage::getColor(itr)),
                                   timestamp + itr * 750);
    }
    scheduler.registerCallback([=](long timestamp) { changeToGame(timestamp); },
                               timestamp + itr * 750);
}

void PracticeMode::changeToGame(long timestamp) {
    state = State::Game;
    lastUpdate = timestamp;

    // Initialize touches.
    for (size_t i = 0; i < touches.size(); i++) {
        touches[i] = Touch();
    }
    lastInput = Input::None;
}

void PracticeMode::changeToEnd(long timestamp) {
    state = State::End;
    scheduler.clear();

    int itr = 0;
    for (; itr < numEndGameFlashes; itr++) {
        scheduler.registerCallback(fillColorCallback(missColor),
                                   timestamp + 2 * itr * 500);
        scheduler.registerCallback(clearCallback(),
                                   timestamp + (2 * itr + 1) * 500);
    }
    scheduler.registerCallback([=](long timestamp) { startGame(); },
                               timestamp + 2 * itr * 500);
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
    int numInactive = NUM_INPUTS - numActive();
    int counter = rand() % numInactive;

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

    changeToStart(timestamp);
}

void PracticeMode::execute() {
    long timestamp = millis();
    scheduler.execute(timestamp);

    if (state == State::Game) {
        Input input = glove->update();
        if (input != lastInput) {
            lastInput = input;
            Serial.println("Input: " + String(static_cast<int>(input)));

            if (input != Input::None) {
                touch(input, timestamp);
            }
        }

        // New round.
        if (timestamp - lastUpdate >= timePerRound) {
            lastUpdate = timestamp;
            for (auto&& touch : touches) {
                if (touch.getValid() && !touch.next(timestamp)) {
                    changeToEnd(timestamp);
                    Serial.println("Missed (no touch)");
                }
            }

            if (shouldAddTouch()) {
                auto idx = getInactiveTouchIdx();
                touches[idx].setValid(true);
            }
        }

        for (size_t i = 0; i < NUM_INPUTS; i++) {
            auto&& touch = touches[i];
            if (touch.getValid()) {
                ledManager->set(static_cast<Input>(i), touch.getColor());
            } else {
                ledManager->clear(static_cast<Input>(i));
            }
        }
    }

    ledManager->show();
}

void PracticeMode::handleTouch(Input input, long timestamp) {
    timePerRound = max<int>(minTimePerRound, timePerRound - timePerRoundDiff);
}

void PracticeMode::touch(Input input, long timestamp) {
    Touch& touch = touches[toInt(input)];
    if (!touch.getValid()) {
        Serial.println("Missed (touch not valid)");
        changeToEnd(timestamp);
        return;
    }

    ScoreType score = touch.reactToTouch(timestamp);
    Serial.println(String("Score: ") + toString(score));
    switch (score) {
        case ScoreType::Miss:
            changeToEnd(timestamp);
            break;

        case ScoreType::Hit:
            handleTouch(input, timestamp);
            break;

        default:
            break;
    }

    touch.setValid(false);
}

Touch::Touch() : valid(false) {}

bool Touch::next(long timestamp) {
    return valid && stage.next();
}

ScoreType Touch::reactToTouch(long timestamp) const {
    return stage.readyToTouch() ? ScoreType::Hit : ScoreType::Miss;
}

const Color& Touch::getColor() const {
    return stage.getColor();
}

const TouchStage& Touch::getStage() const {
    return stage;
}

void Touch::setValid(bool valid) {
    this->valid = valid;

    if (valid) {
        stage = TouchStage();
    }
}

bool Touch::getValid() const {
    return valid;
}
