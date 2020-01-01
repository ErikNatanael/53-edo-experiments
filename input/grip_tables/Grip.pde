class Grip {
  boolean[] bits;
  float radius = 10;
  int numBitsOn = 0;
  
  Grip(int num) {
    bits = new boolean[10];
    for(int i = 0; i < 10; i++) {
      bits[i] = false;
    };
    numBitsOn = 0;
    String s = Integer.toBinaryString(num);
    for (int i = 0; i < s.length(); i++) {
      char ch = s.charAt(i);
      int bitIndex = (10-s.length()) + i;
      if(ch == '1') {
        bits[bitIndex] = true;
        numBitsOn++;
      }
    }
  }
  
  int gripDifference(Grip comp) {
    int diff = 0;
    for(int i = 0; i < 10; i++) {
      if(bits[i] != comp.bits[i]) diff++;
    }
    return diff;
  }
  
  void draw() {
    pushMatrix();
    translate(radius, radius);
    for(int i = 0; i < 10; i++) {
      float x = 0;
      if(i%2 == 1) x = radius*1.5;
      float y = 20 + (i/2) * radius * 1.5;
      stroke(0);
      if(bits[i]) fill(0);
      else noFill();
      ellipse(x, y, radius, radius);
    }
    popMatrix();
  }
  
  void printme() {
    for(boolean b : bits) {
      print(int(b));
    }
    println();
  }
};
