#define TINY_GSM_MODEM_SIM800

#include <WiFi.h>
#include <HardwareSerial.h>
#include <SoftwareSerial.h>
#include <TinyGsmClient.h>
#include <PubSubClient.h>
#include <TinyGPS++.h>
#include <WebServer.h>

const int RXPin = 16; // GPS TX pin connected to ESP32 RX pin
const int TXPin = 17; // GPS RX pin connected to ESP32 TX pin

// Define SoftwareSerial for SIM800L
SoftwareSerial SerialAT(18, 19); // rx tx pins for SIM800L

// MQTT details
const char *broker = "broker.hivemq.com";
const int mqttPort = 1883;
const char *clientId = "gpsclient";
const char *topicOut = "sistgps/2";

TinyGsm modem(SerialAT);
TinyGsmClient client(modem);
PubSubClient mqtt(client);
TinyGPSPlus gps;

WebServer server(80);
String logData;

void handleRestart() {
  server.send(200, "text/plain", "ESP32 Restarting...");
  delay(1000);
  ESP.restart();
}

void handleLogs() {
  String response = "<html><head><meta http-equiv='refresh' content='1'></head><body><pre>";
  response += logData;
  response += "</pre></body></html>";
  server.send(200, "text/html", response);
}
int msgc = 1;
void printAndStore(String message) {
  Serial.println(message);
  logData += "[" + String(msgc) + "] "+ message + "\n\n";
  if (logData.length() > 5000) { // Prevent excessive memory usage
    logData = logData.substring(logData.length() - 2000);
  }
  msgc++;
}

boolean mqttConnect() {
  printAndStore("Attempting MQTT connection...");
  if (!mqtt.connect(clientId)) {
    printAndStore("MQTT connection failed.");
    return false;
  }
  printAndStore("Connected to MQTT broker.");
  return mqtt.connected();
}

// Wi-Fi AP credentials
const char *ssid = "nav_connect";
const char *password = "12345678";

void setup() {
  Serial.begin(115200);
  SerialAT.begin(9600);
  Serial2.begin(9600, SERIAL_8N1, RXPin, TXPin);

  WiFi.softAP(ssid, password);
  printAndStore("ESP32 AP Started. Connect to " + String(ssid));
  printAndStore("AP IP: " + WiFi.softAPIP().toString());

  server.on("/restart", handleRestart);
  server.on("/logs", handleLogs);
  server.begin();

  printAndStore("System start.");
  modem.restart();
  printAndStore("Modem: " + modem.getModemInfo());
  printAndStore("Searching for telco provider.");

  if (!modem.waitForNetwork()) {
    printAndStore("Network search failed");
  }
  printAndStore("Connected to telco.");
  printAndStore("Signal Quality: " + String(modem.getSignalQuality()));

  printAndStore("Connecting to GPRS network.");
  if (!modem.gprsConnect("airtelgprs.com", "", "")) {
    printAndStore("GPRS connection failed");
  }
  printAndStore("Connected to GPRS");
  mqtt.setServer(broker, mqttPort);
}

void loop() {
  server.handleClient();
  if (Serial2.available() > 0) {
    if (gps.encode(Serial2.read())) {
      if (gps.location.isValid()) {
        String gpsData = "Latitude: " + String(gps.location.lat(), 6) + ", Longitude: " + String(gps.location.lng(), 6);
        printAndStore("Signal Quality: " + String(modem.getSignalQuality()));
        printAndStore(gpsData);

        String gpsJson = "{\"lat\": " + String(gps.location.lat(), 6) + ", \"lang\": " + String(gps.location.lng(), 6) + "}";
        if (mqtt.connected()) {
          mqtt.publish(topicOut, gpsJson.c_str());
        } else {
          printAndStore("Mqtt not connected");
          while (!mqttConnect()) {
            continue;
          }
        }
        delay(500);
      }
    }
  } else {
    printAndStore("searching for gps data .....");
    mqtt.disconnect();
  }

  if (mqtt.connected()) {
    mqtt.loop();
  }
}


