import java.io.*;
import java.util.*;

Photo photo;
boolean isTeaching = true;
boolean isCropping = true;

Learn l1;

ProjectiveTransform p;

void setup() {

  PImage pic = loadImage("b.jpg");//"Test.jpg");
  photo = new Photo(pic);
  photo.changeSize();
  p = new ProjectiveTransform(photo.getPI());
}

void draw() {
  if (isCropping)
    p.display();
  else {
    frame.setSize(p.projection.width, p.projection.height);
    photo.pi = p.projection;
    photo.greyscale();
    image(photo.pi, 0, 0);
    if (isTeaching) {
      l1 = new Learn(photo.pi);
      l1.stuff();
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

