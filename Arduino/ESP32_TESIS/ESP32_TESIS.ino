#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <Wire.h>

//BLE server
#define bleDeviceName "ESP32"
#define SERVICE_UUID "91bad492-b950-4226-aa2b-4ede9fa42f59"
#define MOTOR_SERVICE_UUID "c345c464-6ea2-11ed-a1eb-0242ac120002"

// Alturas de tanque
#define ALT_MAX_DEPOSIT 5
#define ALT_MIN_DEPOSIT 25

#define MOTOR 26

// Timer variables
unsigned long lastTime = 0;
unsigned long timerDelay = 1000;  // 1 seg

bool deviceConnected = false;

static char distance1Char[5];
static char distance2Char[5];
static char phChar[5];
static char turbChar[5];
static char motorChar[1];

// Variables de los sensores
int distDeposit = 0;
int pinEco1 = 12;
int pinGatillo1 = 13;
int distCisterna = 0;
int pinEco2 = 27;
int pinGatillo2 = 14;

double turb_Value = 0;
double ph_Value = 0;
int motor = 0;

long readUltrasonicDistance(int triggerPin, int echoPin) {
  pinMode(echoPin, INPUT);
  pinMode(triggerPin, OUTPUT);
  digitalWrite(triggerPin, LOW);
  delayMicroseconds(2);
  digitalWrite(triggerPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(triggerPin, LOW);
  return pulseIn(echoPin, HIGH);
}

// Distance 1 Characteristic
BLECharacteristic sr04Distance1Characteristics("ca73b3ba-39f6-4ab3-91ae-186dc9577d99", BLECharacteristic::PROPERTY_NOTIFY);
BLEDescriptor sr04Distance1Descriptor(BLEUUID((uint16_t)0x2902));

// Distance 2 Characteristic
BLECharacteristic sr04Distance2Characteristics("3c49eb0c-abca-40b5-8ebe-368bd46a7e5e", BLECharacteristic::PROPERTY_NOTIFY);
BLEDescriptor sr04Distance2Descriptor(BLEUUID((uint16_t)0x2902));

// pH Characteristic
BLECharacteristic sensorPHCharacteristics("96f89428-696a-11ed-a1eb-0242ac120002", BLECharacteristic::PROPERTY_NOTIFY);
BLEDescriptor sensorPHDescriptor(BLEUUID((uint16_t)0x2902));

// pH Characteristic
BLECharacteristic sensorTurbCharacteristics("cadf63e3-63ea-4626-9667-e2594d0bf4ae", BLECharacteristic::PROPERTY_NOTIFY);
BLEDescriptor sensorTurbDescriptor(BLEUUID((uint16_t)0x2902));

// Motor Characteristic
BLECharacteristic motorCharacteristics("d5da51ac-6e99-11ed-a1eb-0242ac120002", BLECharacteristic::PROPERTY_NOTIFY);
BLEDescriptor motorDescriptor(BLEUUID((uint16_t)0x2902));

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
  // Serial.begin(115200);
  Serial.begin(115200, SERIAL_8N1, 3, 1);

  // Salidad del Motor
  pinMode(MOTOR, OUTPUT);
  digitalWrite(MOTOR, LOW);

  // Create the BLE Device
  BLEDevice::init(bleDeviceName);

  // Create the BLE Server
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *sensorService = pServer->createService(SERVICE_UUID);
  BLEService *motorService = pServer->createService(MOTOR_SERVICE_UUID);

  // distDeposit Deposito
  sensorService->addCharacteristic(&sr04Distance1Characteristics);
  sr04Distance1Characteristics.addDescriptor(&sr04Distance1Descriptor);

  // distDeposit Cisterna
  sensorService->addCharacteristic(&sr04Distance2Characteristics);
  sr04Distance2Characteristics.addDescriptor(&sr04Distance2Descriptor);

  // pH
  sensorService->addCharacteristic(&sensorPHCharacteristics);
  sensorPHCharacteristics.addDescriptor(&sensorPHDescriptor);

  // Turbidez
  sensorService->addCharacteristic(&sensorTurbCharacteristics);
  sensorTurbCharacteristics.addDescriptor(&sensorTurbDescriptor);

  // Motor
  motorService->addCharacteristic(&motorCharacteristics);
  motorCharacteristics.addDescriptor(&motorDescriptor);

  // Start the service
  sensorService->start();
  motorService->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pServer->getAdvertising()->start();
}

void loop() {
  turb_Value = Serial.parseFloat();
  Serial.println(turb_Value);
  ph_Value = Serial.parseFloat();
  Serial.println(ph_Value);
  if ((millis() - lastTime) > timerDelay) {
    // Leer distancias
    distDeposit = 0.01723 * readUltrasonicDistance(pinGatillo1, pinEco1);
    distCisterna = 0.01723 * readUltrasonicDistance(pinGatillo2, pinEco2);
    bool validDeposito = (distDeposit >= 3) && (distDeposit < 500);
    bool validCisterna = (distCisterna >= 3) && (distCisterna < 500);
    bool validTurb = (turb_Value >= 0) && (turb_Value <= 5);
    bool validPH = (ph_Value >= 0) && (ph_Value <= 14);
    if ((distCisterna < ALT_MIN_DEPOSIT) && validCisterna) {   // Si la cisterna tiene agua...
      if ((distDeposit < ALT_MAX_DEPOSIT) && validDeposito) {  // Si el agua está en el limite superior...
        digitalWrite(MOTOR, LOW);                              // Apagar motor
        motor = 0;
      }
      if ((distDeposit > ALT_MIN_DEPOSIT) && validDeposito) {  // Si el agua está en el limite inferior...
        digitalWrite(MOTOR, HIGH);                             // Enceder motor
        motor = 1;
      } else {
        digitalWrite(MOTOR, LOW);  // Apagar motor
        motor = 0;
      }
    } else {
      digitalWrite(MOTOR, LOW);  // Apagar motor
      motor = 0;
    }
    if (deviceConnected) {
      if (validDeposito) {  // Notificar distancia 1
        dtostrf(distDeposit, 6, 2, distance1Char);
        sr04Distance1Characteristics.setValue(distance1Char);
        sr04Distance1Characteristics.notify();
      }
      if (validTurb) {  // Notificar distancia 2
        dtostrf(distCisterna, 6, 2, distance2Char);
        sr04Distance2Characteristics.setValue(distance2Char);
        sr04Distance2Characteristics.notify();
      }
      if (validTurb) {  // Notificar valor de Turbidez
        dtostrf(turb_Value, 3, 2, turbChar);
        sensorTurbCharacteristics.setValue(turbChar);
        sensorTurbCharacteristics.notify();
      }
      if (validPH) {  // Notificar valor de pH
        dtostrf(ph_Value, 3, 2, phChar);
        sensorPHCharacteristics.setValue(phChar);
        sensorPHCharacteristics.notify();
      }
      // Notificar el valor de motor
      dtostrf(motor, 1, 0, motorChar);
      motorCharacteristics.setValue(motorChar);
      motorCharacteristics.notify();
    }

    lastTime = millis();
  }
}