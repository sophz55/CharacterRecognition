class Learn {

  //Roz
  float[][] rand1;
  float[][] rand2;
  JSONArray ar1;
  JSONArray ar2;
  JSONArray valuesh; //to put into the file
  JSONArray valueso; // to put into the file
  JSONArray inh; //coming from the file
  JSONArray ino; //coming from the file
  String w = "weight";
  float[][] hWeightss;//weights read in by file indexed by [hidden][input]
  float[][] oWeightss; //weights read in by file indexed by [output][hidden]

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
    float[] temp = photo.greyscale();
    input = new float[temp.length+1];
    input[0] = 1;
    for (int i = 0; i< temp.length; i++)
      input[i+1] = temp[i];
    hidden = new float[501];
    hIns = new float[hidden.length];
    hWeights = new float[hidden.length][input.length];
    /*for (float[] els : hWeights)
     for (float el : els)
     el = random(1);
     for (int i = 0; i < hWeights[0].length; i++)
     hWeights[0][i] = random(1);*/
    output = new float[27];
    oIns = new float[output.length];
    oWeights = new float[output.length][hidden.length];
    /*for (float[] els : oWeights)
     for (float el : els)
     el = random(1);
     for (int i = 0; i < oWeights[0].length; i++)
     oWeights[0][i] = random(1);*/

    expected = new float[output.length];
    setExpected();


    //roz
    ar1 = new JSONArray();
    ar2 = new JSONArray();
    /*  for (int i = 0; i < hidden.length; i++) {
     for (int j = 0; j < input.length; j++) {
     JSONObject ob1 = new JSONObject();
     ob1.setFloat(w, rand1[i][j]);
     ar1.setJSONObject(j*4 + i, ob1);
     }
     for (int k = 0; k < 27; k++) {
     JSONObject ob2 = new JSONObject();
     ob2.setFloat(w, rand2[k][i]);
     ar2.setJSONObject(i*4 + k, ob2);
     }
     }*/
    //saveJSONArray(ar1, "data/weighth.json");
    //saveJSONArray(ar2, "data/weighto.json");
  }

  void stuff() {
    while (err () > 0.01) {
      hIns = getIn(input, hWeights);
      hidden = functionG(hIns);
      oIns = getIn(hidden, oWeights);
      output = functionG(oIns);
      println(output);
      println("Error: " + err());
      if (err() < 1) {
        alpha -= 0.01;
      }
      for (int j = 0; j < hidden.length; j++)
        hWeights[j] = changeWeights(deltaHid(j), hIns, hWeights[j]);
      for (int k = 0; k < output.length; k++)
        oWeights[k] = changeWeights(deltaOut(k), oIns, oWeights[k]);
      writefile();
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

  void writefile() { //puts weights into the file weights.json
    valuesh = new JSONArray();
    valueso = new JSONArray();

    for (int i = 0; i < 500; i ++) {

      JSONObject jobh = new JSONObject();
      JSONObject jobo = new JSONObject();

      for (int j = 0; j < 27; j++) {
        jobo.setFloat(w, oWeights[j][i]);
        valueso.setJSONObject(i, jobo);
      }
      for (int k = 0; k < 900; k++) {
        jobh.setFloat(w, hWeights[i][k]);
        valuesh.setJSONObject(i, jobh);
      }
    }
    saveJSONArray(valuesh, "data/weighth.json");
    saveJSONArray(valueso, "data/weighto.json");
  }

  void readfile() {//puts the weights from file weights.json into hweightss and oweightss
    inh = loadJSONArray("data/weighth.json");
    ino = loadJSONArray("data/weighto.json");
    if (inh != null && ino != null) {
      hWeightss = new float[500][900];//hi
      oWeightss = new float[27][500];//oh
      int ch = 0;
      int co = 0;
      for (int i = 0; i < 500; i++) {
        for (int k = 0; k < 900; k++) {
          hWeightss[i][k] = inh.getJSONObject(ch).getFloat(w);
          ch++;
        }
        for (int j = 0; j < 27; j++) {
          oWeightss[j][i] = ino.getJSONObject(co).getFloat(w);
          co++;
        }
      }
    }
  }
}

