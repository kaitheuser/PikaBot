/*  CSE176A Processing (Output Sample)
 *   This example code demonstrates how to transmit data between from the Processing Client
 *   to the Arduino client via Serial Communication (you can read about Serial Protocol here: 
 *   https://learn.sparkfun.com/tutorials/serial-communication/all)
 *   In this example, we transmit the number 1 (char datatype) from the Host PC to the Arduino when
 *   the gray square is clicked.
 *   Once the Arduino receives this character, it will cause the onboard LED to blink.
 *   THIS REQUIRES THE PROVIDED PROCESSING CODE TO BE RUNNING TO WORK!
 *   
*/

#include <Servo.h>

Servo servo;
char incoming_;             // It is better to transmit one character at a time from Processing to 
                            // the Arduino if we simply want to control the Arduino.
int spd = 5;

void setup() {
  // put your setup code here, to run once:
  servo.attach(9);
  Serial.begin(9600);
  servo.write(set_speed(0));
}

void loop() {  
  incoming_ = Serial.read();          // Read the serial buffer from the Processing script.

  if (incoming_ == '1') {             // '1' is sent from Processing if the mouse is pressed
                                      // over the gray square.
    servo.write(set_speed(spd));      // Turn the LED on and move the servo.
    Serial.println("Activated");
  }
  else{
    servo.write(set_speed(0));        // Turn the LED off and stop the servo.
  }
  delay(16);
}

int set_speed(int pos) {
  return (88 + pos);
}
