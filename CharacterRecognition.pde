import java.io.*;
import java.util.*;

Photo photo;
boolean isCropping = true;
boolean isTeaching = true;

Learn learner;

ProjectiveTransform p;

int x = 0;
int y = 0;

ArrayList<Photo> allCharacters = new ArrayList<Photo>();

void setup() {

  size(displayWidth, displayHeight);

  /*PImage pic = loadImage("1.png");
   pic.resize(displayWidth/2, displayWidth*pic.height/pic.width/2);
   photo = new Photo(pic);
   // if (!isCropping)
   // photo.changeSize();*/
  //p = new ProjectiveTransform(photo.pi);

  PImage pic;
 // for (int i = 1; i < 27; i++) {
   // pic = loadImage(i+".png");
    pic = loadImage("b1.jpg");
    pic.resize(displayWidth/2, displayWidth*pic.height/pic.width/2);
    photo = new Photo(pic);
    photo.greyscale();
    Text croppedPhoto = new Text(photo);
    ArrayList<Photo> chars = croppedPhoto.letters;
    for (int j = 0; j < chars.size (); j++) {
      chars.get(j).changeSize();
      allCharacters.add(chars.get(j));
      if (allCharacters.get(allCharacters.size()-1).isSpace) {
        allCharacters.get(allCharacters.size()-1).expect = 27;
        allCharacters.remove(allCharacters.size()-1);
      } else {
        allCharacters.get(allCharacters.size()-1).expect = 1;//i;
      }
    }
  //}

  display(allCharacters);
  println("done1");
  Learn learner = new Learn();
}

void draw() {
  // background(255);
  /*  if (isCropping) {
   p.display();
   for (int i = 0; i < height; i+=20)
   line (width/2, i, width, i);
   } else {
   //frame.setSize(p.projection.width, p.projection.height);
   photo.pi = p.projection;
   photo.greyscale();
   //photo.pi.updatePixels();
   //image(photo.pi, 0, 0);
   
   Text croppedPhoto = new Text(photo);
   ArrayList<Photo> chars = croppedPhoto.letters;
   frame.setSize(displayWidth/2, displayHeight/2);
   
   display(chars);
   
   }
   */
}

void display(ArrayList<Photo> chars) {
  for (int i = 0; i < chars.size (); i++) {
    if (i == 0) {
      x = 0;
      y = 0;
    }
    //show stuff
    image(chars.get(i).pi, x, y);
    line(x, y, x+chars.get(i).pi.width, y);
    line(x+chars.get(i).pi.width, y, x+chars.get(i).pi.width, y + chars.get(i).pi.height);
    line(x+chars.get(i).pi.width, y +chars.get(i).pi.height, x, y +chars.get(i).pi.height);
    line(x, y, x, y +chars.get(i).pi.height);
    if (x + 60 < displayWidth)
      x+=30;
    else {
      x = 0;
      y+=30;
    }
  }
}

//find point closest to mouse when mouse is pressed
void mousePressed() {
  float minDist = -1;
  int closest = -1;
  float d;

  for (int i = 0; i < p.scope.length; i++) {
    d = dist(p.scope[i].x, p.scope[i].y, mouseX, mouseY);
    if (d < minDist || closest == -1) {
      minDist = d;
      closest = i;
    }
  }
  p.chosen = closest;
}

//move chosen vertex of scope to mouse coordinates
void mouseDragged() {
  int mx = mouseX;
  if (mx < 0)
    mx = 0;
  if (mx >= p.original.width)
    mx = p.original.width;
  p.scope[p.chosen].x = mx;
  int my = mouseY;
  if (my < 0)
    my = 0;
  if (my >= p.original.height)
    my = p.original.height;
  p.scope[p.chosen].y = my;
  p.updateTransform();
}

void keyPressed() {
  if (isCropping && keyCode == ENTER) {
    isCropping = false;
  }
}

