class Note {
  int note;
  ArrayList<Grip> grips;
  
  Note(int n, int wrap, int maxNum) {
    grips = new ArrayList<Grip>();
    note = n;
    int numWraps = 0;
    while(((numWraps+1) * wrap) + n <= maxNum) numWraps++;
    for(int i = 0; i < numWraps+1; i++) {
      Grip g = new Grip((i * wrap) + n);
      grips.add(g);
    }
  }
  
  Grip getClosestGrip(Grip compGrip) {
    int smallestDiff = 100;
    Grip closest = grips.get(0);
    for(Grip g : grips) {
      int diff = g.gripDifference(compGrip);
      if(diff < smallestDiff) {
        smallestDiff = diff;
        closest = g;
      }
    }
    return closest;
  }
  
};
