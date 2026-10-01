/* -------------------------------------------------------------------------------
 * Project: ESP32 Ultrasonic Radar Visualizer
 * Author:  Nikhil A E
 * Date:    December 2025
 * Description: A Processing-based GUI that visualizes serial data from an 
 * ESP32 to create a radar-style obstacle detection map.
 * * License: MIT License
 * Copyright (c) 2025 Nikhil A E
 * * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * -------------------------------------------------------------------------------
 */

import processing.serial.*; 
import java.awt.event.KeyEvent; 
import java.io.IOException;

Serial myPort; 
String angle="";
String distance="";
String data="";
String noObject;
float pixsDistance;
int iAngle, iDistance;
int index1=0;
int index2=0;
PFont orcFont;

void setup() {
  size (1200, 700); // This sets the window size
  smooth();
  
  // -------------------------------------------------------------
  // CRITICAL STEP: SELECTING THE PORT
  // -------------------------------------------------------------
  // If the code crashes, change the [0] below to [1] or [2].
  // This selects which USB port your ESP32 is connected to.
  
String portName = "COM5";  
  // -------------------------------------------------------------
  
  // We use 115200 because that is what we put in the ESP32 code
  myPort = new Serial(this, portName, 115200);
  
  myPort.bufferUntil('.'); 
}

void draw() {
  fill(98,245,31);
  // Simulating motion blur and slow fade of the moving line
  noStroke();
  fill(0,4); 
  rect(0, 0, width, height-height*0.065); 
  
  fill(98,245,31); // Green color
  
  // Calls the functions for drawing the radar elements
  drawRadar(); 
  drawLine();
  drawObject();
  drawText();
}

void serialEvent (Serial myPort) { 
  // Reads the data from the Serial Port up to the character '.' 
  data = myPort.readStringUntil('.');
  data = data.substring(0,data.length()-1);
  
  index1 = data.indexOf(","); 
  angle= data.substring(0, index1); 
  distance= data.substring(index1+1, data.length()); 
  
  // Converts the String variables into Integers
  iAngle = int(angle);
  iDistance = int(distance);
}

void drawRadar() {
  pushMatrix();
  translate(width/2,height-height*0.074); 
  noFill();
  strokeWeight(2);
  stroke(98,245,31);
  // Draws the arc lines
  arc(0,0,(width-width*0.0625),(width-width*0.0625),PI,TWO_PI);
  arc(0,0,(width-width*0.27),(width-width*0.27),PI,TWO_PI);
  arc(0,0,(width-width*0.479),(width-width*0.479),PI,TWO_PI);
  arc(0,0,(width-width*0.687),(width-width*0.687),PI,TWO_PI);
  // Draws the angle lines
  line(-width/2,0,width/2,0);
  line(0,0,(-width/2)*cos(radians(30)),(-width/2)*sin(radians(30)));
  line(0,0,(-width/2)*cos(radians(60)),(-width/2)*sin(radians(60)));
  line(0,0,(-width/2)*cos(radians(90)),(-width/2)*sin(radians(90)));
  line(0,0,(-width/2)*cos(radians(120)),(-width/2)*sin(radians(120)));
  line(0,0,(-width/2)*cos(radians(150)),(-width/2)*sin(radians(150)));
  line((-width/2)*cos(radians(30)),0,width/2,0);
  popMatrix();
}

void drawObject() {
  pushMatrix();
  translate(width/2,height-height*0.074); 
  strokeWeight(9);
  stroke(255,10,10); // Red color for the object
  pixsDistance = iDistance*((height-height*0.1666)*0.025); 
  
  // Only draws the object if it is within 40cm
  if(iDistance<40){
    line(pixsDistance*cos(radians(iAngle)),-pixsDistance*sin(radians(iAngle)),(width-width*0.505)*cos(radians(iAngle)),-(width-width*0.505)*sin(radians(iAngle)));
  }
  popMatrix();
}

void drawLine() {
  pushMatrix();
  strokeWeight(9);
  stroke(30,250,60);
  translate(width/2,height-height*0.074); 
  line(0,0,(height-height*0.12)*cos(radians(iAngle)),-(height-height*0.12)*sin(radians(iAngle))); 
  popMatrix();
}

void drawText() { 
  pushMatrix();
  
  if(iDistance>40) {
    noObject = "Out of Range";
  }
  else {
    noObject = "In Range";
  }
  
  // 1. CLEAR THE TEXT AREA (Black Rectangle)
  fill(0,0,0);
  noStroke();
  rect(0, height-height*0.0648, width, height); // This erases old text
  
  fill(98,245,31);
  textSize(25);
  
  // 2. DRAW DISTANCE MARKERS ON RADAR
  text("10cm",width-width*0.3854,height-height*0.0833);
  text("20cm",width-width*0.281,height-height*0.0833);
  text("30cm",width-width*0.177,height-height*0.0833);
  text("40cm",width-width*0.0729,height-height*0.0833);
  
  // 3. DRAW THE STATUS TEXT (Adjusted Spacing)
  textSize(40);
  
  // Left Side: Object Status
  text("Object: " + noObject, 20, height-height*0.0277); 
  
  // Center: Angle
  text("Angle: " + iAngle +" °", width/2 - 50, height-height*0.0277); 
  
  // Right Side: Distance
  text("Dist: ", width-width*0.25, height-height*0.0277);
  if(iDistance<40) {
    // Prints the number NEXT to the label, not on top of it
    text(iDistance +" cm", width-width*0.15, height-height*0.0277);
  }
  
  // 4. DRAW ANGLE LABELS (The rotated text)
  textSize(25);
  fill(98,245,60);
  translate(width/2+width/2*cos(radians(30)),height-height*0.0833-width/2*sin(radians(30)));
  rotate(-radians(-60));
  text("30°",0,0);
  resetMatrix();
  translate(width/2+width/2*cos(radians(60)),height-height*0.0833-width/2*sin(radians(60)));
  rotate(-radians(-30));
  text("60°",0,0);
  resetMatrix();
  translate(width/2+width/2*cos(radians(90)),height-height*0.0833-width/2*sin(radians(90)));
  rotate(radians(0));
  text("90°",0,0);
  resetMatrix();
  translate(width/2+width/2*cos(radians(120)),height-height*0.0833-width/2*sin(radians(120)));
  rotate(radians(-30));
  text("120°",0,0);
  resetMatrix();
  translate(width/2+width/2*cos(radians(150)),height-height*0.0833-width/2*sin(radians(150)));
  rotate(radians(-60));
  text("150°",0,0);
  popMatrix(); 
}
