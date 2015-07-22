class Photo {

  PImage pi;

  Photo(PImage img) {
    pi = img;
  }

  PImage getPI() {
    return pi;
  }

  //greyscales the image, returns array of B&W pixels - either 0 = black or 1 = white
  void greyscale() {
    float result[] = new float[pi.pixels.length];
    float threshold = 170;
    for (int i = 0; i < pi.pixels.length; i++) {
      color col = pi.pixels[i];
      if ((red(col)+blue(col)+green(col))/3 >= threshold) {
        pi.pixels[i] = color(255);
        result[i] = 1;
      } else {
        pi.pixels[i] = color(0);
        result[i] = 0;
      }
    }
    pi.updatePixels();
   // return result;
  }

  //resizes image for optimal recognition
  void changeSize() {
    //img.resize(img.width/4, img.height/4);
    pi.resize(640, 480);
  }
}

