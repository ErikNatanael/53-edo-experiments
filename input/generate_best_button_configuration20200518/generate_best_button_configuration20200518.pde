import java.util.Collections;
import java.util.List;

boolean debug = false;

HashMap<Integer, Note> notes;
HashMap<String, Integer> configsTested;
ArrayList<Note> currentNotes;
String title = "major";
List buttons;
ArrayList<Grip> allGrips;

PFont titleFont;
PFont smallFont;

void setup() {
  size(1920, 1080);
  background(255);
  titleFont = loadFont("SpaceMono-Regular-32.vlw");
  smallFont = loadFont("SpaceMono-Regular-16.vlw");
  
  // test(); // debug function
  
  if(true) {
  
  int bestScalesDiff = Integer.MAX_VALUE;
  int bestChordsDiff = Integer.MAX_VALUE;
  
  configsTested = new HashMap<String, Integer>();
  
  buttons = new ArrayList<Integer>();
  buttons.add(53); // simulating an octave control
  buttons.add(1);
  buttons.add(2); // None of the good ones so far have had two 1s so we need the 2 to have all notes
  buttons.add(4);
  buttons.add(9);
  buttons.add(14);
  buttons.add(17);
  buttons.add(31);
  /*buttons.add(14);
  buttons.add(16);
  buttons.add(8);
  buttons.add(4);
  buttons.add(2);
  buttons.add(1);*/
  
  int numExtraButtons = 1;
  
  for(int i = 0; i < numExtraButtons; i++) {
    //buttons.add(9-i);
    buttons.add(3);
  }
  
  
  while(true) {
    
    // Change button values
    int firstButton = (Integer)buttons.get(buttons.size() - numExtraButtons);
    buttons.set(buttons.size() - numExtraButtons, firstButton + 1); 
    for(int i = buttons.size() - numExtraButtons; i < buttons.size() - 1; i++) {
      int val = (Integer)buttons.get(i);
      if(val == 53) {
        int nextButton = (Integer)buttons.get(i+1);
        buttons.set(i+1, nextButton+1);
        buttons.set(i, 0);
      }
    }


    if((Integer)buttons.get(buttons.size()-1) == 53) {
      println("All button combos checked");
      break;
    }
    
    // If the sum of all buttons is less than 106 you cannot play that note
    // so we don't need to check it
    int sum = 0;
    for(int i = 0; i < buttons.size(); i++) {
      sum += (Integer)buttons.get(i);
    }
    if(sum < 106) continue; // You wouldn't be able to play all the notes
    if(sum > 190) continue; // Unlikely to be good and be ale to play low notes
        
    // Sorting, hashing and checking should be much quicker than running
    // generateAllGrips() for duplicates
    List sortedList = new ArrayList(buttons);
    Collections.sort(sortedList);
    // Create "hash"
    String buttonsHash = "";
    for(int i = 0; i < sortedList.size(); i++) {
      buttonsHash += Integer.toString((Integer)sortedList.get(i)) + ",";
    }
    // Check if it has been tested before
    if(configsTested.containsKey(buttonsHash)) continue;
    else configsTested.put(buttonsHash, 0);
       
    allGrips = new ArrayList<Grip>();
    notes = new HashMap<Integer, Note>();
    currentNotes = new ArrayList<Note>();
    
    // Generate all possible grips i.e. combinations of buttons
    boolean allNotesExist = generateAllGrips();
    
    if(!allNotesExist) continue;
    
    
    int totalGripChange = 0;
    
    // major scales
    for(int i = 0; i < 53; i++) {
      currentNotes = new ArrayList<Note>();
      addMajorScale(i);
      int diff = getBestDiffForCurrentNotes();
      totalGripChange += diff;
      // println("major scale complete " + i);
    }
    //println("Best major scale: " + Integer.toString(bestMajorScale) + ", Worst major scale: " + Integer.toString(worstMajorScale));
    
    // minor scales
    for(int i = 0; i < 53; i++) {
      currentNotes = new ArrayList<Note>();
      addMinorScale(i);
      int diff = getBestDiffForCurrentNotes();
      totalGripChange += diff;
    }
    if(totalGripChange < bestScalesDiff) {
      bestScalesDiff = totalGripChange;
      println("Best config for scales so far: " + Integer.toString(bestScalesDiff));
      for(int i = 0; i < buttons.size(); i++) {
        print(buttons.get(i)); print(", ");
      }
      println();
    }

    totalGripChange = 0;
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
    if(totalGripChange < bestChordsDiff) {
      bestChordsDiff = totalGripChange;
      println("Best config for chords so far: " + Integer.toString(bestChordsDiff));
      for(int i = 0; i < buttons.size(); i++) {
        print(buttons.get(i)); print(", ");
      }
      println();
    }
    print("|");
    
  }
  }
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
  int diff = Integer.MAX_VALUE;
  int numStartGrips = currentNotes.get(0).grips.size();
  int bestStartGrip = 0;
  for(int startGrip = 0; startGrip < numStartGrips; startGrip++) {
    int thisDiff = 0;
    Grip lastGrip = currentNotes.get(0).grips.get(startGrip);
    thisDiff = recursiveDiff(0, 1, lastGrip);
    if(thisDiff < diff) {
      diff = thisDiff;
      bestStartGrip = startGrip;
    }
  }
  return diff;
}

// recursively get the best diff

int recursiveDiff(int thisDiff, int index, Grip lastGrip) {
  int localBestDiff = Integer.MAX_VALUE;
  int numGrips = currentNotes.get(index).grips.size();
  if(index < currentNotes.size()-1) {
    for(int i = 0; i < numGrips; i++) {
      Grip g = currentNotes.get(index).grips.get(i);
      int newDiff = recursiveDiff(thisDiff + lastGrip.gripDifference(g), index+1, g);
      if(newDiff < localBestDiff) localBestDiff = newDiff;
    }
  } else {
    for(int i = 0; i < numGrips; i++) {
      Grip g = currentNotes.get(index).grips.get(i);
      int newDiff = thisDiff + lastGrip.gripDifference(g);
      if(newDiff < localBestDiff) localBestDiff = newDiff;
    }
  }
  return localBestDiff;
}

void test() {
  
  buttons = new ArrayList<Integer>();
  buttons.add(53); // simulating an octave control
  buttons.add(31);
  buttons.add(9);
  buttons.add(16);
  buttons.add(8);
  buttons.add(4);
  buttons.add(2);
  buttons.add(1);
  Collections.shuffle(buttons);
  
  println("buttons: ");
  for(int i = 0; i < buttons.size(); i++) {
    println(buttons.get(i));
  }
  
  
  allGrips = new ArrayList<Grip>();
  notes = new HashMap<Integer, Note>();  
  println(generateAllGrips());
  println("note 31");
  Note note = notes.get(31);
  for(int i = 0; i < note.grips.size(); i++) {
    note.grips.get(i).printme();
    if(i < note.grips.size()-1) {
      println(note.grips.get(i).gripDifference(note.grips.get(i+1)));
    }
  }
  println();
  currentNotes = new ArrayList<Note>();
  int totalGripChange = 0;
    
  // major scales
  for(int i = 0; i < 53; i++) {
    currentNotes = new ArrayList<Note>();
    addMajorScale(i);
    int diff = getBestDiffForCurrentNotes();
    totalGripChange += diff;
  }
  
  println("Best diff: " + Integer.toString(totalGripChange));
  println();
}
