/*
    Video: https://www.youtube.com/watch?v=oCMOYS71NIU
    Based on Neil Kolban example for IDF: https://github.com/nkolban/esp32-snippets/blob/master/cpp_utils/tests/BLE%20Tests/SampleNotify.cpp
    Ported to Arduino ESP32 by Evandro Copercini

   Create a BLE server that, once we receive a connection, will send periodic notifications.
   The service advertises itself as: 6E400001-B5A3-F393-E0A9-E50E24DCCA9E
   Has a characteristic of: 6E400002-B5A3-F393-E0A9-E50E24DCCA9E - used for receiving data with "WRITE" 
   Has a characteristic of: 6E400003-B5A3-F393-E0A9-E50E24DCCA9E - used to send data with  "NOTIFY"

   The design of creating the BLE server is:
   1. Create a BLE Server
   2. Create a BLE Service
   3. Create a BLE Characteristic on the Service
   4. Create a BLE Descriptor on the characteristic
   5. Start the service.
   6. Start advertising.

   In this example rxValue is the data received (only accessible inside that function).
   And txValue is the data to be sent, in this example just a byte incremented every second. 
*/
// string::substr
#include <Arduino.h>
#include <iostream>
#include <string>
#include <stdio.h>    
#include <stdlib.h>     
#include <sstream>
using namespace std;

#include <Tone32.h>
#include "pitches.h"

#define BIN_1 26
#define BIN_2 14
#define AIN_2 4
#define AIN_1 15
#define ENC_1 36
#define ENC_2 33

//horn
#define SPKR 25
#define SPKR_CH 0



#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#define LED 13
#define PR 32

/*photoResistor global variables*/
int photoResistorInit;
int photoReading;
int leftEncoder;
int rightEncoder;
bool autom = true;
int lightstate = 0; 


/* setting PWM properties */
const int freq = 5000;
const int ledChannel_1 = 1;
const int ledChannel_2 = 2;
const int ledChannel_3 = 3;
const int ledChannel_4 = 4;
const int resolution = 8;

/*encoder global variables*/
long curr_time = 0;
long last_time = 0;
float rpms1 = 0.0;
float rpms2 = 0.0;
float maxrpms = 0.0;
volatile int enc_count1;
volatile int enc_count2;
const float encoder_circumference = 66.10*3.14;

BLEServer *pServer = NULL;
BLECharacteristic * pTxCharacteristic;
bool deviceConnected = false;
bool oldDeviceConnected = false;
uint8_t txValue = 0;

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/

#define SERVICE_UUID           "6E400001-B5A3-F393-E0A9-E50E24DCCA9E" // UART service UUID
#define CHARACTERISTIC_UUID_RX "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_UUID_TX "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"


//horn
int tempo = 250;

 int melody2[] = {
  NOTE_C4, 16,
 };
 
void playHornSound() {
  int notes = sizeof(melody2) / sizeof(melody2[0]) / 2;  // sizeof gives the number of bytes, each int value is composed of two bytes (16 bits)
  int wholenote = (60000 * 4) / tempo;  // this calculates the duration of a whole note in ms
  int divider = 0, noteDuration = 0;
  for (int thisNote = 0; thisNote < notes * 2; thisNote = thisNote + 2) {
    divider = melody2[thisNote + 1];  // calculates the duration of each note
    if (divider > 0) {
      noteDuration = (wholenote) / divider;  // regular note, just proceed
    } 
    else if (divider < 0) {
      noteDuration = (wholenote) / abs(divider);  // dotted notes are represented with negative durations!!
      noteDuration *= 1.5; // increases the duration in half for dotted notes
    }
    tone(SPKR, melody2[thisNote], noteDuration * 0.9, SPKR_CH);  // we only play the note for 90% of the duration, leaving 10% as a pause
    delay(noteDuration);  // Wait for the specief duration before playing the next note.
    noTone(SPKR, SPKR_CH);  // stop the waveform generation before the next note.
  }
}

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
    }
};

class MyCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      std::string rxValue = pCharacteristic->getValue();

      if (rxValue.length() > 0) {
        if (rxValue == "1") {
          digitalWrite(13, HIGH);
        }
        if (rxValue == "0") {
          digitalWrite(13, LOW); 
        }
        if (rxValue == "auto") {
          autom = 1; 
        }
        if (rxValue == "autooff") {
          autom = 0; 
        }
        //Honk the horn
        if (rxValue == "honk") {
          playHornSound(); 
        }
        //Driving directions
        if (rxValue.find(',') != -1) {
        Serial.println("Found ,");
        std::size_t pos = rxValue.find(',');
        std::string yval = rxValue.substr(pos+1);
        std::string xval = rxValue.substr(0, pos);
        std::string str;
        const char * yv = yval.c_str();
        int yint = atoi(yv);
        const char * xv = xval.c_str();
        int xint = atoi(xv);
        int outputleft;
        int outputright;
        if (xint==0) {
          outputleft = yint;
          outputright = yint;
        } else if (xint>0){
          outputleft = yint;
          outputright = (((84.0-xint))/84.0) * yint;
        } else {
          outputleft = ((84.0+xint)/84.0) * yint;
          outputright = yint;
        }
        outputleft = (outputleft * (90.0/84.0));
        outputright = (outputright * (90.0/84.0));
        if (outputleft != 0) {
          if (outputleft < 0) {
            outputleft -= 165;
            outputleft = min(-190, outputleft);
          } else {
            outputleft += 165;
            outputleft = max(190, outputleft);
          }
          
        }
        if (outputright != 0) {
          if (outputright < 0) {
            outputright -= 165;
            outputright = min(-190, outputright);
          } else {
            outputright += 165;
            outputright = max(190, outputright);
          }
        }
        if (yint > 0) {
          ledcWrite(ledChannel_2, LOW);
          ledcWrite(ledChannel_1, outputleft);
          ledcWrite(ledChannel_4, LOW);
          ledcWrite(ledChannel_3, outputright);
          }
          else {
          ledcWrite(ledChannel_1, LOW);
          ledcWrite(ledChannel_2, -outputleft);
          ledcWrite(ledChannel_3, LOW);
          ledcWrite(ledChannel_4, -outputright);
            }
          
        }
        Serial.println("*********");
        Serial.print("Received Value: ");
        for (int i = 0; i < rxValue.length(); i++) {
          Serial.print(rxValue[i]);
        }
        Serial.println();
        Serial.println("*********");
      }
    }
};

int incomingByte = 0;

void IRAM_ATTR updateCount() {
  enc_count1+=1.0;
}
void IRAM_ATTR updateCount2() {
  enc_count2+=1.0;
}


void setup() {
  
  Serial.begin(230400);
  pinMode(13, OUTPUT);
  pinMode(14, INPUT);
  photoResistorInit = analogRead(PR);
   //driver directions
     /* configure LED PWM functionalitites */
  pinMode(ENC_1,INPUT);
  pinMode(ENC_2,INPUT);
  Serial.begin(115200);
  attachInterrupt(digitalPinToInterrupt(ENC_1), updateCount, FALLING);
  attachInterrupt(digitalPinToInterrupt(ENC_2), updateCount2, FALLING);
  ledcSetup(ledChannel_1, freq, resolution);
  ledcSetup(ledChannel_2, freq, resolution);
  ledcSetup(ledChannel_3, freq, resolution);
  ledcSetup(ledChannel_4, freq, resolution);

  /* attach the channel to the GPIO to be controlled */
  ledcAttachPin(BIN_1, ledChannel_1);
  ledcAttachPin(BIN_2, ledChannel_2);
  ledcAttachPin(AIN_1, ledChannel_3);
  ledcAttachPin(AIN_2, ledChannel_4);
  //end driver directions
  
  // Create the BLE Device
  BLEDevice::init("UART Service");

  // Create the BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create a BLE Characteristic
  pTxCharacteristic = pService->createCharacteristic(
										CHARACTERISTIC_UUID_TX,
										BLECharacteristic::PROPERTY_NOTIFY
									);
                      
  pTxCharacteristic->addDescriptor(new BLE2902());

  BLECharacteristic * pRxCharacteristic = pService->createCharacteristic(
											 CHARACTERISTIC_UUID_RX,
											BLECharacteristic::PROPERTY_WRITE
										);

  pRxCharacteristic->setCallbacks(new MyCallbacks());

  // Start the service
  pService->start();

  // Start advertising
  pServer->getAdvertising()->start();
  Serial.println("Waiting a client connection to notify...");
}

void loop() {
  if (autom == true) {
  photoReading = analogRead(PR);
  float voltage = photoReading;
  if ((voltage < 80) && lightstate == 0) {
    digitalWrite(13, HIGH);
    lightstate = 1;
  } else if (voltage>=85 && lightstate == 1) {
    digitalWrite(13,LOW);
    lightstate = 0;
  }
  }
  curr_time = millis();
  float difference = curr_time-last_time;
  if (difference >= 5000) {
    last_time = curr_time;
    rpms1 = (enc_count1/(difference*20.0))*encoder_circumference;
    rpms2 = (enc_count2/(difference*20.0))*encoder_circumference;
    maxrpms = max(rpms1, rpms2);
    enc_count1 = 0.0;
    enc_count2 = 0.0;
  }
    if (deviceConnected) {
    std::string dd = String(maxrpms).c_str();
        pTxCharacteristic->setValue(dd);
        pTxCharacteristic->notify();
        delay(10); // bluetooth stack will go into congestion, if too many packets are sent
  
      
	}

    // disconnecting
    if (!deviceConnected && oldDeviceConnected) {
        delay(500); // give the bluetooth stack the chance to get things ready
        pServer->startAdvertising(); // restart advertising
        Serial.println("start advertising");
        oldDeviceConnected = deviceConnected;
    }
    // connecting
    if (deviceConnected && !oldDeviceConnected) {
		// do stuff here on connecting
        oldDeviceConnected = deviceConnected;
        
    }
    
}
