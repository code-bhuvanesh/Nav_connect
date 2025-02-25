# from fastapi import FastAPI
# from pydantic import BaseModel
# import uvicorn
# import socket
# import requests

# app = FastAPI()

# class LogMessage(BaseModel):
#     message: str

# @app.post("/log")
# async def receive_log(log: LogMessage):
#     print(f"[ESP32] {log.message}")
    
#     # Save logs to a file
#     with open("logs.txt", "a") as file:
#         file.write(log.message + "\n")
    
#     return {"status": "Received", "message": log.message}

# def get_local_ip():
#     try:
#         return socket.gethostbyname(socket.gethostname())
#     except:
#         return "Unknown"



# if __name__ == "__main__":
#     local_ip = get_local_ip()
    
#     print(f"🚀 FastAPI Server Running")
#     print(f"🌐 Local IP: {local_ip}")
    
#     uvicorn.run(app, host="0.0.0.0", port=8000)


from fastapi import FastAPI, BackgroundTasks
from fastapi.responses import HTMLResponse
from pydantic import BaseModel
import uvicorn
import socket
import os
import requests

app = FastAPI()
logs = [

]  # Stores logs in memory

ESP32_IP = "192.168.149.195:80"  # Replace with your ESP32's IP address

class LogMessage(BaseModel):
    message: str

@app.post("/log")
async def receive_log(log: LogMessage):
    if(log.message == "System start." and len(logs) != 0):
        logs.append("")
        logs.append("")
        logs.append("-" * 5 + "new logs" + "-" * 5)
    logs.append(log.message)
    print(f"[ESP32] {log.message}")

    with open("logs.txt", "a") as file:
        file.write(log.message + "\n")

    return {"status": "Received", "message": log.message}

@app.get("/logs")
async def get_logs():
    return logs

@app.post("/restart")
async def restart_server():
    logs.clear()
    os.system("sudo reboot")  # Change to 'shutdown /r' for Windows
    return {"status": "Restarting"}

@app.post("/restart-esp")
async def restart_esp():
    try:
        requests.get(f"http://{ESP32_IP}/restart", timeout=2)
        return {"status": "ESP32 Restarting"}
    except requests.exceptions.RequestException:
        return {"status": "ESP32 Unreachable"}

@app.get("/", response_class=HTMLResponse)
async def dashboard():
    return """
    <html>
    <head>
        <title>ESP32 Logs</title>
        <script>
             async function fetchLogs() {
                let response = await fetch('/logs');
                let data = await response.json();
                
                let logDisplay = document.getElementById('logDisplay');
                logDisplay.innerHTML = data.join('<br>');

                // Auto-scroll to the bottom
                logDisplay.scrollTop = logDisplay.scrollHeight;
            }
            setInterval(fetchLogs, 2000);

            async function restartServer() {
                await fetch('/restart', {method: 'POST'});
                alert('Restarting Server...');
            }

            async function restartESP() {
                let res = await fetch('/restart-esp', {method: 'POST'});
                let data = await res.json();
                alert(data.status);
            }
        </script>
        <style>
            body { background-color: #121212; color: white; font-family: Arial, sans-serif; text-align: center; padding: 20px; }
            button { background-color: #6200ea; color: white; border: none; padding: 10px 20px; margin: 10px; cursor: pointer; }
            button:hover { background-color: #3700b3; }
            .logs { height:70vh; max-height: 1500px; overflow-y: auto; border: 1px solid white; padding: 10px; margin-top: 20px; }
        </style>
    </head>
    <body>
        <h1>ESP32 Logs Dashboard</h1>
        <button onclick="restartServer()">Restart Server</button>
        <button onclick="restartESP()">Restart ESP32</button>
        <div class="logs" id="logDisplay">Fetching logs...</div>
    </body>
    </html>
    """

def get_local_ip():
    try:
        return socket.gethostbyname(socket.gethostname())
    except:
        return "Unknown"

if __name__ == "__main__":
    with open("logs.txt", "a") as file:
        file.write("*"*5 + "new message" + "*" * 5 + "\n")
    local_ip = get_local_ip()
    print(f"🚀 FastAPI Server Running at http://{local_ip}:8000")
    uvicorn.run(app, host="0.0.0.0", port=8000)
