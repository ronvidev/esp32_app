#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <Wire.h>

//BLE server
#define bleServerName "ESP32_server"
#define SERVICE_UUID "91bad492-b950-4226-aa2b-4ede9fa42f59"

float temp;
float hum;

// Timer variables
unsigned long lastTime = 0;
unsigned long timerDelay = 3000;  // 3 seg

bool deviceConnected = false;

// Variables de los sensores
int distancia = 0;
int pinEco = 12;
int pinGatillo = 13;
long readUltrasonicDistance(int triggerPin, int echoPin) {
  pinMode(triggerPin, OUTPUT);
  digitalWrite(triggerPin, LOW);
  delayMicroseconds(2);
  digitalWrite(triggerPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(triggerPin, LOW);
  pinMode(echoPin, INPUT);
  return pulseIn(echoPin, HIGH);
}

// Distance Characteristic and Descriptor
BLECharacteristic sr04Distance1Characteristics("ca73b3ba-39f6-4ab3-91ae-186dc9577d99", BLECharacteristic::PROPERTY_NOTIFY);
BLEDescriptor bmeHumidityDescriptor(BLEUUID((uint16_t)0x2903));

//Setup callbacks onConnect and onDisconnect
class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer *pServer) {
    deviceConnected = true;
  };
  void onDisconnect(BLEServer *pServer) {
    deviceConnected = false;
  }
};

void setup() {
  // Start serial communication
  Serial.begin(115200);

  // Led de prueba
  pinMode(LED_BUILTIN, OUTPUT);

  // Create the BLE Device
  BLEDevice::init(bleServerName);

  // Create the BLE Server
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *sensorService = pServer->createService(SERVICE_UUID);

  // Humidity
  sensorService->addCharacteristic(&sr04Distance1Characteristics);
  bmeHumidityDescriptor.setValue("BME humidity");
  sr04Distance1Characteristics.addDescriptor(new BLE2902());

  // Start the service
  sensorService->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pServer->getAdvertising()->start();
  Serial.println("Waiting a client connection to notify...");
}

void loop() {
  if (deviceConnected) {
    if ((millis() - lastTime) > timerDelay) {
      // Read distance
      distancia = 0.01723 * readUltrasonicDistance(pinGatillo, pinEco);
      if (distancia < 500) {
        // Notify distance reading from HC-SR04
        static char distanceChar[5];
        dtostrf(distancia, 6, 2, distanceChar);
        // Set distance Characteristic value and notify
        sr04Distance1Characteristics.setValue(distanceChar);
        sr04Distance1Characteristics.notify();
        // Mostramos la distancia
        Serial.print("Distancia: ");
        Serial.print(distancia);
        Serial.println(" cm");

        // Si la distancia es menor a 15...
        if (distancia < 15) {  // APAGAR MOTOR
          digitalWrite(LED_BUILTIN, LOW);
        }
        if (distancia > 135) {  // ENCENDER MOTOR
          digitalWrite(LED_BUILTIN, HIGH);
        }
      } else {
        Serial.println("Fuera de rango");
      }
      lastTime = millis();
    }
  }
}