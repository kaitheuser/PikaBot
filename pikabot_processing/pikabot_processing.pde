/** 
  * Authors: Alex Chow, Kai Chuen Tan
  * 
  * The software interface for Pikabot. Utilizes the abstracted Page,
  * Menu, and Screen class to implement the different menu and general
  * screens that the user navigates through. This code is used in
  * parallel with Arduino to control the Pikabot's hardware behaviors.
  *
  */

import processing.serial.*;
import processing.sound.*;

//--------------------------Global variables--------------------------//
Serial myPort;        // Create object from Serial class
String val;           // Data received from the serial port -- note that all data transmitted through the Arduino is sent as a string!
float fval;           // Placeholder variable to store the data received from the Arduino.
Page[] pages;         // The global array for referencing the different pages
PFont f;              // Global font
int colorVal = 255;   // Background color value (white)
Page currPage;        // Reference to current Page
SoundFile[] songs;    // Global reference to music SoundFiles
SoundFile pikaSound;  // The sound effect file for when touching -> "pika pika"
int totalFrames = 25; // Total number of frames for animated GIF
float counter = 0;    // Frame counter.
//-----------------------End of global variables-----------------------//


//---------------Built-in Processing methods to implement--------------//
/**
  * Implements setup method. Sets up all global variables where applicable.
  */
void setup()
{
  String portName = Serial.list()[2]; //Change the 0 to a 1 or 2 etc. to match your port -- usually the default works.
  myPort = new Serial(this, portName, 9600); //Make sure that the baudrate (default: 9600) matches that of the Arduino.
  
  // set window size
  size(640, 480);
  
  // initialize all Pages. See helper methods below
  pages = new Page[] {
    constructMenuPlay(),
    constructMenuMusicType(),
    constructScreenPlayMusic(),
    constructScreenPutToy(),
    constructScreenPlayToy()
  };
  
  // set current page to be the first
  currPage = pages[0];
  
  // initialize all music SoundFiles
  songs = new SoundFile[] {
    new SoundFile(this, "Bach-minuet-in-g.wav"),
    new SoundFile(this, "Ed Sheeran - Perfect.wav"),
    new SoundFile(this, "Attack.wav"),
    new SoundFile(this, "Elvis_Presley_-_Cant_Help_Falling_In_Love.wav")
  };
  
  // set up the sound upon touch
  pikaSound = new SoundFile(this, "pika pika.mp3");
  
  // set up global font  
  f = createFont("Courier New", 16, true);
  textFont(f);
  fill(0);
}


/**
  * Implements draw method abstracted to a simple class (Page) and method (render)
  * to display the current page. Also detects if the touch sensor has been touched
  * at any point in time to play the sound "pika pika."
  */
void draw()
{
    currPage.render();    // each Menu or Screen will have its own render method
    detectTouch();        // detects whether the capacitive sensor has been touched
}


/**
  * Implements keyPressed method. The keyboard controls UP and DOWN arrow
  * only works with choosing items in a Menu Page.
  */
void keyPressed() {
  if (key == CODED) {
    
    // check if the current page is a Menu
    if (currPage instanceof Menu) {
      if (keyCode == DOWN) {
        ((Menu)currPage).nextMenuItem();
      }
      else if (keyCode == UP) {
        ((Menu)currPage).prevMenuItem();
      }
    }
  }
  
  // if the ENTER key is pressed, navigate to next page
  if (keyCode == ENTER) {
    currPage.navigate();
  }
}
//------------End of Built-in Processing methods to implement----------//


//------------------------General helper methods-----------------------//
/**
  * Helper method for detecting touch. Reads signals from the connected
  * Arduino and plays the "pika pika" sound for every touch.
  */
void detectTouch() {
  if ( myPort.available() > 0) // checks to see if the port in the setup is available
  {
    val = myPort.readStringUntil('\n'); // read in the value from the serial port
    
    if (val != null) {                                 
      fval = int(trim(val));     // convert the string to an int
     
      // If the value is 1, play the "Pika pika" sound effect.
      if (fval == 1) {
        pikaSound.play();
      }
    }
  }
}
//---------------------End of general helper methods-------------------//


//----------------Helper methods for constructing pages----------------//
/**
  * Helper method for constructing the first menu for users to choose whether
  * to play music or to play toy with them. The next pages are indexed 1 and
  * 3 respectively in the pages[] array.
  */
Menu constructMenuPlay() {
  String id = "play";
  String[] choices = {
    "Play music",
    "Play toy with me"
  };
  int[] nextPageIndices = {1, 3};
  
  return new Menu(id, nextPageIndices, choices, colorVal);
}


/**
  * Helper method for constructing the music type menu for users to choose
  * which genre of music to play. The next page is always indexed 2 but based
  * on our implementation, we needed to duplicate it so that any choice leads
  * to that page in the pages[] array.
  */
Menu constructMenuMusicType() {
  String id = "music_type";
  String[] choices = {
    "Classical",
    "Pop",
    "Rock",
    "Oldies",
  };
  int[] nextPageIndices = {2, 2, 2, 2};
  
  return new Menu(id, nextPageIndices, choices, colorVal);
}


/**
  * Helper method for constructing the playing music screen. A touch from the
  * user always stops the music and return the user to the main menu screen.
  */
Screen constructScreenPlayMusic() {
  boolean playMusic = true;
  String id = "play_music";
  int nextPageIndex = 0;    // Set next page as the main screen
  return new Screen(id, nextPageIndex, "music notes.jpg", colorVal, playMusic);
}


/**
  * Helper method for constructing the put toy instructions screen. A touch
  * from the user leads them to the next screen where the servo will turn
  * Pikachu around back and forth as if it's playing the toy.
  */
Screen constructScreenPutToy() {
  boolean playToy = false;
  String id = "put_toy";  
  int nextPageIndex = 4; // Set next page as the play toy screen
  return new Screen(id, nextPageIndex, "put toy.jpg", colorVal, playToy);
}


/**
  * Helper method for constructing the play toy screen. On this screen,
  * music will play, and the servo will turn the Pikabot around back and
  * forth as if it's playing the toy. A touch from the user leads them
  * to back to the main menu.
  */
Screen constructScreenPlayToy() {
  boolean playToy = true;
  String id = "play_toy";
  int nextPageIndex = 0;    // Set next page as the main screen
  return new Screen(id, nextPageIndex, "dancePika/Pikabot-00.png", colorVal, playToy);
}
//------------End of helper methods for constructing pages--------------//


//--------------------------Class definitions---------------------------//
/******************************************************************************
  * The abstracted class Page is meant to serve as an umbrella to categorize
  * any single screen that of a certain function, e.g. a menu page, 
  * a general screen page.
  *****************************************************************************/
abstract class Page {
  String id;                                // generic string id for identification (unused)

  /**
    * Constructor
    */
  Page(String id) {
    this.id = id;
  }
  
  abstract void render();                   // a generic render method to be called inside draw()
  abstract void navigate();                 // to navigate to the next page upon touch
  abstract void onEnter();                  // any setup code to be done upon entering the page. 
                                            //   Must be called at the end of navigate.
}


/******************************************************************************
  * The Menu class generalizes a menu page and implements the functionality of
  * selecting the menu list for the different choices. It implements all of 
  * Page's abstract methods.
  *****************************************************************************/
class Menu extends Page {
  String[] choices;            // the menu item texts to display
  int[] nextPageIndices;       // the indices of next page for each choice 
  int selectedIndex;           // index of the currently selected menu item
  int colorVal;                // color value for the background
  int menuIntervalPixels;      // the space between each menu item on screen
  
  
  /**
    * Constructor
    */
  Menu(String id, int[] nextPageIndices, String[] choices, int colorVal) {
    super(id);
    this.choices = choices;
    this.nextPageIndices = nextPageIndices;
    this.colorVal = colorVal;
    this.menuIntervalPixels = choices.length + 1;    // +1 to fit items on the screen
  }
  
  
  /**
    * Implements the render method. For each choice, we append a prefix to front
    * of it. If it's not selected, the prefix is simply two spaces. If it is
    * selected, the prefix will have a ">" sign to indicate selection.
    */
  void render() {
    background(colorVal);
    
    for(int i = 0; i < choices.length; i++) {
      String prefix = ("  ");
      if(i == selectedIndex) {
        prefix = "> ";
      }
      
      // use menuIntervalPixels to space out the menu items more evenly
      text(prefix + choices[i], 10, max(
        i * 80,
        height / menuIntervalPixels + i * height / menuIntervalPixels
      ));
    }    
  }
    
  /**
    * Method to be called on this Menu instance to select the next Menu item.
    * Utilizes the min function -- any choice up to choices.length - 1 will be
    * chosen, and will be capped at choices.length - 1.
    */
  void nextMenuItem() {
    selectedIndex = min(selectedIndex + 1, choices.length - 1);
  }
  
  /**
    * Method to be called on this Menu instance to select the previous Menu item.
    * Utilizes the max function -- any choice up greater than 0 will be chosen,
    * and will not be allowed to go past 0.
    */
  void prevMenuItem() {
    selectedIndex = max(0, selectedIndex - 1);
  }
  
  
  /**
    * Implements the navigate method. For any Menu, first choose the index of the 
    * next page in pages[] corresponding to the index of the selected menu item.
    * Then, we access the Page whose index is nextPageIndex. If the next Screen
    * is supposed to play music, then set the Screen's music index to selectedIndex.
    * This works for our purposes.
    */
  void navigate() {
    if (nextPageIndices[selectedIndex] < pages.length) {    // check bounds
      int nextPageIndex = nextPageIndices[selectedIndex];
      currPage = pages[nextPageIndex];
      
      // set the right music index based on user's choice
      if (currPage instanceof Screen && ((Screen)currPage).playMusic) {
        ((Screen)currPage).setMusicIndex(selectedIndex);
      }
      
      currPage.onEnter();
    } else {
      println("page not implemented!");
    }
  }
  
  
  /**
    * Empty onEnter method.
    */
  void onEnter() {}
}


/******************************************************************************
  * The Screen class generalizes a screen page and implements the functionality
  * of selecting performing a task--e.g., play music or turn servo. It 
  * implements all of Page's abstract methods.
  *****************************************************************************/
class Screen extends Page {
  int nextPageIndex;            // the index of the next Page
  PImage img;                   // the image to display 
  int musicIndex;               // the index of the piece in songs[]
  int imageScaleFactor = 10;    // the image scale factor to size with window
  int colorVal;                 // background color
  boolean playMusic;            // whether this screen is supposed to play music
  
  /**
    * Constructor. musicIndex is not set since we'll set it before entering
    * the page anyway.
    */
  Screen(String id, int nextPageIndex, String imageFileName, int colorVal, boolean playMusic) {
    super(id); 
    this.img = loadImage(imageFileName);
    this.colorVal = colorVal;
    this.nextPageIndex = nextPageIndex;
    this.playMusic = playMusic;
  }
  
  
  /**
    * Implements the render method. Simple as putting an image on the screen.
    */
  void render() {
    // clears screen
    background(colorVal);    
    
    if (currPage == pages[4]) {     // for the playing toy page
      
      // place the Pikachu dancing up and down gif
      image(
        loadImage("dancePika/Pikabot-" + nf(int(counter), 2) + ".png"),
        width / imageScaleFactor,
        height / imageScaleFactor,
        (imageScaleFactor - 2) * (width / imageScaleFactor),
        (imageScaleFactor - 2) * (height / imageScaleFactor)
      );
      
      // set up font and text
      textFont(f,20);
      fill(0); 
      text("Come dance with Pikabot!",110,450);
      
      // for displaying the looped gif animation correctly
      counter = counter + 0.2;
      if (counter >= totalFrames){
        counter = 0.0;
      }
      
      // turn the servo at the same time
      turnServo();
    } else {                        // for the play music page
      
      // place the music notes image on the screen
      image(
        img,
        width / imageScaleFactor,
        height / imageScaleFactor,
        (imageScaleFactor - 2) * (width / imageScaleFactor),
        (imageScaleFactor - 2) * (height / imageScaleFactor)
      );
    }
    
  }
  
  /**
    * Implements the navigate method. If this page is supposed to play music,
    * stop the music and go to next page. If the next page is supposed to play
    * music, set its music index.
    */
  void navigate() {
    if (nextPageIndex < pages.length) {    // check bounds
      if (currPage instanceof Screen && ((Screen)currPage).playMusic) {
        songs[this.musicIndex].stop();
        myPort.write('0');                 // writes a '0' to the Arduino
                                           // to stop the servo from turning
      }
      
      currPage = pages[nextPageIndex];
      if (currPage instanceof Screen && ((Screen)currPage).playMusic) {
        ((Screen)currPage).setMusicIndex(this.musicIndex);
      }
      
      currPage.onEnter();
    } else {
      println("page not implemented!");
    }
  }
  
  
  /**
    * Setter for musicIndex.
    */
  void setMusicIndex(int musicIndex) {
    this.musicIndex = musicIndex;
  }
  
  
  /**
    * Implements onEnter method. If this screen is supposed to play music,
    * then play it. Assumes musicIndex has been correctly set.
    */
  void onEnter() {
    if (playMusic) playMusic(musicIndex);
    if ( playMusic && currPage == pages[4] ) turnServo();
  }
  
  
  /**
    * A simple wrapper method for playing music.
    */
  void playMusic(int musicIndex) {
    if(musicIndex > -1) songs[musicIndex].play();
  }
  
  /**
    * Turns the servo on the connected Arduino by sending a '1'. The Arduino
    * code will handle this.
    */
  void turnServo() {
    myPort.write('1');
  }
}
//-----------------------End of Class definitions------------------------//
