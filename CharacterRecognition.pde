//PImage photo;
float hWeights[][];
float hidden[];
float hIns[];
float oWeights[][];
float output[];
float oIns[];
float input[];
float expected[];
boolean isTeaching=true;
float alpha = 1;

void setup() {
  PImage photo = loadImage("a.jpg");
  image(photo, 0, 0);
  changeSize(photo);
  size(photo.width, photo.height);
  image(photo, 0, 0);
  photo.loadPixels();
  input = new float[photo.pixels.length + 1];
 // input[0] = 255;
  float[] greyscale = greyscale(photo);
  for (int i = 0; i < input.length; i++)
    input[i] = greyscale[i];// - 1];
  photo.updatePixels();
  image(photo, 0, 0);
  hidden = new float[500];
  hIns = new float[hidden.length];
  hWeights = new float[hidden.length][photo.pixels.length];
  for (float[] els : hWeights)
    for (float el : els)
      el = 0.5;
  output = new float[26];
  oIns = new float[output.length];
  oWeights = new float[output.length][hidden.length];
  for (float[] els : oWeights)
    for (float el : els)
      el = 0.5;
  expected = new float[output.length];
  setExpected();
}

void draw() {
  hIns = getIn(input, hWeights);
  hidden = functionG(hIns);
  oIns = getIn(hidden, oWeights);
  output = functionG(oIns);
  println(output);
  if (err() > 20) {
    if (err() < 30) {
      alpha -= 0.01;
      for (int j = 0; j < hidden.length; j++)
        changeWeights(deltaHid(j), hIns, hWeights[j]);
      for (int k = 0; k < output.length; k++)
        changeWeights(deltaOut(k), oIns, oWeights[k]);
    }
  }
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
  return abs(output[k] - expected[k]);
}

float err() {
  float sum = 0;
  for (int i = 0; i < output.length; i++)
    sum += err(i);
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
void changeWeights(float delta, float[] in, float[] weights) {
  for (int i = 0; i < weights.length; i++)
    weights[i] += alpha * in[i] * delta;
}

//resizes image for optimal recognition
void changeSize(PImage img) {
  //img.resize(img.width/4, img.height/4);
  img.resize(300, 300);
}

//greyscales the image, returns array of B&W pixels - either 0 or 255
float[] greyscale(PImage img) {
  float result[] = new float[img.pixels.length];
  float threshold = 40;
  for (int i = 0; i < img.pixels.length; i++) {
    color col = img.pixels[i];
    if ((red(col)+blue(col)+green(col))/3 > threshold) {
      img.pixels[i] = color(255);
      result[i] = 255;
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
  expected[0] = 1;
}

