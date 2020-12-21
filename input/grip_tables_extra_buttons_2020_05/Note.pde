class Note {
  int note;
  ArrayList<Grip> grips;
  
  Note(int n) {
    grips = new ArrayList<Grip>();
    note = n;
  }
  
  void addGrip(Grip newGrip) {
    grips.add(newGrip);
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
