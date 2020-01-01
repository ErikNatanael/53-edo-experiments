/*( // wrapping at 106
var wraps = ();
106.do { | note |
  var playable = false;
  wraps[note] = List[];
  2.do{ | wrap |
    var numBinaryOnes = (note + (wrap*106)).asBinaryDigits.sum;

    if( numBinaryOnes <= 5) {
      playable = true;
      wraps[note].add(wrap);
    };
  };
  if(playable == false) {
    ("note " + note + " cannot be played using 5 fingers with this wrap").postln;
  };
};
wraps.postln;

)*/

ArrayList<Note> notes;
int wrap = 106*2;
int maxNum = int(pow(2, 10)-1);
String title = "C major";

PFont titleFont;
PFont smallFont;

void setup() {
  size(1920, 1080);
  background(255);
  titleFont = loadFont("SpaceMono-Regular-32.vlw");
  smallFont = loadFont("SpaceMono-Regular-16.vlw");

  println("wrap: ", wrap);
  println("maxNum: ", maxNum);
  
  Note nn = new Note(0, 106, 1023);
  for(Grip g : nn.grips) {
    g.printme();
  }
  
  notes = new ArrayList<Note>();
  addMajorScale(0);
  
}

void addMajorScale(int offset) {
  int lastNote = offset;
  for(int i = 0; i < 8; i++) {
    int newNote = 0;
    if(i==0) newNote = offset;
    else {
      switch(i%7) {
        case 1: newNote = 9*2; break;
        case 2: newNote = 8*2; break;
        case 3: newNote = 5*2; break;
        case 4: newNote = 9*2; break;
        case 5: newNote = 9*2; break;
        case 6: newNote = 8*2; break;
        case 0: newNote = 5*2; break;
      }
      newNote = newNote + lastNote;
    }
    lastNote = newNote;
    Note n = new Note(newNote, wrap, maxNum);
    notes.add(n);
  }
}

void addMinorScale(int offset) {
  int lastNote = offset;
  for(int i = 0; i < 8; i++) {
    int newNote = 0;
    if(i==0) newNote = offset;
    else {
      switch(i%7) {
        case 1: newNote = 9*2; break;
        case 2: newNote = 5*2; break;
        case 3: newNote = 9*2; break;
        case 4: newNote = 9*2; break;
        case 5: newNote = 5*2; break;
        case 6: newNote = 9*2; break;
        case 0: newNote = 8*2; break;
      }
      newNote = newNote + lastNote;
    }
    lastNote = newNote;
    Note n = new Note(newNote, wrap, maxNum);
    notes.add(n);
  }
}

void addChromatic106() {
  int step = 1;
  for(int i = 0; i < 106; i++) {
    Note n = new Note(i*step, wrap, maxNum);
    notes.add(n);
  }
}

void draw() {
  background(255);
  textFont(titleFont);
  fill(0);
  text(title, 0, 38);
  float diagramW = 50;
  float diagramH = 120;
  int perLine = int(width/diagramW);
  Grip lastGrip = notes.get(0).grips.get(0);
  for(int i = 0; i < notes.size(); i++) {
    pushMatrix();
    int line = i/perLine;
    float x = (i - (line*perLine)) * diagramW;
    float y = 50 + diagramH * line;
    translate(x, y);
    
    fill(0);
    textFont(smallFont);
    text(Integer.toString(notes.get(i).note), 0, 16);
    Grip g = notes.get(i).getClosestGrip(lastGrip);
    g.draw();
    lastGrip = g;
    popMatrix();
  }
  
}
