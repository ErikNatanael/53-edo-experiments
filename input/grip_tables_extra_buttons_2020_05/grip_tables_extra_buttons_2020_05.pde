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

boolean debug = false;

HashMap<Integer, Note> notes;
ArrayList<Note> currentNotes;
String title = "major";
IntList buttons;
ArrayList<Grip> allGrips;

PFont titleFont;
PFont smallFont;

void setup() {
  size(1920, 1080);
  background(255);
  titleFont = loadFont("SpaceMono-Regular-32.vlw");
  smallFont = loadFont("SpaceMono-Regular-16.vlw");
  
  buttons = new IntList();
  buttons.append(53); // simulating an octave control
  buttons.append(14);
  buttons.append(17);
  buttons.append(5);
  buttons.append(9);
  //buttons.append(3);
  //buttons.append(5);
  //buttons.append(31);
  
  buttons.append(31);
  buttons.append(16);
  buttons.append(8);
  //buttons.append(5);
  buttons.append(4);
  buttons.append(2);
  //buttons.append(18);
  buttons.append(1);
  //buttons.append(1);
  
  allGrips = new ArrayList<Grip>();
  notes = new HashMap<Integer, Note>();
  currentNotes = new ArrayList<Note>();
  
  // Generate all possible grips i.e. combinations of buttons
  generateAllGrips();

  Note nn = notes.get(0);
  for(Grip g : nn.grips) {
    g.printme();
  }
  
  long totalGripChange = 0;
  
  int bestMajorScale = Integer.MAX_VALUE;
  int worstMajorScale = 0;
  // major scales
  for(int i = 0; i < 53; i++) {
    currentNotes = new ArrayList<Note>();
    addMajorScale(i);
    int diff = getBestDiffForCurrentNotes();
    totalGripChange += diff;
    if(diff < bestMajorScale) {
      bestMajorScale = diff;
    };
    if(diff > worstMajorScale) {
      worstMajorScale = diff;
    }
    println("major scale complete " + i);
  }
  println("Best major scale: " + Integer.toString(bestMajorScale) + ", Worst major scale: " + Integer.toString(worstMajorScale));
  
  // minor scales
  int bestMinorScale = Integer.MAX_VALUE;
  int worstMinorScale = 0;
  for(int i = 0; i < 53; i++) {
    currentNotes = new ArrayList<Note>();
    addMinorScale(i);
    int diff = getBestDiffForCurrentNotes();
    totalGripChange += diff;
    if(diff < bestMinorScale) {
      bestMinorScale = diff;
    }
    if(diff > worstMinorScale) {
      worstMinorScale = diff;
    }
    println("minor scale complete " + i);
  }
  println("Best minor scale: " + Integer.toString(bestMinorScale) + ", Worst minor scale: " + Integer.toString(worstMinorScale));
  println("Total diff for all major and minor scales: " + Long.toString(totalGripChange));
  totalGripChange = 0;
  debug = false;
  // major chords
  for(int i = 0; i < 53; i++) {
    currentNotes = new ArrayList<Note>();
    addMajorSevenChord(i);
    totalGripChange += getBestDiffForCurrentNotes();
  }
  // minor chords
  for(int i = 0; i < 53; i++) {
    currentNotes = new ArrayList<Note>();
    addMinorChord(i);
    totalGripChange += getBestDiffForCurrentNotes();
  }
  debug = false;
  println("Total diff for all major and minor chords: " + Long.toString(totalGripChange));
  totalGripChange = 0;
  debug = false;
  for(int i = 0; i < 53; i++) {
    currentNotes = new ArrayList<Note>();
    addMajorNineHarmonicSevenChord(i);
    totalGripChange += getBestDiffForCurrentNotes();
  }
  
  for(int i = 0; i < 53; i++) {
    currentNotes = new ArrayList<Note>();
    addMinorSevenChord(i);
    totalGripChange += getBestDiffForCurrentNotes();
  }

  for(int i = 0; i < 53; i++) {
    currentNotes = new ArrayList<Note>();
    addMinorColouredChord(i);
    totalGripChange += getBestDiffForCurrentNotes();
  }
  
  for(int i = 0; i < 53; i++) {
    currentNotes = new ArrayList<Note>();
    addMinorColouredChord2(i);
    totalGripChange += getBestDiffForCurrentNotes();
  }
  debug = false;
  println("Total diff for all extra coloured chords: " + Long.toString(totalGripChange));
  totalGripChange = 0;
  debug = false;
  for(int i = 0; i < 53; i++) {
    currentNotes = new ArrayList<Note>();
    addEagle12Scale(i);
    totalGripChange += getBestDiffForCurrentNotes();
  }
  println("Total diff for all extra scales and materials: " + Long.toString(totalGripChange));
  /*totalGripChange = 0;
  currentNotes = new ArrayList<Note>();
  for(int i = 0; i < 53; i++) {
    currentNotes = new ArrayList<Note>();
    addChromatic53(i);
    totalGripChange += getBestDiffForCurrentNotes();
  }
  totalGripChange += getBestDiffForCurrentNotes();
  println("Total diff for all chromatic scales: " + Long.toString(totalGripChange));*/
  noLoop();
}

void addMajorScale(int offset) {
  int lastNote = offset;
  for(int i = 0; i < 8; i++) {
    int newNote = 0;
    if(i==0) newNote = offset;
    else {
      switch(i%7) {
        case 1: newNote = 9; break;
        case 2: newNote = 8; break;
        case 3: newNote = 5; break;
        case 4: newNote = 9; break;
        case 5: newNote = 9; break;
        case 6: newNote = 8; break;
        case 0: newNote = 5; break;
      }
      newNote = newNote + lastNote;
    }
    lastNote = newNote;
    Note n = notes.get(newNote);
    currentNotes.add(n);
  }
}

void addMajorSevenChord(int offset) {
  int lastNote = offset;
  for(int i = 0; i < 4; i++) {
    int newNote = 0;
    if(i==0) newNote = offset;
    else {
      switch(i%7) {
        case 1: newNote = 17; break;
        case 2: newNote = 14; break;
        case 3: newNote = 14; break;
      }
      newNote = newNote + lastNote;
    }
    lastNote = newNote;
    Note n = notes.get(newNote);
    currentNotes.add(n);
  }
}
void addMajorHarmonicSevenChord(int offset) {
  int lastNote = offset;
  for(int i = 0; i < 4; i++) {
    int newNote = 0;
    if(i==0) newNote = offset;
    else {
      switch(i%7) {
        case 1: newNote = 17; break;
        case 2: newNote = 14; break;
        case 3: newNote = 12; break;
      }
      newNote = newNote + lastNote;
    }
    lastNote = newNote;
    Note n = notes.get(newNote);
    currentNotes.add(n);
  }
}
void addMajorNineHarmonicSevenChord(int offset) {
  int lastNote = offset;
  for(int i = 0; i < 5; i++) {
    int newNote = 0;
    if(i==0) newNote = offset;
    else {
      switch(i%7) {
        case 1: newNote = 9; break;
        case 2: newNote = 8; break;
        case 3: newNote = 14; break;
        case 4: newNote = 12; break;
      }
      newNote = newNote + lastNote;
    }
    lastNote = newNote;
    Note n = notes.get(newNote);
    currentNotes.add(n);
  }
}
void addMinorChord(int offset) {
  int lastNote = offset;
  for(int i = 0; i < 3; i++) {
    int newNote = 0;
    if(i==0) newNote = offset;
    else {
      switch(i%7) {
        case 1: newNote = 14; break;
        case 2: newNote = 17; break;
      }
      newNote = newNote + lastNote;
    }
    lastNote = newNote;
    Note n = notes.get(newNote);
    currentNotes.add(n);
  }
}

void addMinorSevenChord(int offset) {
  int lastNote = offset;
  for(int i = 0; i < 4; i++) {
    int newNote = 0;
    if(i==0) newNote = offset;
    else {
      switch(i%7) {
        case 1: newNote = 14; break;
        case 2: newNote = 17; break;
        case 3: newNote = 14; break;
      }
      newNote = newNote + lastNote;
    }
    lastNote = newNote;
    Note n = notes.get(newNote);
    currentNotes.add(n);
  }
}

void addMinorColouredChord(int offset) {
  int lastNote = offset;
  for(int i = 0; i < 6; i++) {
    int newNote = 0;
    if(i==0) newNote = offset;
    else {
      switch(i%7) {
        case 1: newNote = 5; break;
        case 2: newNote = 9; break;
        case 3: newNote = 17; break;
        case 4: newNote = 4; break;
        case 5: newNote = 10; break;
      }
      newNote = newNote + lastNote;
    }
    lastNote = newNote;
    Note n = notes.get(newNote);
    currentNotes.add(n);
  }
}

void addMinorColouredChord2(int offset) {
  int lastNote = offset;
  for(int i = 0; i < 7; i++) {
    int newNote = 0;
    if(i==0) newNote = offset;
    else {
      switch(i%7) {
        case 1: newNote = 14; break;
        case 2: newNote = 35; break;
        case 3: newNote = 13; break;
        case 4: newNote = -9; break;
        case 5: newNote = -17; break;
        case 6: newNote = -5; break;
      }
      newNote = newNote + lastNote;
    }
    lastNote = newNote;
    Note n = notes.get(newNote);
    currentNotes.add(n);
  }
}



void addMinorScale(int offset) {
  int lastNote = offset;
  for(int i = 0; i < 8; i++) {
    int newNote = 0;
    if(i==0) newNote = offset;
    else {
      switch(i%7) {
        case 1: newNote = 9; break;
        case 2: newNote = 5; break;
        case 3: newNote = 9; break;
        case 4: newNote = 9; break;
        case 5: newNote = 5; break;
        case 6: newNote = 9; break;
        case 0: newNote = 8; break;
      }
      newNote = newNote + lastNote;
    }
    lastNote = newNote;
    Note n = notes.get(newNote);
    currentNotes.add(n);
  }
}

void addEagle12Scale(int offset) {
  int lastNote = offset;
  for(int i = 0; i < 13; i++) {
    int newNote = 0;
    if(i==0) newNote = offset;
    else {
      switch(i%12) {
        case 1: newNote = 5; break;
        case 2: newNote = 4; break;
        case 3: newNote = 5; break;
        case 4: newNote = 4; break;
        case 5: newNote = 5; break;
        case 6: newNote = 4; break;
        case 7: newNote = 5; break;
        case 8: newNote = 5; break;
        case 9: newNote = 3; break;
        case 10: newNote = 6; break;
        case 11: newNote = 3; break;
        case 0: newNote = 5; break;
      }
      newNote = newNote + lastNote;
    }
    lastNote = newNote;
    Note n = notes.get(newNote);
    currentNotes.add(n);
  }
}

void addChromatic53(int offset) {
  int step = 1;
  for(int i = 0; i < 53; i++) {
    Note n = notes.get(i*step + offset);
    currentNotes.add(n);
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
  int totalGripChange = 0;
  Grip lastGrip = currentNotes.get(0).grips.get(0);
  for(int i = 0; i < currentNotes.size(); i++) {
    pushMatrix();
    int line = i/perLine;
    float x = (i - (line*perLine)) * diagramW;
    float y = 50 + diagramH * line;
    translate(x, y);
    
    fill(0);
    textFont(smallFont);
    int noteNum = currentNotes.get(i).note;
    text(Integer.toString(noteNum), 0, 16);
    Grip g = currentNotes.get(i).getClosestGrip(lastGrip);
    totalGripChange += lastGrip.gripDifference(g);
    g.draw();
    lastGrip = g;
    popMatrix();
  }
  textFont(smallFont);
  text("diff: " + Integer.toString(totalGripChange), diagramW * currentNotes.size(), 16);
  
}

boolean generateAllGrips() {
  int numDifferentGrips = (int)Math.pow(2, buttons.size());
  for(int i = 0; i < numDifferentGrips; i++) {
    boolean[] bits = new boolean[buttons.size()]; 
    // init to false
    for(int j = 0; j < buttons.size(); j++) {
      bits[j] = false;
    }
    // Get the bit representation for this grip number (not note number) i.e. the grip
    /*String binaryString = Integer.toBinaryString(i);
    for(int j = 0; j < binaryString.length(); j++) {
      if(binaryString.charAt(binaryString.length() - 1 -j) == '1') {
        bits[bits.length-1-j] = Boolean.TRUE; 
      }
    }*/
    
    int input = i;

    
    for (int j = buttons.size()-1; j >= 0; j--) {
        bits[j] = (input & (1 << j)) != 0;
    }
    // Convert to note number
    int noteNum = 0;
    for(int j = 0; j < buttons.size(); j++) {
      if(bits[j] == true) {
        noteNum += (Integer)buttons.get(j);
      }
    }
    // Create grip and store
    Grip newGrip = new Grip(bits, noteNum);
    if(!notes.containsKey(noteNum)) {
      notes.put(noteNum, new Note(noteNum));
    }
    /*
    print(Integer.toString(i) + " : " + Integer.toString(noteNum) + " : ");
    for(int j = 0; j < buttons.size(); j++) {
      if(bits[j]) print("1"); else print("0");
    }
    println();*/
    notes.get(noteNum).addGrip(newGrip);
  }
  
  // Check that all notes exist
  for(int i = 0; i <= 106; i++) {
    if(!notes.containsKey(i)) {
      return false;
    }
  }
  return true;
}

// returns the number of finger changes for playing the notes in the currentNotes
// if
int getBestDiffForCurrentNotes() {
  BestBranch bestBranch = new BestBranch();
  int numStartGrips = currentNotes.get(0).grips.size();
  int bestStartGrip = 0;
  for(int startGrip = 0; startGrip < numStartGrips; startGrip++) {
    int thisDiff = 0;
    Grip lastGrip = currentNotes.get(0).grips.get(startGrip);
    thisDiff = recursiveDiff(0, 1, lastGrip, bestBranch);
    if(thisDiff < bestBranch.diff) {
      bestBranch.diff = thisDiff;
      bestStartGrip = startGrip;
    }
  }
  return bestBranch.diff;
}

// recursively get the best diff

int recursiveDiff(int thisDiff, int index, Grip lastGrip, BestBranch bestSoFar) {
  int localBestDiff = Integer.MAX_VALUE;
  // If this branch is already poor don't continue searching
  if(thisDiff > bestSoFar.diff) {
    return Integer.MAX_VALUE;
  }
  int numGrips = currentNotes.get(index).grips.size();
  if(index < currentNotes.size()-1) {
    for(int i = 0; i < numGrips; i++) {
      Grip g = currentNotes.get(index).grips.get(i);
      int newDiff = recursiveDiff(thisDiff + lastGrip.gripDifference(g), index+1, g, bestSoFar);
      if(newDiff < localBestDiff) localBestDiff = newDiff;
    }
  } else {
    // This is the last note in the sequence
    for(int i = 0; i < numGrips; i++) {
      Grip g = currentNotes.get(index).grips.get(i);
      int newDiff = thisDiff + lastGrip.gripDifference(g);
      if(newDiff < localBestDiff) {
        localBestDiff = newDiff;
        if(localBestDiff < bestSoFar.diff) {
          bestSoFar.diff = localBestDiff;
        }
      }
    }
  }
  return localBestDiff;
}
