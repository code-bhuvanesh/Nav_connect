import paho.mqtt.client as mqtt
import json
import asyncio
import websockets
import ssl
from time import sleep

data_changed = False
data = ""

# MQTT Callbacks
def on_connect(mqttc, obj, flags, reason_code, properties):
    print(f"MQTT Connected: {reason_code}")
    mqttc.subscribe("sistgps/#")

def on_message(mqttc, obj, msg):
    """Set flag when new data arrives"""
    global data_changed, data  
    data_changed = True
    data = msg.payload.decode("utf-8")

def on_disconnect(mqttc, obj, rc):
    print("MQTT Disconnected! Trying to reconnect...")
    while True:
        try:
            mqttc.reconnect()
            print("MQTT Reconnected!")
            break  # Exit loop when reconnected
        except Exception as e:
            print(f"MQTT Reconnect Failed: {e}")
            sleep(5)  # Wait 5 seconds before retrying

# MQTT Client Setup
mqttc = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
mqttc.on_connect = on_connect
mqttc.on_message = on_message
mqttc.on_disconnect = on_disconnect

mqttc.connect("broker.hivemq.com", 1883, 60)
mqttc.loop_start()

# WebSocket Connection Function
async def ws_client():
    global data_changed, data  
  # url = "ws://192.168.29.180:8000/ws/buslocation/2"
    # url = "wss://probable-chainsaw-94wwxrw4xqr2p46v-8000.app.github.dev/ws/buslocation/2"
    url = "wss://navconnect.onrender.com/ws/buslocation/2"

    while True:  # Infinite loop for reconnection
        try:
            print("WebSocket: Connecting...")
            async with websockets.connect(url) as ws:
                print("WebSocket: Connected!")
                while True:
                    if data_changed:
                        print(f"Sending WebSocket Data: {data}")
                        await ws.send(data)
                        response = await ws.recv()
                        print(f"WebSocket Response: {response}")
                        data_changed = False
                    await asyncio.sleep(0.1)  # Prevent CPU overuse
        except Exception as e:
            print(f"WebSocket Error: {e}. Retrying in 5 seconds...")
            await asyncio.sleep(5)  # Wait before reconnecting

# Run WebSocket Client in an Async Loop
async def main():
    await ws_client()

print("Started WebSocket Client")
asyncio.run(main())
