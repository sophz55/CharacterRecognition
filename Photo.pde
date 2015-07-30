class Photo {

  PImage pi;
  float[] values; //0 = black, 1 = white
  boolean isSpace = false;  
  int expect = 0;

  Photo(PImage img) {
    pi = img;
    values = new float[pi.pixels.length];
    for (int i = 0; i < pi.pixels.length; i++) {
      if (pi.pixels[i] == color(255))
        values[i] = 1;
      if (pi.pixels[i] == color(0))
        values[i] = 0;
    }
  }

  Photo(int minX, int maxX, int minY, int maxY, PImage pic) {
    PImage img = createImage(maxX - minX, maxY - minY, RGB);
    img.loadPixels();
    for (int j = 0; j < img.height; j++)
      for (int i = 0; i < img.width; i++)
        img.pixels[j * img.width + i] = pic.pixels[(minY + j) * pic.width + minX + i];
    img.updatePixels();
    pi = img;
    values = new float[pi.pixels.length];
    for (int i = 0; i < pi.pixels.length; i++) {
      if (pi.pixels[i] == color(255))
        values[i] = 1;
      if (pi.pixels[i] == color(0))
        values[i] = 0;
    }
  }

  //greyscales the image, returns array of B&W pixels - either 0 = black or 1 = white
  void greyscale() {
    float result[] = new float[pi.pixels.length];
    float threshold = 180;
    for (int i = 0; i < pi.pixels.length; i++) {
      color col = pi.pixels[i];
      if (brightness(col) >= threshold) {
        pi.pixels[i] = color(255);
        result[i] = 1;
      } else {
        pi.pixels[i] = color(0);
        result[i] = 0;
      }
    }
    pi.updatePixels();
    values = result;
  }

  //resizes image for optimal recognition
  void changeSize() {
    //img.resize(img.width/4, img.height/4);
    pi.resize(30, 30);
    greyscale();
  }
}

