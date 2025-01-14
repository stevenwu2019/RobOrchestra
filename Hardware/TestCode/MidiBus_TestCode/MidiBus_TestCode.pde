//Xylobot Testing Code
//Plays through a chromatic scale on loop
//Used to test functionality of solenoids(they break randomly)

import themidibus.*; //Library documentation: http://www.smallbutdigital.com/themidibus.php

MidiBus myBus; //Creates a MidiBus object
int channel = 0; //channel xylobot is on
int noteLen = 1000; //set note length in milliseconds

//Bounds on range (MIDI values)
int lo = 60; //middle C (C4)
int hi = 76; //E5

//Parameters for directing stream of MIDI data
int input = 0;
int output = 1 ;

//Reference
String[] notes = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"};


//for making output readable
String midiToNote(int x){
   return notes[x%12] + " " + (x/12-1); 
}

//initialization
void setup() {
  MidiBus.list(); // List all available Midi devices on STDOUT. Hopefully robots show up here!
  System.out.println("");

  myBus = new MidiBus(this, input, output); //Creates bus to send MIDI data to xylobot

}

//loops
void draw() {
  
  //plays every chromatic note in the range
  for(int i = 0; i < 6; i++)
  {
    for(int x = lo; x < hi; x++){
      System.out.println("Testing note with MIDI value " + x);
      
      //creates a note object
      Note mynote = new Note(channel, x, 100);
      Note off = new Note(channel, x, 0);
      
      //sends note to Xylobot 
      myBus.sendNoteOn(mynote);
      
      //time between each note
      delay(1000);
      myBus.sendNoteOn(off);
      delay(500);
    }
  }

}