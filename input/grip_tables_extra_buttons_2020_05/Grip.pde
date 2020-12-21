class Grip {
  //ArrayList<Boolean> grip;
  boolean[] grip;
  int noteNum;
  float radius = 10;
  int numBitsOn = 0;
  
  Grip(boolean[] grip_, int noteNum_) {
    grip = grip_;
    noteNum = noteNum_;
    numBitsOn = 0;
    for(Boolean g : grip) {
      if(g) { numBitsOn++; }
    }

  }
  
  int gripDifference(Grip comp) {
    int diff = 0;
    for(int i = 0; i < grip.length; i++) {
      if(grip[i] != comp.grip[i]) diff++;
    }
    return diff;
  }
  
  void draw() {
    pushMatrix();
    translate(radius, radius);
    for(int i = 0; i < grip.length; i++) {
      float x = 0;
      //if(i%2 == 1) x = radius*1.5;
      float y = 20 + (i) * radius * 1.5;
      stroke(0);
      if(grip[i]) fill(0);
      else noFill();
      ellipse(x, y, radius, radius);
    }
    popMatrix();
  }
  
  void printme() {
    for(Boolean b : grip) {
      print(int(b));
    }
    println();
  }
};
