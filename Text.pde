class Text {

  ArrayList<Photo> lines = new ArrayList<Photo>();
  ArrayList<Photo> words = new ArrayList<Photo>();
  ArrayList<Photo> letters = new ArrayList<Photo>();

  int wordThres = 7; //threshold for length of space between words

  Photo textPhoto;

  Text(Photo img) {
    textPhoto = img;
    findLines();
    for (int i = 0; i < lines.size(); i++)
      findWords(lines.get(i));
    for (int i = 0; i < words.size(); i++)
      findLetters(words.get(i));
    for (int i = 0; i < letters.size(); i++)
      letters.get(i).changeSize();
  }

  void findLines() {
    boolean whiteLine = true;
    boolean isLine = false;

    //coordinates
    int startY = 0;
    int endY = 0;

    textPhoto.pi.loadPixels();

    for (int i = 0; i < textPhoto.pi.height; i++) {
      whiteLine = true;
      for (int j = 0; j < textPhoto.pi.width; j++) {
        if (textPhoto.values[i*textPhoto.pi.width + j] == 0) {
          whiteLine = false;
          if (!isLine) {
            isLine = true;
            startY = i;
          }
        }
      }
      if (whiteLine && isLine) {
        isLine = false;
        endY = i + 1;
        lines.add(new Photo(0, textPhoto.pi.width, startY, endY, textPhoto.pi));
      }
    }
  }

  void findWords(Photo linePhoto) {
    boolean whiteSpace = true;
    boolean isWord = false;
    int lenWhiteSpace = 0;

    //coordinates
    int startX = 0;
    int endX = 0;

    linePhoto.pi.loadPixels();

    for (int i = 0; i < linePhoto.pi.width; i++) {
      whiteSpace = true;
      for (int j = 0; j < linePhoto.pi.height; j++) {
        if (linePhoto.values[j * linePhoto.pi.width + i] == 0) {
          whiteSpace = false;
          if (!isWord) {
            isWord = true;
            startX = i;
          }
        }
      }
      if (whiteSpace) {
        lenWhiteSpace++;
        if (lenWhiteSpace >= wordThres && isWord) {
          isWord = false;
          endX = i + 1;
          words.add(new Photo(startX, endX, 0, linePhoto.pi.height, linePhoto.pi));
        }
      } else
        lenWhiteSpace = 0;
    }
  }

  void findLetters(Photo wordPhoto) {
    boolean whiteSpace = true;
    boolean isLetter = false;

    //coordinates
    int startX = 0;
    int endX = 0;

    wordPhoto.pi.loadPixels();

    for (int i = 0; i < wordPhoto.pi.width; i++) {
      whiteSpace = true;
      for (int j = 0; j < wordPhoto.pi.height; j++) {
        if (wordPhoto.values[j * wordPhoto.pi.width + i] == 0) {
          whiteSpace = false;
          if (!isLetter) {
            isLetter = true;
            startX = i;
          }
        }
      }
      if (whiteSpace && isLetter) {
        isLetter = false;
        endX = i + 1;
        letters.add(new Photo(startX, endX, 0, wordPhoto.pi.height, wordPhoto.pi));
      }
    }
    
    addSpace();
  }
  
  void addSpace(){
    PImage blankSpace = createImage(30,30,RGB);
    blankSpace.loadPixels();
    for (int i = 0; i < blankSpace.pixels.length; i++)
      blankSpace.pixels[i] = color(255);
    blankSpace.updatePixels();
    letters.add(new Photo(blankSpace));
    letters.get(letters.size() - 1).isSpace = true;
  }
}
