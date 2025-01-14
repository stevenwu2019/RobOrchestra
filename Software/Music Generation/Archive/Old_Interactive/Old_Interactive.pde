import themidibus.*; //Import midi library
import java.lang.Math; //To get random numbers
import controlP5.*; //For GUI stuff

ControlP5 cp5;

//Open SimpleSynth to play on Mac

MidiBus myBus; //Creates a MidiBus object
int channel = 0; //set channel. 0 for speakers
int velocity = 120; //melody note volume
int noteLen = 100; //set chord length in milliseconds
boolean playing = true;
 
int tonic = 60; //set key to C major
int currentNote = 7;
int beatIndex = 0;
int snareMIDI = 36;
int tomMIDI = 37;
int[] scaleOffsets = {0, 2, 4, 5, 7, 9, 11, 12};
int[] majorOffsets = {0, 2, 4, 5, 7, 9, 11, 12};
int[] minorOffsets = {0, 2, 3, 5, 7, 8, 10, 12};
int[][] rhythms = {{1}, {2, 2}, {4, 4, 4, 4}};
int[] nextRhythm = {}; //Start on a whole note

float a = 1, b = 1, c = 1, d = 1, e = 1, f = 1, g = 1;
float[] p = {1/7, 1/7, 1/7, 1/7, 1/7, 1/7, 1/7};

float xyloDensity = 0.0;
float snareDensity = 0.0;
float tomDensity = 0.0;

int phraseLen = 16;
float[] xylo = {1.0, 0.00, 0.00, 0.00, 1.0, 0.00, 0.0, 0.0, 1.0, 0.00, 0.0, 0.00, 1.0, 0.0, 0.0, 0.0};
float[] tom = {1.0, -1.0, 0.0, -1.0, 0.5, -1.0, 0.0, -1.0, 1.0, -1.0, 0.0, -1.0, 0.5, 0.0, -1.0, 0.0};
float[] snare = {0.5, -1.0, 0.0, -1.0, 1.0, -1.0, 0.0, -1.0, 0.5, -1.0, 0.0, -1.0, 1.0, -1.0, 0.0, -1.0};



//sets up screen
void setup() {

  MidiBus.list(); // List all available Midi devices on STDOUT. Hopefully robots show up here!
  myBus = new MidiBus(this, 0, 1);
  
  size(400, 750);
  cp5 = new ControlP5(this);
  
  cp5.addButton("Major")
    .setBroadcast(false)
    .setValue(0)
    .setPosition(100, 50)
    .setSize(200, 19)
    .setBroadcast(true)
  ;
  cp5.addButton("Minor")
    .setBroadcast(false)
    .setValue(0)
    .setPosition(100, 100)
    .setSize(200, 19)
    .setBroadcast(true)
  ;
  cp5.addButton("Stop")
    .setBroadcast(false)
    .setValue(0)
    .setPosition(100, 150)
    .setSize(200, 19)
    .setBroadcast(true)
  ;
  cp5.addSlider("noteLen")
    .setPosition(100, 200)
    .setSize(200, 19)
    .setRange(100, 500) //I'd like a log scale...
    .setValue(250)
  ;
  cp5.addSlider("xyloDensity")
    .setPosition(100, 250)
    .setSize(200, 19)
    .setRange(0.0, 1.0)
    .setValue(0.0)
  ;
  cp5.addSlider("snareDensity")
    .setPosition(100, 300)
    .setSize(200, 19)
    .setRange(0.0, 1.0)
    .setValue(0.0)
  ;
  cp5.addSlider("tomDensity")
    .setPosition(100, 350)
    .setSize(200, 19)
    .setRange(0.0, 1.0)
    .setValue(0.0)
  ;
  for(int x = 'a'; x < 'h'; x++){
     cp5.addSlider(str((char)x))
    .setPosition(100, 400 + 50*(x - 'a'))
    .setSize(200, 19)
    .setRange(0, 1)
    .setValue(1)
  ; 
  }
  thread("playMelody");
}


//this function repeats indefinitely
void draw() {
  float sum = a + b + c + d + e + f + g;
  if(sum == 0){
    println("Problem!!!");
    return;
  }
  p[0] = a/sum;
  p[1] = b/sum;
  p[2] = c/sum;
  p[3] = d/sum;
  p[4] = e/sum;
  p[5] = f/sum;
  p[6] = g/sum;
}

void playMelody(){
  while(playing){
    int offset = 0;
    double r = Math.random();
    double xyloPlay = Math.random();
    double snarePlay = Math.random();
    double tomPlay = Math.random();
    double xyloThresh = Math.min(xylo[beatIndex] + xyloDensity, 1.0);
    double snareThresh = Math.min(snare[beatIndex] + snareDensity, 1.0);
    double tomThresh = Math.min(tom[beatIndex] + tomDensity, 1.0);
     //System.out.println("snarePlay = " + snarePlay + " threshold = " + snareThresh);
    if(snarePlay <= snareThresh) {
      int pitchSnare = snareMIDI;
      Note noteSnare = new Note(0, pitchSnare, 100);
      System.out.println("snare\n");
      myBus.sendNoteOn(noteSnare);
        
    }
    delay(2);
    if(tomPlay <= tomThresh) {
      int pitchTom = tomMIDI;
      Note noteTom = new Note(0, pitchTom, 100);
      myBus.sendNoteOn(noteTom);
        
    }
    delay(2);
    if(xyloPlay <= xyloThresh) {
      for(int x = 0; x < 7; x++){
        r -= p[x];
        if(r < 0){
          offset = x;
          break;
        }
      }
      int pitch = tonic + scaleOffsets[offset];
      
      
      Note noteXylo = new Note(channel, pitch, velocity);
      myBus.sendNoteOn(noteXylo);  
    }
    delay(noteLen);
    beatIndex = (beatIndex + 1) % phraseLen;
  }

  exit();
}

public void Major(int val){
  //This magically runs when the button gets clicked. I'm not sure how.
  scaleOffsets = majorOffsets;
  println("In major");
}

public void Minor(int val){
  //This magically runs when the button gets clicked. I'm not sure how.
  scaleOffsets = minorOffsets;
  println("In minor");
}

public void Stop(int val) {
  playing = false;
}

int getNextRhythm(){
  int in = (int)(Math.random()*rhythms.length);
  
  int[] temp = new int[max(nextRhythm.length-1, 0) + rhythms[in].length];
  
  int index = 0;
  for(int x = 1; x < nextRhythm.length; x++){
     temp[index++] = nextRhythm[x]; 
  }
  for(int x = 0; x < rhythms[in].length; x++){
     temp[index++] = rhythms[in][x]; 
  }
  nextRhythm = temp;
  return nextRhythm[0];
}

//processes delay in milliseconds
void delay(int time) {
  int current = millis();
  while (millis () < current+time){
    Thread.yield();
  } 
}