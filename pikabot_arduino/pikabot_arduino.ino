/** 
  * Authors: Alex Chow, Kai Chuen Tan
  * 
  * An interative code for Pikabot.
  * Pikabot will output an audio response like "Pika" when Pikabot is touched on the belly (touch sensor). 
  * Pikabot will also dance by rotating the continuous servo in the CW and CCW direction repeatedly when
  * the user chooses the "Dance" option from the Processing UI.
  * THIS REQUIRES THE PROVIDED PROCESSING CODE TO BE RUNNING TO WORK!
  *
  */

#include <Servo.h>          // Include servo library

Servo servo;                // Create servo object
char incoming_;             // A signal that indicates whether to dance or not from Processing.
bool outgoing_;             // Transmitted Data from the touch sensor to the Arduino, then to Processing.

int spd = 3;                // Servo rotation speed 
int turnCount = 0;          // Counter variable that decides when to rotate the servo in the opposite direction.

int touchSensorPin = 2;     // Touch sensor pin
int touchSensorValue = 0;   // A signal that indicates whether the touch sensor is touched.
         

void setup() {
  // put your setup code here, to run once:
  servo.attach(9);          // Attach servo to pin 9.
  Serial.begin(9600);       // Begin serial at 9600 Baud Rate.
  servo.write(set_speed(0));// Make sure the servo does not rotate.
}

void loop() {  
  incoming_ = Serial.read();                        // Read the serial buffer from the Processing script.

  if (incoming_ == '1') {                           // '1' is sent from Processing if the dance option is selected.
    if (turnCount < 20) {
      servo.write(set_speed(spd));                  // Rotate the servo
    } else if(turnCount >= 20 && turnCount < 35) {
      servo.write(set_speed(-spd));                 // Change the servo rotation direction
    } else {
      turnCount = 0;                                // Reset the turn count.
    }
    Serial.println("Activated");      
    turnCount++;                                    // Increment turn count.
  }
  else{
    servo.write(set_speed(0));                      // Stop the servo.
  }

  touchSensorValue = digitalRead(touchSensorPin);   // Read the digital input value from the touch sensor

  // Output 1 to Processing when the touch sensor is touched
  if ((bool)touchSensorValue != outgoing_) {
    Serial.println(1);
    outgoing_ = touchSensorValue;                   // Reintialized the outgoing_ value to the touchSensorValue.
  }
  
  delay(16);                                        // Delay 16 ms to ensure the servo rotates smoothly.
}

// User-defined function for the servo speed settings.
int set_speed(int pos) {
  return (87 + pos);
}
