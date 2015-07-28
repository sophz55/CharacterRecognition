class Learn {

  //Roz
  /*JSONArray valuesh; //to put into the file
   JSONArray valueso; // to put into the file
   JSONArray ino; //coming from the file
   JSONArray inh; //coming from the file
   String w = "weight";
   float[][] hWeightss;//weights read in by file indexed by [hidden][input]
   float[][] oWeightss; //weights read in by file indexed by [output][hidden]*/
  //boolean pls = false;

  float hWeights[][]; // weights indexed by [hidden_node][input]
  float hidden[]; // output of nodes in hidden layer
  float hIns[]; // total input to each hidden node
  float oWeights[][]; // weights indexed by [output_node][hidden_node]
  float output[]; // outputs of nodes in output layer
  float oIns[]; // total input to each output node
  float input[]; //  input to nueral network (input[0] corresponds to special input of 1)
  float expected[]; // expected output
  float alpha = 1;

  Photo photo;

  Learn(PImage img) {
    photo = new Photo(img);
    image(photo.pi, 0, 0);
    photo.changeSize();
    size(photo.pi.width, photo.pi.height);
    image(photo.pi, 0, 0);

    //make input from pixels of given PImage
    photo.pi.loadPixels();
    float[] temp = photo.greyscale();
    input = new float[temp.length+1];
    input[0] = 1; //dummy
    for (int i = 0; i< temp.length; i++)
      input[i+1] = temp[i];

    //hidden stuff
    hidden = new float[501];
    hIns = new float[hidden.length];
    hWeights = new float[hidden.length][input.length];

    //output stuff
    output = new float[27];
    oIns = new float[output.length];
    oWeights = new float[output.length][hidden.length];

    //expected
    expected = new float[output.length];
    setExpected(1);

    //set initial weights
    //readFile();
    /*for (float[] els : hWeights)
      for (float el : els)
        el = random(1);
    for (float[] els : oWeights)
      for (float el : els)
        el = random(1);*/

    for (int i = 0; i < hWeights[0].length; i++) 
      hWeights[0][i] = 0.1;
    for (int i = 0; i < oWeights[0].length; i++)
      oWeights[0][i] = 0.1;
  }

  //calls everything and writes into the text files
  void stuff() {
    while (err() > .01) {
      hIns = getIn(input, hWeights);
      hidden = functionG(hIns);
      oIns = getIn(hidden, oWeights);
      output = functionG(oIns);
      println(output);
      println("Error: " + err());
      println("alpha: " + alpha);
      if (err() < 3) {
          alpha -= 0.01;
      }
      for (int j = 0; j < hidden.length; j++)
        hWeights[j] = changeWeights(deltaHid(j), hIns, hWeights[j]);
      for (int k = 0; k < output.length; k++)
        oWeights[k] = changeWeights(deltaOut(k), oIns, oWeights[k]);
    }
    writeFile();
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
    return expected[k] - output[k];
  }

  //finds total error for all outputs (sum of squares)
  float err() {
    float sum = 0;
    for (int i = 0; i < output.length; i++)
      sum += err(i) * err(i);
    return sum;
  }

  //finds the delta value for a neuron k in the output layer
  float deltaOut(int k) {
    return err(k)*gPrime(oIns[k]);
  }

  //finds the delta value for a neuron j in the hidden layer
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

  //set expected result for each input picture (e.g. "a" will have expected [0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
  void setExpected(int i) {
    for (float el : expected)
      el = 0;
    expected[i] = 1;
  }

  //reads in and sets weights for hidden and output layers from text files
  void readFile() {
    BufferedReader br = null;
    BufferedReader br2 = null;
    try {
      br = new BufferedReader(new FileReader("./Documents/Processing/CharacterRecognition/data/hWeights.txt"));
      br2 = new BufferedReader(new FileReader("./Documents/Processing/CharacterRecognition/data/oWeights.txt"));
    } 
    catch (Exception e) {
      e.printStackTrace();
    }
    for (int i = 0; i < hWeights.length; i++) {
      for (int j = 0; j < hWeights[0].length; j++) {
        try {
          hWeights[i][j]=Float.parseFloat(br.readLine());
        } 
        catch (Exception e) {
        }
      }
    }
    for (int i = 0; i < oWeights.length; i++) {
      for (int j = 0; j < oWeights[0].length; j++) {
        try {
          oWeights[i][j]=Float.parseFloat(br2.readLine());
        } 
        catch (Exception e) {
        }
      }
    }
  }

  //writes in new weights to the text files after they have been adjusted
  void writeFile() {
    PrintWriter pw = null;
    PrintWriter pw2 = null;
    try {
      pw = new PrintWriter(new FileWriter("./Documents/Processing/CharacterRecognition/data/hWeights.txt"));
      pw2 = new PrintWriter(new FileWriter("./Documents/Processing/CharacterRecognition/data/oWeights.txt"));
    } 
    catch (Exception e) { 
      e.printStackTrace();
    }
    for (int i = 0; i < hWeights.length; i++) {
      for (int j = 0; j < hWeights[0].length; j++) {
        pw.println(hWeights[i][j]);
      }
    }
    for (int i = 0; i < oWeights.length; i++) {
      for (int j = 0; j < oWeights[0].length; j++) {
        pw2.println(oWeights[i][j]);
      }
    }

    pw.close();
    pw2.close();
    exit();
  }


  //JSON Array stuff
  /* void writefile() { //puts weights into the file weights.json
   valuesh = new JSONArray();
   valueso = new JSONArray();
   
   for (int i = 0; i < hidden.length; i ++) {
   JSONObject jobo = new JSONObject();
   for (int j = 0; j < output.length; j++) {
   jobo.setFloat(w, oWeights[j][i]);
   valueso.setJSONObject(j + i * hidden.length, jobo);
   }
   }
   
   for (int k = 0; k < input.length; k++) {
   JSONObject jobh = new JSONObject();
   for (int i = 0; i < hidden.length; i ++) {
   jobh.setFloat(w, hWeights[i][k]);
   valuesh.setJSONObject(k + i * hidden.length, jobh);
   }
   }
   
   saveJSONArray(valuesh, "data/h.json");
   saveJSONArray(valueso, "data/o.json");
   }
   
   void readfile() {//puts the weights from file weights.json into hweightss and oweightss
   inh = loadJSONArray("data/h.json");
   ino = loadJSONArray("data/o.json");
   
   if (inh != null && ino != null) {
   hWeightss = new float[hidden.length][input.length];//hi
   oWeightss = new float[output.length][hidden.length];//oh
   int ch = 0;
   int co = 0;
   for (int i = 0; i < hidden.length; i++) {
   for (int k = 0; k < input.length; k++) {
   hWeightss[i][k] = inh.getJSONObject(ch).getFloat(w);
   //println(ch + " " +inh.getJSONObject(ch).getFloat(w));
   ch++;
   }
   for (int j = 0; j < output.length; j++) {
   oWeightss[j][i] = ino.getJSONObject(co).getFloat(w);
   co++;
   }
   }
   }
   pls = true;
   }*/
}

