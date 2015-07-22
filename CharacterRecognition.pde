//PImage photo;
float hWeights[][]; // weights indexed by [hidden_node][input]
float hidden[]; // output of nodes in hidden layer
float hIns[]; // total input to each hidden node
float oWeights[][]; // weights indexed by [output_node][hidden_node]
float output[]; // outputs of nodes in output layer
float oIns[]; // total input to each output node
float input[]; //  input to nueral network (input[0] corresponds to special input of 1)
float expected[]; // expected output
boolean isTeaching=true;
float alpha = 1;

ProjectiveTransform p;

// XXX for each hWeights and oWeights, make sure you have a weight for each k in Weights[k][0] that corresponds to special input of 1
// XXX change inputs to be in range 0 to 1

void setup() {
  PImage photo = loadImage("b.jpg");
  image(photo, 0, 0);
  changeSize(photo);
  size(photo.width, photo.height);
  image(photo, 0, 0);
  photo.loadPixels();
  input = new float[photo.pixels.length + 1];
  float[] greyscale = greyscale(photo);
  input[0] = 1;
  for (int i = 1; i < input.length; i++)
    input[i] = greyscale[i-1];
  photo.updatePixels();
  image(photo, 0, 0);
  hidden = new float[501];
  hIns = new float[hidden.length];
  hWeights = new float[hidden.length][photo.pixels.length];
  for (float[] els : hWeights)
    for (float el : els)
      el = random(1);
  for (int i = 0; i < hWeights[0].length; i++)
    hWeights[0][i] = random(1);
  output = new float[27];
  oIns = new float[output.length];
  oWeights = new float[output.length][hidden.length];
  for (float[] els : oWeights)
    for (float el : els)
      el = random(1);
  for (int i = 0; i < oWeights[0].length; i++)
    oWeights[0][i] = random(1);
  expected = new float[output.length];
  setExpected();
  p = new ProjectiveTransform(photo);
  //  float[][] testMatrix1 = new float[][] {
  //    {
  //      2, -1, 0
  //    }
  //    , 
  //    {
  //      3, -5, 2
  //    }
  //    , 
  //    {
  //      1, 4, -2
  //    }
  //  };
  //  Matrix TM1 = new Matrix(testMatrix1);
  //  float[][] identity = new float[][] {
  //    {
  //      3, -2, 5
  //    }
  //    , 
  //    {
  //      0, -1, 6
  //    }
  //    , 
  //    {
  //      -4, 2, -1
  //    }
  //  };
  //  Matrix TM2 = new Matrix(identity);
  //
  //  Matrix TM4 = TM1.inverse();
  //
  //  Matrix result = TM1.multMatrix(TM4);
  //  for (int i = 0; i < 3; i++) {
  //    println(Arrays.toString(result.matrix[i]));
  //  }

  Matrix TM2 = p.qMatrix(new Point(1, 2, 1), new Point(3, 4, 1), new Point(5, 7, 1), new Point(36, 78, 1));
  Matrix TM3 = new Matrix(new float[][] {
    {
      1, 0, 1
    }
    , {
      0, 1, 1
    }
    , {
      0, 0, 1
    }
  }
  );
  Matrix asdf = TM2.multMatrix(TM3);
  float[][] result = asdf.matrix;
  println("" + result[0][0] / result[2][0] + " " + result[1][0] / result[2][0]);
  println("" + result[0][1] / result[2][1] + " " + result[1][1] / result[2][1]);
  println("" + result[0][2] / result[2][2] + " " + result[1][2] / result[2][2]);
}

void draw() {
  hIns = getIn(input, hWeights);
  hidden = functionG(hIns);
  oIns = getIn(hidden, oWeights);
  output = functionG(oIns);
  //  println(output);
  //  println("Error: " + err());
  if (err() > .01) {
    if (err() < 2) {
      alpha -= 0.01;
    }
    for (int j = 0; j < hidden.length; j++)
      hWeights[j] = changeWeights(deltaHid(j), hIns, hWeights[j]);
    for (int k = 0; k < output.length; k++)
      oWeights[k] = changeWeights(deltaOut(k), oIns, oWeights[k]);
  }

  p.display();
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


//takes array of inputs and 2d array of weights, returns array of weighted sums
float[] getIn(float[] in, float[][] weights) {
  float sums[] = new float[weights.length]; 
  float sum=0;
  for (int j = 0; j < weights.length; j++) {
    for (int i = 0; i < weights[0].length; i++)
      sum += weights[j][i]*in[i]; 
    sums[j] = sum; 
    sum = 0;
  }
  return sums;
}



//takes array of weighted sums (inputs), puts it through function G
float[] functionG(float ins[]) {
  float out[] = new float[ins.length]; 
  for (int i = 0; i < out.length; i++)
    out[i] = 1/(1+exp(-1*ins[i]));
  return out;
}

//takes input value, puts it through derivative of function G
float gPrime(float in) {
  return exp(-1*in)/sq(1+exp(-1*in));
}

//finds error value for each ouput/neuron value (a-z)
float err(int k) {
  return expected[k] - output[k]; //abs(output[k] - expected[k]); // XXX not supposed to be abs
}

float err() {
  float sum = 0;
  for (int i = 0; i < output.length; i++)
    sum += err(i) * err(i);
  return sum;
}

float deltaOut(int k) {
  return err(k)*gPrime(oIns[k]);
}

float deltaHid(int j) {
  float sum = 0;
  for (int k = 0; k < output.length; k++)
    sum += oWeights[k][j] * deltaOut(k);
  return sum * gPrime(hIns[j]);
}

//changes the weights for 1 neuron
float[] changeWeights(float delta, float[] in, float[] weights) {
  float[] newWeights = new float[weights.length];
  for (int i = 0; i < in.length; i++)
    newWeights[i] = weights[i] + alpha * in[i] * delta;
  return newWeights;
}

//resizes image for optimal recognition
void changeSize(PImage img) {
  //img.resize(img.width/4, img.height/4);
  img.resize(300, 300);
}

//greyscales the image, returns array of B&W pixels - either 0 = black or 1 = white
float[] greyscale(PImage img) {
  float result[] = new float[img.pixels.length];
  float threshold = 40;
  for (int i = 0; i < img.pixels.length; i++) {
    color col = img.pixels[i];
    if ((red(col)+blue(col)+green(col))/3 > threshold) {
      img.pixels[i] = color(255);
      result[i] = 1;
    } else {
      img.pixels[i] = color(0);
      result[i] = 0;
    }
  }
  return result;
}

//set expected result for each input picture (e.g. "a" will have expected [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
void setExpected() {
  for (float el : expected)
    el = 0;
  expected[2] = 1;
}

