#include <Adafruit_NeoPixel.h>

#define LED_PIN 5
#define NUM_PIXELS 12
#define BAUD_RATE 9600

Adafruit_NeoPixel pixels(NUM_PIXELS, LED_PIN, NEO_GRB + NEO_KHZ800);

void setup() {
    Serial.begin(BAUD_RATE);

    pixels.setBrightness(30);
    pixels.begin();
}

void loop() {

    pixels.clear();
    pixels.show();

    for (int i = 0; i < 12; i++)
    {
        pixels.fill(pixels.Color(rand() % 255, rand() % 255, rand() % 255), i, 1);
        
    }
    

    pixels.show();
    delay(300);
}
