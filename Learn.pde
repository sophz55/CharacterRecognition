class Learn {

  float hWeights[][]; // weights indexed by [hidden_node][input]
  float hidden[]; // output of nodes in hidden layer
  float hIns[]; // total input to each hidden node
  float oWeights[][]; // weights indexed by [output_node][hidden_node]
  float output[]; // outputs of nodes in output layer
  float oIns[]; // total input to each output node
  float input[]; //  input to nueral network (input[0] corresponds to special input of 1)
  float expected[]; // expected output
  float alpha = 1;

  void Learn(PImage img) {
    Photo photo = new Photo(img);
    image(photo.pi, 0, 0);
    photo.changeSize();
    size(photo.pi.width, photo.pi.height);
    image(photo.pi, 0, 0);
    photo.pi.loadPixels();
    hidden = new float[501];
    hIns = new float[hidden.length];
    hWeights = new float[hidden.length][photo.pi.pixels.length];
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
  }

  void stuff() {
    while (err () > 0.01) {
      hIns = getIn(input, hWeights);
      hidden = functionG(hIns);
      oIns = getIn(hidden, oWeights);
      output = functionG(oIns);
      println(output);
      println("Error: " + err());
      if (err() < 2) {
        alpha -= 0.01;
      }
      for (int j = 0; j < hidden.length; j++)
        hWeights[j] = changeWeights(deltaHid(j), hIns, hWeights[j]);
      for (int k = 0; k < output.length; k++)
        oWeights[k] = changeWeights(deltaOut(k), oIns, oWeights[k]);
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

  //set expected result for each input picture (e.g. "a" will have expected [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
  void setExpected() {
    for (float el : expected)
      el = 0;
    expected[2] = 1;
  }
}

