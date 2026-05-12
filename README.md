# PARQ — IoT Based Smart Parking System

![PARQ Logo](logo_app.jpeg)

A full-stack IoT smart parking system built as a third-year mini project.
PARQ allows users to pre-book parking slots via a mobile app, with real-time slot availability tracked by ultrasonic sensors and a servo motor-all synced through Firebase Realtime Database.
##Demo

## Hardware Working Model

[Click here to watch demo](working_vd.mp4)

## App Screenshots

| Login | Sign Up | Home |
|---|---|---|
| ![Login](login_img.png) | ![Signup](signup_img.png) | ![Home](prebookpg_img.png) |

| Booking Details | Slot Map | Profile |
|---|---|---|
| ![Booking](prebookdetails_img.png) | ![Map](map_app.jpeg) | ![Profile](profile_img.png) |

## Hardware & Backend

| Firebase Database | Hardware Model |
|---|---|
| ![Firebase](firebase_database.jpeg) | ![Hardware](hardware_img.jpeg) |

## Features

- Pre-book parking slots through the PARQ mobile app
- Login/Sign up to book
- Profile page with user details, booking history and edit option
- Enter booking details — date and time
- Booking confirmation screen 
- Real-time slot availability displayed on an interactive map (green = available, orange = booked, red = occupied, yellow= selected)
- Firebase Realtime Database syncs app bookings to hardware instantly
- Arduino reads booking data and operates servo motor for correct slot selection
- Ultrasonic sensors detect vehicle occupancy and update slot status in real time

## System Architecture  
```
PARQ Mobile App (Flutter)
        |
        | (Read/Write)
        ▼
Firebase Realtime Database
        |
        | (Stream)
        ▼
ESP8266 (Wi-Fi Bridge)
        |
        | (Serial - UART)
        ▼
Arduino Uno
        |
        |---> Servo Motor (Gate Control)
        |---> 4x HC-SR04 Ultrasonic Sensors (Occupancy Detection)
```
## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter (Dart) |
| Backend / Database | Firebase Realtime Database |
| Wi-Fi Microcontroller | ESP8266 |
| Hardware Controller | Arduino Uno |
| Sensors | HC-SR04 Ultrasonic (x4) |
| Actuator | Servo Motor |
| Communication | UART Serial (Arduino ↔ ESP8266) |

## Hardware Components

- Arduino Uno
- ESP8266 Wi-Fi Module
- 4x HC-SR04 Ultrasonic Sensors
- Servo Motor (SG90)
- Jumper wires
- Custom foam board parking model

  ## Project Structure

```
IOT-Smart-Parking-parq/
├── parking_controller.ino      # Arduino: sensor reading + servo gate control
├── firebase_bridge.ino         # ESP8266: Firebase streaming + serial communication
├── app/                        # Flutter mobile app source code
├── logo_app.jpeg               # PARQ app logo
├── login_img.png               # App login screen
├── signup_img.png              # App signup screen
├── prebookpg_img.png           # App home/prebook screen
├── prebookdetails_img.png      # App booking details screen
├── map_app.jpeg                # App slot map screen
├── profile_img.png             # App profile screen
├── firebase_database.jpeg      # Firebase database screenshot
├── hardware_img.jpeg           # Hardware model photo
└── working_vd.mp4              # Hardware demo video
```

### Hardware
1. Connect HC-SR04 sensors to Arduino:
   - Sensor 1: Trig = 3, Echo = 4
   - Sensor 2: Trig = 6, Echo = 7
   - Sensor 3: Trig = 8, Echo = 9
   - Sensor 4: Trig = 11, Echo = 12
   - VCC → 5V, GND → GND
2. Connect servo motor to pin 9
3. Connect ESP8266 to Arduino via SoftwareSerial:
   - ESP TX → Arduino RX (pin 12)
   - ESP RX → Arduino TX (pin 13)
4. Upload `parking_controller.ino` to Arduino Uno
5. Replace credentials in `firebase_bridge.ino` and upload to ESP8266

