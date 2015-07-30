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
  int expect;
  Photo photo;
  boolean isDone = false;
  int count = 0;

  Learn() {
    hWeights = new float[500][901];
    oWeights = new float[27][501];
    //get weights from txt files


    while (count < 10) {
      //get random 30x30 photo to put through learn
      photo = allCharacters.get(round(random(allCharacters.size()-1)));
      //photo = allCharacters.get(0);
      photo.pi.loadPixels();
      float[] temp = photo.values;

      input = new float[temp.length + 1];
      for (int i = 0; i< temp.length; i++)
        input[i] = temp[i];

      input[input.length - 1] = 1; //last input = dummy

      // input * hWeights = hIns
      // hIns --> function G --> hidden
      // hidden * oWeights = oIns
      // oIns --> function G --> output

      //hidden stuff
      hidden = new float[501]; //500 neurons, index 500 is dummy
      hIns = new float[hidden.length - 1]; 
      hWeights = new float[hidden.length - 1][input.length];

      //output stuff
      output = new float[27];  // indices 0 - 25 = letters of alphabet, index 26 = " "
      oIns = new float[output.length];
      oWeights = new float[output.length][hidden.length];

      /*      for (int i = 0; i < hWeights[0].length; i++) 
       hWeights[0][i] = .1;
       for (int i = 0; i < oWeights[0].length; i++)
       oWeights[0][i] = .1;*/

      //expected
      expected = new float[output.length];
      setExpected(photo.expect);

      readFile();

      neuralNet();

      count++;
    }

    isDone = true;
  }

  //calls everything and writes into the text files
  void neuralNet() {

    float temp = err();
    int errCount = 0;

    while (err () > .1) {

      hIns = getIn(input, hWeights);
      hidden = functionG(hIns, false);
      hidden[hidden.length - 1] = 1; //update bias value

      oIns = getIn(hidden, oWeights);
      output = functionG(oIns, true);

      println(output);
      println("Error: " + err());
      println("Count: " + count);
      println("expected: " + photo.expect);
      println("alpha: " + alpha);

      if (err() < 2) {
        alpha -= 0.01;
      }
      if ((err() > 25 && errCount > 10) || alpha < -5) {
        alpha = .75;
      }
      if (err() >= temp) {
        errCount++;
      } else {
        errCount = 0;
      }
      temp = err();

      float[][] hTemp = new float[hWeights.length][hWeights[0].length];
      float[][] oTemp = new float[oWeights.length][oWeights[0].length];

      for (int j = 0; j < hTemp.length; j++) {
        hTemp[j] = changeWeights(deltaHid(j), hIns, hWeights[j]);
      }

      for (int k = 0; k < oTemp.length; k++) {
        oTemp[k] = changeWeights(deltaOut(k), oIns, oWeights[k]);
      }
      hWeights = hTemp;
      oWeights = oTemp;
    }

    writeFile();
  }

  //takes array of inputs and 2d array of weights, returns array of weighted sums
  //Params:
  //float in[num-of-inputs + 1], float weights[num-of-outputs][num-of-inputs + 1]
  float[] getIn(float[] in, float[][] weights) {
    float weightedSums [] = new float[weights.length]; 
    for (int j = 0; j < weights.length; j++) {
      float current = 0;
      for (int i = 0; i < weights[0].length; i++)
        current += weights[j][i]*in[i]; 
      weightedSums[j] = current;
    }
    return weightedSums;
  }

  //takes array of weighted sums (inputs), puts it through function G
  //Param: float ins[num-of-inputs], boolean outputLayer
  //Returns: float out[num-of-outputs = num-of-inputs + 1]
  float[] functionG(float ins[], boolean outputLayer) {
    int extra = 1; //account for dummyNode in hiddenLayer's output
    if (outputLayer) {
      extra = 0;
    }

    float out[] = new float[ins.length + extra];

    for (int i = 0; i < ins.length; i++)
      out[i] = 1/(1+exp(-1*ins[i]));

    if (!outputLayer) {
      out[out.length - 1] = 1;
    }
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
      sum += abs(err(i));
    return sum;
  }

  //finds the delta value for a neuron k in the output layer
  float deltaOut(int k) {
    return err(k) * gPrime( oIns[k] );
  }

  //finds the delta value for a neuron j in the hidden layer
  float deltaHid(int j) {
    float sum = 0;
    for (int k = 0; k < output.length - 1; k++)
      sum += oWeights[k][j] * deltaOut(k);
    return sum * gPrime( hIns[j] );
  }

  //changes the weights for 1 neuron
  float[] changeWeights(float delta, float[] in, float[] weights) {
    float[] newWeights = new float[weights.length];
    for (int i = 0; i < in.length; i++)
      newWeights[i] = weights[i] + alpha * in[i] * delta;
    return newWeights;
  }

  //set expected result for each input picture (e.g. "a" will have expected [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
  void setExpected(int i) {
    for (int a = 0; a < expected.length; a++)
      expected[a] = 0;
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
    if (isTeaching) {
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
    } else {
      try {
        pw = new PrintWriter(new FileWriter("./Documents/Processing/CharacterRecognition/data/results.txt"));
      } 
      catch (Exception e) { 
        e.printStackTrace();
      }
    }
    pw.close();
    pw2.close();

    if (isDone)
      exit();
  }
}

