#include <ESP8266WiFi.h>
#include <Firebase_ESP_Client.h>

// -------------------- WiFi Credentials --------------------
#define WIFI_SSID "YOUR_WIFI_SSID"
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"

// -------------------- Firebase Credentials --------------------
#define API_KEY "YOUR_FIREBASE_API_KEY"
#define DATABASE_URL "YOUR_FIREBASE_DATABASE_URL"

FirebaseData fbdo;
FirebaseData stream;
FirebaseAuth auth;
FirebaseConfig config;

bool signupOK = false;

// ---------------- PRINT CONTROL VARIABLES ----------------
String printQueue[50];
int totalItems = 0;
int currentIndex = 0;
unsigned long lastPrintTime = 0;
bool newDataArrived = false;

void setup() {

  Serial.begin(115200);
  //Serial.println();

  // ---------------- WiFi ----------------
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  //Serial.print("Connecting");

  while (WiFi.status() != WL_CONNECTED) {
    //Serial.print(".");
    delay(500);
  }

  //Serial.println("\nWiFi Connected");
  //Serial.println(WiFi.localIP());

  // ---------------- Firebase ----------------
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  if (Firebase.signUp(&config, &auth, "", "")) {
    signupOK = true;
    //Serial.println("Firebase Connected");
  } else {
    //Serial.println(config.signer.signupError.message.c_str());
  }

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // ---------------- Start Stream ----------------
  if (!Firebase.RTDB.beginStream(&stream, "/parking/bookings")) {
    //Serial.println("Stream begin error");
    //Serial.println(stream.errorReason());
  } else {
    //Serial.println("🔥 Stream started...");
  }

 // Serial.println("\nType to send like:");
  //Serial.println("1001: S2b");
}

void loop() {

  if (!Firebase.ready() || !signupOK)
    return;

  // =====================================================
  // 🔥 RECEIVE FROM FIREBASE
  // =====================================================

  if (!Firebase.RTDB.readStream(&stream)) {
    //Serial.println("Stream read error");
    //Serial.println(stream.errorReason());
  }

  if (stream.streamAvailable()) {

    FirebaseJson json;
    json.setJsonData(stream.jsonString());

    size_t count = json.iteratorBegin();

    totalItems = 0;
    currentIndex = 0;

    //Serial.println("------ Updated Booking ------");

    for (size_t i = 0; i < count; i++) {

      String bookingID, nestedData;
      int type;

      json.iteratorGet(i, type, bookingID, nestedData);

      FirebaseJson subJson;
      subJson.setJsonData(nestedData);

      size_t subCount = subJson.iteratorBegin();

      for (size_t j = 0; j < subCount; j++) {

        String slot, status;
        int subType;

        subJson.iteratorGet(j, subType, slot, status);

        // Remove quotes
        status.replace("\"", "");
        status.trim();

        // Format: 1001: S2b
        printQueue[totalItems] = bookingID + ": " + slot + status;

        totalItems++;
      }

      subJson.iteratorEnd();
    }

    json.iteratorEnd();

    newDataArrived = true;
  }

  // =====================================================
  // ⏱ PRINT ONE ENTRY EVERY 1 SECOND
  // =====================================================

  if (newDataArrived && currentIndex < totalItems) {

    if (millis() - lastPrintTime >= 1000) {

      Serial.println(printQueue[currentIndex]);

      currentIndex++;
      lastPrintTime = millis();

      if (currentIndex >= totalItems) {
        //Serial.println("-----------------------------");
        newDataArrived = false;
      }
    }
  }

  // =====================================================
  // 📤 SEND SERIAL DATA TO FIREBASE
  // =====================================================

  if (Serial.available()) {

    String input = Serial.readStringUntil('\n');
    input.trim();

    int separatorIndex = input.indexOf(':');

    if (separatorIndex != -1) {

      String bookingID = input.substring(0, separatorIndex);
      String value = input.substring(separatorIndex + 1);

      bookingID.trim();
      value.trim();

      if (value.length() < 2) {
        //Serial.println("❌ Invalid format");
        return;
      }

      // Example S2b
      String slot = value.substring(0, value.length() - 1);
      String status = value.substring(value.length() - 1);

      String path = "parking/bookings/" + bookingID + "/" + slot;

      //Serial.print("Sending -> ");
      //Serial.print(path);
      //Serial.print(" : ");
      //Serial.println(status);

      if (Firebase.RTDB.setString(&fbdo, path.c_str(), status)) {
        //Serial.println("✅ Sent Successfully");
      } else {
        //Serial.println("❌ Failed");
        //Serial.println(fbdo.errorReason());
      }

    } else {
      //Serial.println("❌ Use format: 1001: S2b");
    }
  }
}