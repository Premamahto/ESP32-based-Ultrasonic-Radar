/* * -------------------------------------------------------------------------------
 * Project: ESP32 Ultrasonic Radar System (LCD + Buzzer)
 * Based on original by Nikhil A E, December 2025
 * Description: Real-time obstacle detection using an HC-SR04 ultrasonic sensor 
 * mounted on a sweeping Servo motor, with live readout on I2C LCD and 
 * buzzer alert when object enters threshold range.
 * License: MIT License
 * -------------------------------------------------------------------------------
 */

#include <ESP32Servo.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>

// Pin Definitions
const int trigPin = 12;  
const int echoPin = 14;  
const int servoPin = 13; 
const int buzzerPin = 27;

const int threshold = 20;  // cm - adjust detection range here

long duration;
int distance;

Servo myServo; 
LiquidCrystal_I2C lcd(0x25, 16, 2);

void setup() {
  pinMode(trigPin, OUTPUT); 
  pinMode(echoPin, INPUT); 
  pinMode(buzzerPin, OUTPUT);
  
  Serial.begin(115200); 
  
  // ESP32 Servo setup
  myServo.setPeriodHertz(50); 
  myServo.attach(servoPin, 500, 2400); 

  // LCD setup
  Wire.begin(21, 22);
  lcd.init();
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print("Radar Ready");
  delay(1000);
  lcd.clear();
}

void loop() {
  // Sweep from 15 to 165 degrees
  for(int i=15; i<=165; i++){  
    myServo.write(i);
    delay(30);
    distance = calculateDistance();
    
    sendData(i, distance);
    updateLCD(i, distance);
  }
  
  // Sweep back from 165 to 15 degrees
  for(int i=165; i>15; i--){  
    myServo.write(i);
    delay(30);
    distance = calculateDistance();
    
    sendData(i, distance);
    updateLCD(i, distance);
  }
}

// Function to calculate distance via Ultrasonic Sensor
int calculateDistance(){ 
  digitalWrite(trigPin, LOW); 
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH); 
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  
  duration = pulseIn(echoPin, HIGH); 
  distance = duration * 0.034 / 2;

  // Buzzer alert logic
  if (distance > 0 && distance < threshold) {
    digitalWrite(buzzerPin, HIGH);
  } else {
    digitalWrite(buzzerPin, LOW);
  }

  return distance;
}

// Function to format serial output for Processing/Visualizers
void sendData(int angle, int dist) {
  Serial.print(angle); 
  Serial.print(","); 
  Serial.print(dist); 
  Serial.print("."); 
}

// Function to update the LCD with angle + distance
void updateLCD(int angle, int dist) {
  lcd.setCursor(0, 0);
  lcd.print("Angle: ");
  lcd.print(angle);
  lcd.print("   ");

  lcd.setCursor(0, 1);
  lcd.print("Dist: ");
  lcd.print(dist);
  lcd.print(" cm   ");
}