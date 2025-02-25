#define TINY_GSM_MODEM_SIM800

#include <HardwareSerial.h>
#include <SoftwareSerial.h>
#include <TinyGsmClient.h>
#include <PubSubClient.h>
#include <TinyGPS++.h>

const int RXPin = 16; // GPS TX pin connected to ESP32 RX pin
const int TXPin = 17; // GPS RX pin connected to ESP32 TX pin

// Define SoftwareSerial for SIM800L
SoftwareSerial SerialAT(18, 19); // rx tx pins for sim800l

// Network details
const char apn[] = "airtelgprs.com"; // airtel APN
const char user[] = "";              // no username
const char pass[] = "";              // no password

// MQTT details
const char *broker = "broker.hivemq.com"; // MQTT broker address
const int mqttPort = 1883;                // MQTT port
const char *clientId = "gpsclient";       // client ID for MQTT
const char *topicOut = "sistgps/2";       // 1 is the bus id
// const char *topicIn = "sistgps/#";

TinyGsm modem(SerialAT);     // GSM module instance
TinyGsmClient client(modem); // GPRS client instance
PubSubClient mqtt(client);   // MQTT client instance

TinyGPSPlus gps; // gps instance

boolean mqttConnect()
{
  Serial.println("Attempting MQTT connection...");

  // Connect to the MQTT broker
  if (!mqtt.connect(clientId))
  {
    Serial.print("."); // shows connecting
    return false;
  }

  Serial.println("Connected to broker.");
  // mqtt.subscribe(topicIn);
  return mqtt.connected();
}

void mqttCallback(char *topic, byte *payload, unsigned int len)
{
  // used to print the subscribed messages when received
  Serial.print("Message received: ");
  Serial.write(payload, len);
  Serial.println();
}

void setup()
{
  Serial.begin(115200);                          // Serial Monitor baud rate
  SerialAT.begin(9600);                          // SoftwareSerial baud rate
  Serial2.begin(9600, SERIAL_8N1, RXPin, TXPin); // initialize serial communication with GPS

  Serial.println("System start.");
  modem.restart(); // Restart the GSM module
  Serial.println("Modem: " + modem.getModemInfo());

  Serial.println("Searching for telco provider.");
  if (!modem.waitForNetwork())
  {
    Serial.println("Network search failed");
    while (true)
      ; // Halt if network registration fails
  }
  Serial.println("Connected to telco.");
  Serial.println("Signal Quality: " + String(modem.getSignalQuality()));

  Serial.println("Connecting to GPRS network.");
  if (!modem.gprsConnect(apn, user, pass))
  {
    Serial.println("GPRS connection failed");
    while (true)
      ; // Halt if GPRS connection fails
  }
  Serial.println("Connected to GPRS: " + String(apn));

  mqtt.setServer(broker, mqttPort);
  mqtt.setCallback(mqttCallback);

  Serial.print("finding satalites fro GPS ..");
  while(Serial2.available() <= 0){
    Serial.print(".");
  }
  Serial.println("GPS CONECTED");

}

void loop()
{
  // // Read from Serial Monitor and publish to MQTT
  // if (Serial.available()) {
  //   delay(10);  // Short delay to ensure complete reading
  //   String message = "";
  //   while (Serial.available()) {
  //     message += (char) Serial.read();  // Read incoming serial data
  //   }
  //   mqtt.publish(topicOut, message.c_str());  // Publish to MQTT
  // }

  if (Serial2.available() > 0)
  {
    
    if (gps.encode(Serial2.read()))
    {
      if (gps.location.isValid())
      {
        
        Serial.println("Connecting to MQTT Broker: " + String(broker));
        while (!mqttConnect())
        {
          continue; // Keep trying to connect to MQTT
        }
        Serial.println("Connected to MQTT broker.");

        Serial.print("Latitude: ");
        Serial.println(gps.location.lat(), 6);
        Serial.print("Longitude: ");
        Serial.println(gps.location.lng(), 6);
        if (mqtt.connected())
        {
          Serial.println("{\"lat\" : " + String(gps.location.lat(), 6) + ", \"lang\" : " + String(gps.location.lng(), 6) + "}");
          // Send a message
          String gpsmsg = "{\"lat\" : " + String(gps.location.lat(), 6) + ", \"lang\" : " + String(gps.location.lng(), 6) + "}";
          mqtt.publish(topicOut, gpsmsg.c_str());
        }

        sleep(1);
      }
    }
  }
  else{
    mqtt.disconnect();
    Serial1.println("Gps and mqtt has disconnected");
  }

  if (mqtt.connected())
  {
    mqtt.loop(); // Keep MQTT connection alive
  }
}