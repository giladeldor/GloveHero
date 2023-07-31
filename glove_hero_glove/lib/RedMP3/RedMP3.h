#ifndef _Red_MP3_H__
#define _Red_MP3_H__

#include <Arduino.h>
#include <SoftwareSerial.h>

/// @brief NOT USED.
class RedMP3 {
public:
    RedMP3(uint8_t rxd, uint8_t txd);
    void play();
    void pause();
    void nextSong();
    void previousSong();
    void volumeUp();
    void volumeDown();
    void forward();
    void rewind();
    void stopPlay();
    void stopInject();
    void singleCycle();
    void allCycle();
    void playWithIndex(int8_t index);
    void injectWithIndex(int8_t index);

    uint8_t getStatus();

    void setVolume(int8_t vol);
    void playWithFileName(int8_t directory, int8_t file);
    void playWithVolume(int8_t index, int8_t volume);
    void cyclePlay(int16_t index);
    void setCyleMode(int8_t AllSingle);
    void playCombine(int16_t folderAndIndex[], int8_t number);

private:
    void begin();
    SoftwareSerial myMP3;
    void sendCommand(int8_t command, int16_t dat = 0);
    void mp3Basic(int8_t command);
    void mp3_5bytes(int8_t command, uint8_t dat);
    void mp3_6bytes(int8_t command, int16_t dat);
    void sendBytes(uint8_t buf[], uint8_t nbytes);
};

#endif
