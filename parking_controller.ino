#include <SoftwareSerial.h>
#include <Servo.h>

#define NUM_SENSORS 4

// 🔹 ESP Serial Pins
#define ESP_RX 12
#define ESP_TX 13

SoftwareSerial espSerial(ESP_RX, ESP_TX);

// 🔹 Servo
Servo myServo;
int angles[NUM_SENSORS] = {36, 72, 108, 144};

// 🔹 Ultrasonic pins
const int trigPins[NUM_SENSORS] = {2, 4, 10, 6};
const int echoPins[NUM_SENSORS] = {3, 5, 11, 7};

long duration;

bool prevState[NUM_SENSORS];
bool slotBooked[NUM_SENSORS];
String bookingID[NUM_SENSORS];

//---------------------------------
float readUltrasonic(int trigPin, int echoPin)
{
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);

  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  duration = pulseIn(echoPin, HIGH, 30000);
  float distance = duration * 0.0343 / 2;

  return distance;
}
//---------------------------------

void setup()
{
  Serial.begin(115200);
  espSerial.begin(115200);

  myServo.attach(9);
  myServo.write(0);  // default position
  delay(2000);

  for(int i=0; i<NUM_SENSORS; i++)
  {
    pinMode(trigPins[i], OUTPUT);
    pinMode(echoPins[i], INPUT);

    prevState[i] = false;
    slotBooked[i] = false;
    bookingID[i] = "";
  }

}

//---------------------------------

void openGate(int slotIndex)
{
  myServo.write(angles[slotIndex]);
  delay(5000);
  myServo.write(0);
  delay(2000);
}

//---------------------------------

void loop()
{
  // =========================================
  // 📥 RECEIVE FROM ESP
  // =========================================
  if (espSerial.available())
  {
    String input = espSerial.readStringUntil('\n');
    input.trim();

    Serial.println("Received: " + input);

    int separatorIndex = input.indexOf(':');

    if (separatorIndex != -1)
    {
      String id = input.substring(0, separatorIndex);
      String value = input.substring(separatorIndex + 1);

      id.trim();
      value.trim();

      String slotStr = value.substring(0, value.length() - 1);
      String status = value.substring(value.length() - 1);

      int slotNumber = slotStr.substring(1).toInt() - 1;

      if (slotNumber >= 0 && slotNumber < NUM_SENSORS)
      {
        if (status == "b")
        {
          slotBooked[slotNumber] = true;
          bookingID[slotNumber] = id;
          delay(2000);
          // 🚪 Open gate for that slot
          openGate(slotNumber);

          delay(60000);

          openGate(slotNumber);
          delay(2000);
        }
      }
    }
  }

  // =========================================
  // 🚗 CHECK OCCUPANCY
  // =========================================
  for(int i=0; i<NUM_SENSORS; i++)
  {
    if (!slotBooked[i])
      continue;

    float d = readUltrasonic(trigPins[i], echoPins[i]);
    bool currentState = (d > 0 && d < 5);

    if(currentState != prevState[i])
    {
      espSerial.print(bookingID[i]);
      espSerial.print(": S");
      espSerial.print(i + 1);

      if(currentState)
        espSerial.println("p");
      else
        espSerial.println("e");

      prevState[i] = currentState;
    }
  }

  delay(200);
}