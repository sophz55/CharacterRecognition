class Point {

  float x, y, z;

  Point(float X, float Y, float Z) {
    x = X;
    y = Y;
    z = Z;
  }

  float[] getVector() {
    float[] result = new float[] {
      x, y, z
    }; 
    return result;
  }
}

