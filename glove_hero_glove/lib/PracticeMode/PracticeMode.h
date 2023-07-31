#ifndef PRACTICE_MODE_H
#define PRACTICE_MODE_H

#include <LedManager.h>
#include <Scheduler.h>
#include <time.h>
#include <array>

/// @brief The possible scores for a touch in the game.
enum class ScoreType { Hit, Miss };

/// @brief Converts a score to it's string representation.
/// @param score The score to convert.
/// @return The string representation of the score.
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

/// @brief Represents the stages of a touch during the game.
/// The touch starts at stage 0 and progresses to stage 3.
/// At this stage (and this stage only), the touch is considered
/// complete and the player is awarded a point. If the touch is
/// missed, it goes to stage 4 and the game starts over.
class TouchStage {
private:
    int stage = 0;
    static constexpr int numStages = 4;
    static std::array<Color, numStages> colors;

public:
    /// @brief Get the number of stages.
    /// @return The number of stages.
    static constexpr int getNumStages();

    /// @brief Advances the touch to it's next stage.
    /// @return True if the touch is still active, false otherwise.
    bool next();

    /// @brief Get the current stage.
    /// @return The current stage.
    int getStage() const;

    /// @brief Checks if the stage of the touch is ready for the player to touch
    /// (stage == 3).
    /// @return True if the touch is ready to be touched, false otherwise.
    bool readyToTouch() const;

    /// @brief Checks if the touch is missed (stage == 4).
    /// @return True if the touch is missed, false otherwise.
    bool missed() const;

    /// @brief Gets the color matching the stage of the touch.
    /// @return The color matching the stage of the touch.
    const Color& getColor() const;

    /// @brief Gets the color matching the given stage.
    /// @param stage The stage to get the color for.
    /// @return The color matching the given stage.
    static const Color& getColor(int stage);
};

/// @brief Represents a touch during the game.
class Touch {
private:
    TouchStage stage;
    bool valid;

public:
    /// @brief Construct a new Touch object.
    Touch();

    /// @brief Checks if the touch is valid.
    /// @return True if the touch is valid, false otherwise.
    bool getValid() const;

    /// @brief Sets the validity of the touch.
    /// @param valid The validity of the touch.
    void setValid(bool valid);

    /// @brief Advances the touch to it's next stage.
    /// @return True if the touch is valid and still active, false otherwise.
    bool next();

    /// @brief Returns the score for the touch when tapped at the current stage.
    /// @return The score for the touch when tapped at the current stage.
    ScoreType reactToTouch() const;

    /// @brief Gets the color matching the stage of the touch.
    /// @return The color matching the stage of the touch.
    const Color& getColor() const;

    /// @brief Gets the stage of the touch.
    /// @return The stage of the touch.
    const TouchStage& getStage() const;
};

/// @brief Game manager for the practice mode (offline) game.
/// @remark The game is implemented as a state machine, while also
/// using a scheduler to schedule events.
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
    /// @brief Construct a new Practice Mode object.
    /// @param ledManager The led manager to use.
    /// @param glove The input manager to use.
    void setup(LedManager* ledManager, InputBase* glove);

    /// @brief Starts the game.
    void startGame();

    /// @brief Run the update loop of the game.
    void execute();
};

#endif